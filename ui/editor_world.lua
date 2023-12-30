
-- header
local path = GetParentPath(...)
local helpers = require(path.."helpers")
local tooltip_islandComposite = require(path.."helper_tooltip_islandComposite")
local DecoIcon = require(path.."deco/DecoIcon")
local DecoImmutable = require(path.."deco/DecoImmutable")
local DecoImmutableIsland = DecoImmutable.ObjectSurface2xCenterClip
local DecoImmutableIslandOutline = DecoImmutable.IslandCompositeIsland
local DecoImmutableIslandCompositeTitle = DecoImmutable.ObjectNameLabelBounceCenterHClip
local UiDragSource = require(path.."widget/UiDragSource")
local UiDragObject_Island = require(path.."widget/UiDragObject_Island")
local UiDropTarget = require(path.."widget/UiDropTarget")
local UiScrollAreaExt = require(path.."widget/UiScrollAreaExt")
local UiScrollArea = UiScrollAreaExt.vertical
local UiScrollAreaH = UiScrollAreaExt.horizontal

-- defs
local EDITOR_TITLE = "World Editor"
local ENTRY_HEIGHT = helpers.ENTRY_HEIGHT
local PADDING = 8
local SCROLLBAR_WIDTH = 16
local ORIENTATION_VERTICAL = helpers.ORIENTATION_VERTICAL
local ORIENTATION_HORIZONTAL = helpers.ORIENTATION_HORIZONTAL
local DRAG_TARGET_TYPE = easyEdit.islandComposite:getDragType()
local TOOLTIP_ISLAND_COMPOSITE = tooltip_islandComposite
local DEFAULT_ISLAND_SLOTS = { "archive", "rst", "pinnacle", "detritus" }
local ISLAND_ICON_DEF = easyEdit.island:getIconDef()
local ISLAND_COMPOSTE_COMPONENTS = {
	"island",
	"corporation",
	"ceo",
	"tileset",
	"enemyList",
	"bossList",
	"missionList",
	"structureList",
}

-- ui
local islandSlots
local worldEditor = {}
local dragObject = UiDragObject_Island(DRAG_TARGET_TYPE)

local function resetAll()
	for i = 1, 4 do
		local islandComposite = easyEdit.islandComposite:get(DEFAULT_ISLAND_SLOTS[i])
		local island = easyEdit.island:get(islandComposite.island)
		local islandInSlot = islandSlots[i]

		islandInSlot.data = islandComposite
	end
end

local function getIslandsAvaliable()
	local t = copy_table(easyEdit.islandComposite._children)
	local ret = {}
	for island, composite in pairs(t) do
		table.insert(ret, island)
	end
	return ret
end

local function chaosRoll()
	local islands_avaliable = getIslandsAvaliable()
	for i = 1, 4 do
		local choice = islands_avaliable[random_int(#islands_avaliable)+1]
		local islandComposite = easyEdit.islandComposite:get(choice)
		local islandInSlot = islandSlots[i]

		islandInSlot.data = islandComposite
	end
end

local function balancedRoll()
	local islands_avaliable = getIslandsAvaliable()
	for i = 1, 4 do
		local choice = random_removal(islands_avaliable)
		local islandComposite = easyEdit.islandComposite:get(choice)
		local islandInSlot = islandSlots[i]

		islandInSlot.data = islandComposite
	end
end

local function updateWorldCache()
	for i = 1, 4 do
		local islandComposite = islandSlots[i].data

		if islandComposite then
			easyEdit.savedata.cache.world[i] = islandComposite._id
		else
			easyEdit.savedata.cache.world[i] = easyEdit.savedata.cache.world[i] or DEFAULT_ISLAND_SLOTS[i]
		end
	end
end

local function setParentAsGroupOwner(self)
	self.groupOwner = self.parent
end

local function buildFrameContent(parentUi)
	local root = sdlext:getUiRoot()
	local islandComposites = UiBoxLayout()

	islandSlots = {
		UiDropTarget(DRAG_TARGET_TYPE),
		UiDropTarget(DRAG_TARGET_TYPE),
		UiDropTarget(DRAG_TARGET_TYPE),
		UiDropTarget(DRAG_TARGET_TYPE),
	}

	for islandSlot, islandUi in ipairs(islandSlots) do
		local currentIslandComposite = easyEdit.world[islandSlot]
		local currentIsland = easyEdit.island:get(currentIslandComposite.island)

		local function onTooltipShown(self, hoveredUi)
			local missing = false
			local malformed = false

			local editedIslandComposite = self.parent.data
			if editedIslandComposite == nil then
				local missingIslandCompositeId = easyEdit.savedata.cache.world[islandSlot]
				self.tooltip = "Missing island composite: "..missingIslandCompositeId
			else
				local tooltip = {}
				for _, name in ipairs(ISLAND_COMPOSTE_COMPONENTS) do

					local componentId = editedIslandComposite[name]
					local component = easyEdit[name]:get(componentId)
					if componentId == nil then
						missing = true
						tooltip[#tooltip+1] = "Missing "..name.."\n"
					elseif component == nil then
						missing = true
						tooltip[#tooltip+1] = "Missing "..name..": "..componentId.."\n"
					elseif component:isInvalid() then
						malformed = true
						tooltip[#tooltip+1] = "Malformed "..name..": "..componentId.."\n"
					end
				end

				if missing or malformed then
					self.tooltip_title = "Update blocked"
					self.tooltip = table.concat(tooltip):sub(1,-2)
				else
					local editedIsland = easyEdit.island:get(editedIslandComposite.island)
					self.tooltip_title = "Restart required"
					self.tooltip = string.format("Restart required for island graphics to change from %s to %s", currentIsland:getName(), editedIsland:getName())
				end
			end
		end

		local function draw_ifIssue(self, screen)
			local issue = false
			local editedIslandComposite = self.parent.data

			if editedIslandComposite == nil or editedIslandComposite:isInvalid() then
				issue = true
			end

			if not issue then
				issue = currentIslandComposite.island ~= editedIslandComposite.island
			end

			if issue then
				self.__index.draw(self, screen)
			end
		end

		islandUi
			:beginUi()
				:format(setParentAsGroupOwner)
				:anchor("right", "top")
				:sizepx(40, 40)
				:pospx(20, 20)
				:setVar("draw", draw_ifIssue)
				:setVar("onTooltipShown", onTooltipShown)
				:decorate{
					DecoImmutable.SolidHalfBlack,
					DecoImmutable.WarningLarge,
				}
			:endUi()
	end

	local content = UiWeightLayout()
		:size(1,1)
		:hgap(0)
		:beginUi()
			:size(1,1)
			:padding(PADDING)
			:beginUi(UiWeightLayout)
				:size(1,1)
				:vgap(8)
				:orientation(ORIENTATION_VERTICAL)
				:beginUi()
					:width(1):heightpx(ENTRY_HEIGHT)
					:setVar("padl", 8)
					:setVar("padr", 8)
					:setVar("text_title_centerv", "World")
					:decorate{
						DecoImmutable.Frame,
						DecoImmutable.TextTitleCenterV,
					}
				:endUi()
				:beginUi()
					:size(1,1)
					:decorate{
						DecoImmutable.Frame,
						DecoIcon("img/strategy/waterbg.png", { clip = true }),
					}
					:beginUi(islandSlots[1])
						:size(.5, .5)
						:anchor("left", "top")
					:endUi()
					:beginUi(islandSlots[2])
						:size(.5, .5)
						:anchor("left", "bottom")
					:endUi()
					:beginUi(islandSlots[3])
						:size(.5, .5)
						:anchor("right", "top")
					:endUi()
					:beginUi(islandSlots[4])
						:size(.5, .5)
						:anchor("right", "bottom")
					:endUi()
				:endUi()
			:endUi()
		:endUi()
		:beginUi()
			:widthpx(0
				+ ISLAND_ICON_DEF.width * ISLAND_ICON_DEF.scale
				+ 4 * PADDING + SCROLLBAR_WIDTH
			)
			:height(1)
			:padding(PADDING)
			:beginUi(UiWeightLayout)
				:size(1,1)
				:vgap(8)
				:orientation(ORIENTATION_VERTICAL)
				:beginUi()
					:width(1):heightpx(ENTRY_HEIGHT)
					:setVar("padl", 8)
					:setVar("padr", 8)
					:setVar("text_title_centerv", "Islands")
					:decorate{
						DecoImmutable.Frame,
						DecoImmutable.TextTitleCenterV,
					}
				:endUi()
				:beginUi(UiScrollArea)
					:size(1,1)
					:decorate{ DecoImmutable.Frame }
					:beginUi(islandComposites)
						:size(1,1)
						:padding(PADDING)
						:vgap(7)
					:endUi()
				:endUi()
			:endUi()
		:endUi()

	local cache_world = easyEdit.savedata.cache.world or DEFAULT_ISLAND_SLOTS

	for islandSlot, cache_data in ipairs(cache_world) do
		local islandComposite = easyEdit.islandComposite:get(cache_data)
		local islandInSlot = islandSlots[islandSlot]

		islandInSlot
			:setVar("data", islandComposite)
			:setCustomTooltip(TOOLTIP_ISLAND_COMPOSITE)
			:decorate{ DecoImmutableIslandOutline }
	end

	for _, islandComposite in pairs(easyEdit.islandComposite._children) do
		local entry = UiDragSource(dragObject)

		entry
			:widthpx(ISLAND_ICON_DEF.width * ISLAND_ICON_DEF.scale)
			:heightpx(ISLAND_ICON_DEF.height * ISLAND_ICON_DEF.scale)
			:setVar("data", islandComposite)
			:setCustomTooltip(TOOLTIP_ISLAND_COMPOSITE)
			:decorate{
				DecoImmutable.Button,
				DecoImmutable.Anchor,
				DecoImmutableIsland,
				DecoImmutable.TransHeader,
				DecoImmutableIslandCompositeTitle,
			}
			:addTo(islandComposites)
	end

	return content
end

local function buildFrameButtons(buttonLayout)
	local tooltip = "Reset everything to default."
	local tooltip_disabled = "Everything is already set to default"
	local button = sdlext.buildButton("Default"):addTo(buttonLayout)

	function button:relayout()
		self.disabled = true

		for islandSlot, island in ipairs(islandSlots) do
			if island.data == nil or island.data:getId() ~= DEFAULT_ISLAND_SLOTS[islandSlot] then
				self.disabled = false
				break
			end
		end

		if self.disabled then
			if self.tooltip ~= tooltip_disabled then
				self:settooltip(tooltip_disabled)
			end
		else
			if self.tooltip ~= tooltip then
				self:settooltip(tooltip)
			end
		end

		Ui.relayout(self)
	end

	local onclicked = button.onclicked
	function button:onclicked(button)
		if self.disabled then
			return true
		end

		resetAll()

		return true
	end

	local chaos_tooltip = "Randomize the islands, with duplicates"
	local chaos_button = sdlext.buildButton("Chaos Roll"):addTo(buttonLayout)
	chaos_button:settooltip(chaos_tooltip)
	function chaos_button:onclicked(chaos_button)
		chaosRoll()
		return true
	end

	local balanced_tooltip = "Randomize the islands, without duplicates"
	local balanced_button = sdlext.buildButton("Balanced Roll"):addTo(buttonLayout)
	balanced_button:settooltip(balanced_tooltip)
	function balanced_button:onclicked(balanced_button)
		balancedRoll()
		return true
	end
end

local function onExit()
	updateWorldCache()

	easyEdit.savedata:saveAsFile("world", easyEdit.savedata.cache.world)
	easyEdit.savedata:updateLiveData()
end

function worldEditor.mainButton()
	sdlext.showDialog(function(ui, quit)
		ui.onDialogExit = onExit

		local frame = sdlext.buildButtonDialog(
			EDITOR_TITLE,
			buildFrameContent,
			buildFrameButtons
		)

		function frame:onGameWindowResized(screen, oldSize)
			local minW = 800
			local minH = 600
			local maxW = 1000
			local maxH = 800
			local width = math.min(maxW, math.max(minW, ScreenSizeX() - 200))
			local height = math.min(maxH, math.max(minH, ScreenSizeY() - 100))

			self
				:widthpx(width)
				:heightpx(height)
		end

		frame
			:addTo(ui)
			:anchor("center", "center")
			:onGameWindowResized()
	end)
end

return worldEditor
