
-- header
local path = GetParentPath(...)
local helpers = require(path.."helpers")
local decorate = require(path.."helper_decorate")
local tooltip = require(path.."helper_tooltip")
local tooltip_islandComposite = require(path.."helper_tooltip_islandComposite")
local UiEditBox = require(path.."widget/UiEditBox")
local UiEditorButton = require(path.."widget/UiEditorButton")
local UiScrollAreaExt = require(path.."widget/UiScrollAreaExt")
local UiScrollAreaH = UiScrollAreaExt.horizontal
local UiScrollArea = UiScrollAreaExt.vertical
local UiPopup = require(path.."widget/UiPopup")
local DecoObj = require(path.."deco/DecoObj")
local DecoEditorButton = require(path.."deco/DecoEditorButton")
local staticContentList = require(path.."helper_staticContentList")

local createUiLabel = helpers.createUiLabel
local createUiTitle = helpers.createUiTitle
local createUiEditBox = helpers.createUiEditBox
local createVerticalBar = helpers.createVerticalBar
local createDecoGroupButton = helpers.createDecoGroupButton
local decorate_button = decorate.button

-- defs
local EDITOR_TITLE = "Island Editor"
local BORDER_SIZE = 2
local SCROLL_BAR_WIDTH = 16
local PADDING = 8
local ORIENTATION_HORIZONTAL = helpers.ORIENTATION_HORIZONTAL
local ORIENTATION_VERTICAL = helpers.ORIENTATION_VERTICAL

-- ui
local currentContent
local islandList
local uiEditBox
local islandEditor = {}
local sortLessThan = get_sort_less_than("_id")

local function format_contentList(ui)
	ui
		:decorate{ createDecoGroupButton() }
		:heightpx(40)

	ui.popupWindow
		:width(0.6)
		:height(0.6)

	ui.popupWindow.flowlayout
		:padding(20)
		:vgap(60)
end

local function format_contentListContainer(ui)
	ui
		:heightpx(100)
		:padding(20)
end

local function onPopupEntryClicked(self)
	local popupButton = self.popupOwner

	popupButton.id = self.id
	popupButton.data = self.data

	if easyEdit.displayedEditorButton then
		popupButton:send()
	end

	popupButton.popupWindow:quit()

	return true
end

local function onSend_island(sender, reciever)
	local obj = modApi.island:get(sender.id)
	reciever.data.island = sender.id
	decorate_button.obj(sender, obj)
	reciever.decorations[3]:setObject(obj)
end

local function mkSend_popup(objName)
	return function(sender, reciever)
		local obj = modApi[objName]:get(sender.id)
		reciever.data[objName] = sender.id
		decorate_button.obj(sender, obj)
	end
end

local function mkSend_list(objName)
	return function(sender, reciever)
		local objList = modApi[objName]:get(sender.data)
		reciever.data[objName] = sender.data
		staticContentList(sender, objList)
	end
end

local function mkRecieve_popup(objName)
	return function(reciever, sender)
		local obj = modApi[objName]:get(sender.data[objName])
		reciever.data = obj
		decorate_button.obj(reciever, obj)
	end
end

local function mkRecieve_list(objName)
	return function(reciever, sender)
		local objList = modApi[objName]:get(sender.data[objName])
		staticContentList(reciever, objList)
	end
end

local function onRecieve_id(reciever, sender)
	reciever:updateText(sender.data._id)
end

local onSend = {
	island = onSend_island,
	ceo = mkSend_popup("ceo"),
	tileset = mkSend_popup("tileset"),
	enemyList = mkSend_list("enemyList"),
	missionList = mkSend_list("missionList"),
	bossList = mkSend_list("bossList"),
	structureList = mkSend_list("structureList"),
}

local onRecieve = {
	id = onRecieve_id,
	island = mkRecieve_popup("island"),
	ceo = mkRecieve_popup("ceo"),
	tileset = mkRecieve_popup("tileset"),
	enemyList = mkRecieve_list("enemyList"),
	missionList = mkRecieve_list("missionList"),
	bossList = mkRecieve_list("bossList"),
	structureList = mkRecieve_list("structureList"),
}

local function reset(reciever)
	reciever = reciever or easyEdit.displayedEditorButton
	if reciever == nil then return end

	local objectList = reciever.data

	if objectList:isCustom() then
		-- TODO: test if this makes sense
		if reciever == easyEdit.displayedEditorButton then
			easyEdit.displayedEditorButton = nil
		end
		-- TODO: test what happens to custom created islands
		if objectList:delete() then
			reciever:detach()
		end
	else
		objectList:reset()
		reciever.decorations[3]:setObject(reciever.data)
	end

	for _, ui in pairs(uiEditBox) do
		ui:recieve()
	end
end

local function resetAll()
	for i = #islandList.children, 1, -1 do
		reset(islandList.children[i])
	end
end

local function buildFrameContent(parentUi)
	islandList = UiBoxLayout()
	currentContent = UiScrollArea()

	local iconDef_island = modApi.units:getIconDef()
	local icon_island_width = iconDef_island.width * iconDef_island.scale
	local icon_island_height = iconDef_island.height * iconDef_island.scale

	uiEditBox = {
		id = createUiEditBox(createUiTitle, "Selected Island"),
		island = createUiEditBox(UiPopup, "Islands"),
		ceo = createUiEditBox(UiPopup, "Ceos"),
		tileset = createUiEditBox(UiPopup, "Tilesets"),
		enemyList = createUiEditBox(UiPopup, "Enemy Lists"),
		missionList = createUiEditBox(UiPopup, "Mission Lists"),
		bossList = createUiEditBox(UiPopup, "Boss Lists"),
		structureList = createUiEditBox(UiPopup, "Structure Lists"),
	}

	local content = UiWeightLayout()
		:hgap(0)
		-- left (list of islands)
		:beginUi(Ui)
			:widthpx(0
				+ icon_island_width
				+ SCROLL_BAR_WIDTH
				+ BORDER_SIZE
				+ 4 * PADDING
			)
			:padding(PADDING)
			:beginUi(UiWeightLayout)
				:width(1)
				:vgap(8)
				:orientation(ORIENTATION_VERTICAL)
				:add(createUiTitle("Islands"))
				:beginUi(UiScrollArea)
					:decorate{ DecoFrame() }
					:beginUi(islandList)
						:padding(PADDING)
						:vgap(7)
						:anchorH("left")
					:endUi()
				:endUi()
			:endUi()
		:endUi()
		:beginUi()
			:padding(PADDING)
			:beginUi(UiWeightLayout)
				:width(1)
				:vgap(8)
				:orientation(ORIENTATION_VERTICAL)
				:beginUi(uiEditBox.id)
					:setVar("onRecieve", onRecieve.id)
				:endUi()
				:beginUi(currentContent)
					:hide()
					:beginUi(UiBoxLayout)
						:padding(PADDING)
						:vgap(0)
						:beginUi()
							:heightpx(2)
							:decorate{ DecoSolid(deco.colors.buttonborder) }
						:endUi()
						:beginUi(UiWeightLayout)
							:heightpx(200)
							:beginUi(UiBoxLayout)
								:width(.30)
								:vgap(7)
								:setVar("padt", 8)
								:add(createUiLabel("ISLAND"))
								:beginUi(uiEditBox.island)
									:anchorH("center")
									:setVar("onRecieve", onRecieve.island)
									:setVar("onSend", onSend.island)
									:setCustomTooltip(tooltip.island)
									:addList(
										modApi.island._children,
										decorate_button.obj,
										onPopupEntryClicked
									)
								:endUi()
							:endUi()
							:beginUi()
								:widthpx(2)
								:decorate{ DecoSolid(deco.colors.buttonborder) }
							:endUi()
							:beginUi(UiBoxLayout)
								:width(.30)
								:vgap(7)
								:setVar("padt", 8)
								:add(createUiLabel("CEO"))
								:beginUi(uiEditBox.ceo)
									:anchorH("center")
									:setVar("onRecieve", onRecieve.ceo)
									:setVar("onSend", onSend.ceo)
									:setCustomTooltip(tooltip.ceo)
									:addList(
										modApi.ceo._children,
										decorate_button.obj,
										onPopupEntryClicked
									)
								:endUi()
							:endUi()
							:beginUi()
								:widthpx(2)
								:decorate{ DecoSolid(deco.colors.buttonborder) }
							:endUi()
							:beginUi(UiBoxLayout)
								:width(.30)
								:vgap(7)
								:setVar("padt", 8)
								:add(createUiLabel("TILESET"))
								:beginUi(uiEditBox.tileset)
									:anchorH("center")
									:setVar("onRecieve", onRecieve.tileset)
									:setVar("onSend", onSend.tileset)
									:setCustomTooltip(tooltip.tileset)
									:addList(
										modApi.tileset._children,
										decorate_button.obj,
										onPopupEntryClicked
									)
								:endUi()
							:endUi()
						:endUi()
						:beginUi(UiBoxLayout)
							:heightpx(400)
							:padding(20)
							:vgap(40)
							:format(format_contentListContainer)
							:beginUi(uiEditBox.enemyList)
								:format(format_contentList)
								:setVar("onRecieve", onRecieve.enemyList)
								:setVar("onSend", onSend.enemyList)
								:addList(
									modApi.enemyList._children,
									staticContentList,
									onPopupEntryClicked
								)
							:endUi()
							:beginUi(uiEditBox.missionList)
								:format(format_contentList)
								:setVar("onRecieve", onRecieve.missionList)
								:setVar("onSend", onSend.missionList)
								:addList(
									modApi.missionList._children,
									staticContentList,
									onPopupEntryClicked
								)
							:endUi()
							:beginUi(uiEditBox.bossList)
								:format(format_contentList)
								:setVar("onRecieve", onRecieve.bossList)
								:setVar("onSend", onSend.bossList)
								:addList(
									modApi.bossList._children,
									staticContentList,
									onPopupEntryClicked
								)
							:endUi()
							:beginUi(uiEditBox.structureList)
								:format(format_contentList)
								:setVar("onRecieve", onRecieve.structureList)
								:setVar("onSend", onSend.structureList)
								:addList(
									modApi.structureList._children,
									staticContentList,
									onPopupEntryClicked
								)
							:endUi()
						:endUi()
					:endUi()
				:endUi()
			:endUi()
		:endUi()

	local islands_sorted = to_sorted_array(modApi.islandComposite._children, sortLessThan)

	-- populate island list
	for _, islandComposite in ipairs(islands_sorted) do
		local scrollarea = islandList.parent
		local decorations = decorate_button.islandComposite(nil, islandComposite)
		decorations[1] = DecoEditorButton()
		local entry = UiEditorButton(scrollarea)
			:widthpx(icon_island_width)
			:heightpx(icon_island_height)
			:setVar("data", islandComposite)
			:decorate(decorations)
			:setCustomTooltip(tooltip_islandComposite)
			:addTo(islandList)

	end

	local function onEditorButtonSet(widget)
		if widget then
			currentContent:show()
			for _, ui in pairs(uiEditBox) do
				ui:recieve()
			end
		else
			currentContent:hide()
			uiEditBox.id:updateText("Selected Island")
		end
	end

	easyEdit.events.onEditorButtonSet:unsubscribeAll()
	easyEdit.events.onEditorButtonSet:subscribe(onEditorButtonSet)

	return content
end

local function buildFrameButtons(buttonLayout)

	sdlext.buildButton(
		"Default",
		"Reset everything to default\n\nWARNING: This will delete all custom islands",
		resetAll
 	):addTo(buttonLayout)

	sdlext.buildButton(
		"Reset",
		"Reset currently selected island",
		reset
 	):addTo(buttonLayout)
end

local function onExit()
	UiEditorButton:resetGlobalVariables()

	modApi.islandComposite:save()
end

function islandEditor.mainButton()
	UiEditorButton:resetGlobalVariables()

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

return islandEditor
