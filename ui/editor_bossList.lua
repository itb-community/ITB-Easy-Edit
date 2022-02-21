
-- header
local path = GetParentPath(...)
local helpers = require(path.."helpers")
local decorate = require(path.."helper_decorate")
local tooltip = require(path.."helper_tooltip")
local dragEntry = require(path.."helper_dragEntry")
local UiDragSource = require(path.."widget/UiDragSource")
local UiDragObject = require(path.."widget/UiDragObject")
local UiDropTarget = require(path.."widget/UiDropTarget")
local UiScrollAreaExt = require(path.."widget/UiScrollAreaExt")
local UiScrollArea = UiScrollAreaExt.vertical
local UiScrollAreaH = UiScrollAreaExt.horizontal
local dynamicContentList = require(path.."helper_dynamicContentList")
local dynamicContentListContainer = require(path.."helper_dynamicContentListContainer")

local createUiTitle = helpers.createUiTitle
local createDecoGroupButton = helpers.createDecoGroupButton
local decorate_button_unit = decorate.button.unit

-- defs
local DRAG_TYPE_MISSION = modApi.missions:getDragType()
local TITLE_EDITOR = "Boss List Editor"
local TITLE_CREATE_NEW_LIST = "Create new list"
local FONT_TITLE = helpers.FONT_TITLE
local TEXT_SETTINGS_TITLE = helpers.TEXT_SETTINGS_TITLE
local ORIENTATION_VERTICAL = helpers.ORIENTATION_VERTICAL
local ORIENTATION_HORIZONTAL = helpers.ORIENTATION_HORIZONTAL
local PADDING = 8
local SCROLLBAR_WIDTH = 16
local OBJECT_LIST_HEIGHT = helpers.OBJECT_LIST_HEIGHT
local OBJECT_LIST_PADDING = helpers.OBJECT_LIST_PADDING
local OBJECT_LIST_GAP = helpers.OBJECT_LIST_GAP

-- ui
local contentListContainers
local bossListEditor = {}
local dragObject = dragEntry(modApi.missions)

local function resetAll()
	for i = #contentListContainers.children, 1, -1 do
		local contentListContainer = contentListContainers.children[i]
		local contentList = contentListContainer.contentList
		local objectList = contentList.data

		if objectList:isCustom() then
			if objectList:delete() then
				contentListContainer:detach()
			end
		else
			objectList:reset()
			dynamicContentList(contentList, objectList)
		end
	end
end

local function buildFrameContent(parentUi)
	contentListContainers = UiBoxLayout()
	local bossMissions = UiBoxLayout()
	local unit_iconDef = modApi.units:getIconDef()
	local createNewList = UiTextBox()
	local dropTargets = {}

	local content = UiWeightLayout()
		:hgap(0)
		:beginUi(Ui)
			:padding(PADDING)
			:beginUi(UiWeightLayout)
				:width(1)
				:vgap(8)
				:orientation(ORIENTATION_VERTICAL)
				:add(createUiTitle("Boss Lists"))
				:beginUi(UiScrollArea)
					:decorate{ DecoFrame() }
					:beginUi(UiBoxLayout)
						:height(nil)
						:vgap(OBJECT_LIST_GAP)
						:padding(PADDING)
						:setVar("padt", OBJECT_LIST_PADDING)
						:setVar("padb", OBJECT_LIST_PADDING)
						:anchorH("center")
						:beginUi(contentListContainers)
							:height(nil)
							:vgap(OBJECT_LIST_GAP)
						:endUi()
						:beginUi()
							:heightpx(OBJECT_LIST_HEIGHT)
							:padding(-5) -- unpad button
							:decorate{ createDecoGroupButton() }
							:beginUi(createNewList)
								:setVar("textfield", TITLE_CREATE_NEW_LIST)
								:settooltip("Create a new boss list", nil, true)
								:decorate{
									DecoTextBox{
										font = FONT_TITLE,
										textset = TEXT_SETTINGS_TITLE,
										alignH = "center",
										alignV = "center",
									}
								}
							:endUi()
						:endUi()
					:endUi()
				:endUi()
			:endUi()
		:endUi()
		:beginUi(Ui)
			:widthpx(unit_iconDef.width * unit_iconDef.scale + 4 * PADDING + SCROLLBAR_WIDTH)
			:padding(PADDING)
			:beginUi(UiWeightLayout)
				:width(1)
				:vgap(8)
				:orientation(ORIENTATION_VERTICAL)
				:add(createUiTitle("Bosses"))
				:beginUi(UiScrollArea)
					:decorate{ DecoFrame() }
					:beginUi(bossMissions)
						:padding(PADDING)
						:vgap(7)
					:endUi()
				:endUi()
			:endUi()
		:endUi()

	for _, objectList in pairs(modApi.bossList._children) do
		local contentListContainer = dynamicContentListContainer(objectList, dragObject)
		contentListContainers:add(contentListContainer)
		contentListContainer.contentList
			:setVar("isGroupTooltip", true)
			:settooltip("Drag-and-drop units to edit the boss list", nil, true)
	end

	local bossMissions_filtered = filter_table(modApi.missions._children, function(k, v)
		return v.BossPawn ~= nil
	end)

	for _, bossMission in pairs(bossMissions_filtered) do
		local entry = UiDragSource(dragObject)

		entry
			:widthpx(unit_iconDef.width * unit_iconDef.scale)
			:heightpx(unit_iconDef.height * unit_iconDef.scale)
			:setVar("data", bossMission)
			:settooltip("Drag-and-drop to add to a boss list", nil, true)
			:addTo(bossMissions)

		local unit = modApi.units:get(bossMission.BossPawn)
		decorate_button_unit(entry, unit)
	end

	function createNewList:onEnter()
		local name = self.textfield
		if name:len() > 0 and modApi.bossList:get(name) == nil then
			local objectList = modApi.bossList:add(name)
			objectList:lock()
			contentListContainers:add(dynamicContentListContainer(objectList, dragObject))
		end

		self.root:setfocus(content)
	end

	createNewList.onFocusChangedEvent:subscribe(function(uiTextBox, focused, focused_prev)
		if focused then
			uiTextBox.textfield = ""
			uiTextBox:setCaret(0)
			uiTextBox.selection = nil
		else
			uiTextBox.textfield = TITLE_CREATE_NEW_LIST
		end
	end)

	function content:keydown(keycode)
		if SDLKeycodes.isEnter(keycode) then
			createNewList:show()
			createNewList:setfocus()

			return true
		end
	end

	return content
end

local function buildFrameButtons(buttonLayout)
	sdlext.buildButton(
		"Default",
		"Reset everything to default\n\nWARNING: This will delete all custom boss lists",
		resetAll
 	):addTo(buttonLayout)
end

local function onExit()
	modApi.bossList:save()
end

-- main button
function bossListEditor.mainButton()

	sdlext.showDialog(function(ui, quit)
		ui.onDialogExit = onExit

		local frame = sdlext.buildButtonDialog(
			TITLE_EDITOR,
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

return bossListEditor
