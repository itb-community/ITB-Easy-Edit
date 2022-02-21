
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
local decorate_button_structure = decorate.button.structure

-- defs
local DRAG_TYPE_STRUCTURE = modApi.structures:getDragType()
local TITLE_EDITOR = "Structure List Editor"
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
local structureListEditor = {}
local dragObject = dragEntry(modApi.structures)

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
	local structures = UiBoxLayout()
	local structure_iconDef = modApi.structures:getIconDef()
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
				:add(createUiTitle("Structure Lists"))
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
							:setVar("padl", 5) -- pad text
							:decorate{ createDecoGroupButton() }
							:beginUi(createNewList)
								:setVar("textfield", TITLE_CREATE_NEW_LIST)
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
			:widthpx(structure_iconDef.width * structure_iconDef.scale + 4 * PADDING + SCROLLBAR_WIDTH)
			:padding(PADDING)
			:beginUi(UiWeightLayout)
				:width(1)
				:vgap(8)
				:orientation(ORIENTATION_VERTICAL)
				:add(createUiTitle("Structures"))
				:beginUi(UiScrollArea)
					:decorate{ DecoFrame() }
					:beginUi(structures)
						:padding(PADDING)
						:vgap(7)
					:endUi()
				:endUi()
			:endUi()
		:endUi()

	for _, objectList in pairs(modApi.structureList._children) do
		contentListContainers:add(dynamicContentListContainer(objectList, dragObject))
	end

	for _, structure in pairs(modApi.structures._children) do
		local entry = UiDragSource(dragObject)

		entry
			:widthpx(structure_iconDef.width * structure_iconDef.scale)
			:heightpx(structure_iconDef.height * structure_iconDef.scale)
			:setVar("data", structure)
			:settooltip("Drag-and-drop on a structure list", nil, true)
			:addTo(structures)

		decorate_button_structure(entry, structure)
	end

	function createNewList:onEnter()
		local name = self.textfield
		if name:len() > 0 and modApi.structureList:get(name) == nil then
			local objectList = modApi.structureList:add(name)
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
		"Reset everything to default\n\nWARNING: This will delete all custom structure lists",
		resetAll
 	):addTo(buttonLayout)
end

local function onExit()
	modApi.structureList:save()
end

-- main button
function structureListEditor.mainButton()

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

return structureListEditor
