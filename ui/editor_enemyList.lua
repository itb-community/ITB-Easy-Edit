
-- header
local path = GetParentPath(...)
local helpers = require(path.."helpers")
local DecoImmutable = require(path.."deco/DecoImmutable")
local UiDragSource = require(path.."widget/UiDragSource")
local UiContentList = require(path.."widget/UiContentList")
local UiScrollAreaExt = require(path.."widget/UiScrollAreaExt")
local UiScrollArea = UiScrollAreaExt.vertical
local UiScrollAreaH = UiScrollAreaExt.horizontal

local getCreateUnitDragSourceCopyFunc = helpers.getCreateUnitDragSourceCopyFunc
local getCreateUnitDragSourceFunc = helpers.getCreateUnitDragSourceFunc
local contentListDragObject = helpers.contentListDragObject
local resetButton_contentList = helpers.resetButton_contentList
local deleteButton_contentList = helpers.deleteButton_contentList
local getSurface = sdlext.getSurface
local getTextSurface = sdl.text
local makeCullable = helpers.makeCullable


-- defs
local DRAG_TYPE_ENEMY = easyEdit.units:getDragType()
local TITLE_EDITOR = "Enemy List Editor"
local TITLE_CREATE_NEW_LIST = "Create new list"
local FONT_TITLE = helpers.FONT_TITLE
local TEXT_SETTINGS_TITLE = helpers.TEXT_SETTINGS_TITLE
local FONT_LABEL = helpers.FONT_LABEL
local TEXT_SETTINGS_LABEL = helpers.TEXT_SETTINGS_LABEL
local ORIENTATION_VERTICAL = helpers.ORIENTATION_VERTICAL
local ORIENTATION_HORIZONTAL = helpers.ORIENTATION_HORIZONTAL
local ENTRY_HEIGHT = helpers.ENTRY_HEIGHT
local PADDING = 8
local SCROLLBAR_WIDTH = 16
local OBJECT_LIST_HEIGHT = helpers.OBJECT_LIST_HEIGHT
local OBJECT_LIST_PADDING = helpers.OBJECT_LIST_PADDING
local OBJECT_LIST_GAP = helpers.OBJECT_LIST_GAP
local UNIT_ICON_DEF = easyEdit.units:getIconDef()
local TRANSFORM_UNIT = helpers.transformUnit
local TRANSFORM_UNIT_HL = helpers.transformUnitHl
local TRANSFORM_UNIT_DRAG_HL = helpers.transformUnitDragHl
local CONTENT_ENTRY_DEF = copy_table(UNIT_ICON_DEF)
CONTENT_ENTRY_DEF.width = 25
CONTENT_ENTRY_DEF.height = 25
CONTENT_ENTRY_DEF.clip = false


-- ui
local contentListContainers
local enemyListEditor = {}
local dragObject = contentListDragObject(easyEdit.units:getDragType())
	:setVar("createObject", getCreateUnitDragSourceCopyFunc(CONTENT_ENTRY_DEF))
	:decorate{ DecoImmutable.ObjectSurface2xOutline }

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
			contentList:reset()
			contentList:populate()
		end
	end
end

local function buildFrameContent(parentUi)
	contentListContainers = UiBoxLayout()
	local enemies = UiBoxLayout()
	local createNewList = UiInputField()
	local dropTargets = {}

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
					:decorate{
						DecoImmutable.Frame,
						DecoText("Enemy Lists", FONT_TITLE, TEXT_SETTINGS_TITLE),
					}
				:endUi()
				:beginUi(UiScrollArea)
					:size(1,1)
					:decorate{ DecoImmutable.Frame }
					:beginUi(UiBoxLayout)
						:width(1):height(nil)
						:vgap(OBJECT_LIST_GAP)
						:padding(PADDING)
						:setVar("padt", OBJECT_LIST_PADDING)
						:setVar("padb", OBJECT_LIST_PADDING)
						:anchorH("center")
						:beginUi(contentListContainers)
							:width(1):height(nil)
							:vgap(OBJECT_LIST_GAP)
						:endUi()
						:beginUi()
							:width(1):heightpx(OBJECT_LIST_HEIGHT)
							:padding(-5) -- unpad button
							:decorate{ DecoImmutable.GroupButton }
							:beginUi(createNewList)
								:size(1,1)
								:format(function(self) self:setGroupOwner(self.parent) end)
								:setVar("textfield", TITLE_CREATE_NEW_LIST)
								:settooltip("Create a new enemy list", nil, true)
								:decorate{
									DecoInputField{
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
			:widthpx(0
				+ UNIT_ICON_DEF.width * UNIT_ICON_DEF.scale
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
					:decorate{
						DecoImmutable.Frame,
						DecoText("Enemies", FONT_TITLE, TEXT_SETTINGS_TITLE),
					}
				:endUi()
				:beginUi(UiScrollArea)
					:size(1,1)
					:decorate{ DecoImmutable.Frame }
					:beginUi(enemies)
						:size(1,1)
						:padding(PADDING)
						:vgap(7)
					:endUi()
				:endUi()
			:endUi()
		:endUi()

	local function addObjectList(objectList)
		local resetButton
		local contentList = UiContentList{
			data = objectList,
			dragObject = dragObject,
			createEntry = getCreateUnitDragSourceFunc(CONTENT_ENTRY_DEF, dragObject),
		}

		if objectList:isCustom() then
			resetButton = deleteButton_contentList()
		else
			resetButton = resetButton_contentList()
		end

		contentList:populate()

		contentListContainers
			:beginUi(UiWeightLayout)
				:width(1):heightpx(40)
				:format(makeCullable)
				:orientation(ORIENTATION_HORIZONTAL)
				:setVar("contentList", contentList)
				:add(resetButton)
				:beginUi(contentList)
					:size(1,1)
					:setVar("isGroupTooltip", true)
					:settooltip("Drag-and-drop units to edit the enemy list"
						.."\n\nHold [CTRL] while dragging to duplicate entries"
						.."\n\nMouse-wheel to scroll the list"
						, nil, true)
				:endUi()
			:endUi()
	end

	local enemyLists_sorted = to_array(easyEdit.enemyList._children)

	stablesort(enemyLists_sorted, function(a, b)
		return alphanum(a:getName():lower(), b:getName():lower())
	end)

	for _, objectList in ipairs(enemyLists_sorted) do
		addObjectList(objectList)
	end

	local enemies_sorted = to_array(filter_table(easyEdit.units._children, function(k, v)
		return v:isBaseEnemy()
	end))

	stablesort(enemies_sorted, function(a, b)
		return alphanum(a:getName():lower(), b:getName():lower())
	end)

	for _, enemy in ipairs(enemies_sorted) do
		local enemyId = enemy._id
		local entry = UiDragSource(dragObject)

		entry.data = enemy
		entry.saveId = enemyId:sub(1,-2)
		entry.createObject = getCreateUnitDragSourceCopyFunc(CONTENT_ENTRY_DEF)

		entry
			:widthpx(UNIT_ICON_DEF.width * UNIT_ICON_DEF.scale)
			:heightpx(UNIT_ICON_DEF.height * UNIT_ICON_DEF.scale)
			:settooltip("Drag-and-drop to add to an enemy list", nil, true)
			:decorate{
				DecoImmutable.Button,
				DecoImmutable.Anchor,
				DecoImmutable.ObjectSurface2xOutlineCenterClip,
				DecoImmutable.TransHeader,
				DecoImmutable.ObjectNameLabelBounceCenterHClip,
			}
			:format(makeCullable)
			:addTo(enemies)
	end

	function createNewList:onEnter()
		local name = self.textfield
		if name:len() > 0 and easyEdit.enemyList:get(name) == nil then
			local objectList = easyEdit.enemyList:add(name)
			objectList:lock()
			objectList.edited = true
			addObjectList(objectList)
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
	local tooltip = "Reset everything to default\n\nWARNING: This will delete all custom enemy lists"
	local tooltip_disabled = "Everything is already set to default"
	local button = sdlext.buildButton("Default"):addTo(buttonLayout)

	function button:relayout()
		self.disabled = true

		for _, contentListContainer in ipairs(contentListContainers.children) do
			local contentList = contentListContainer.contentList
			local objectList = contentList.data

			if objectList.edited then
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
end

local function onExit()
	easyEdit.enemyList:save()
end

-- main button
function enemyListEditor.mainButton()

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
			local maxW = 1400
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

return enemyListEditor
