
local path = GetParentPath(...)
local helpers = require(path.."helpers")
local tooltip = require(path.."helper_tooltip")
local DecoObj = require(path.."deco/DecoObj")
local UiScrollAreaExt = require(path.."widget/UiScrollAreaExt")
local UiScrollAreaH = UiScrollAreaExt.horizontal
local onGroupClicked = helpers.onGroupClicked
local createDecoGroupButton = helpers.createDecoGroupButton
local isGroupHighlighted = helpers.isGroupHighlighted

local FONT_TITLE = helpers.FONT_TITLE
local TEXT_SETTINGS_TITLE = helpers.TEXT_SETTINGS_TITLE
local FONT_LABEL = helpers.FONT_LABEL
local TEXT_SETTINGS_LABEL = helpers.TEXT_SETTINGS_LABEL

local function staticContentList(ui, objList)
	ui.data = objList._id

	if ui.contentList then
		ui.contentList:detach()
	end

	ui.contentList = Ui()
	local width = 0
	local gap = 50

	local function addContent(label, category)
		local exit = false
			or category == nil
			or #category == 0

		if exit then return end

		if label then
			label = label:upper()..":"
		end

		local deco = DecoText(label, FONT_LABEL, TEXT_SETTINGS_LABEL)
		local labelWidth = sdlext.totalWidth(deco.surface)

		ui.contentList
			:setVar("nofitx", false)
			:setVar("nofity", false)
			:beginUi()
				:setxpx(width)
				:widthpx(labelWidth)
				:decorate{ deco }
			:endUi()

		width = width + labelWidth

		for i, objId in ipairs(category) do
			local obj

			if objList:instanceOf(modApi.enemyList._class) then
				obj = modApi.units:get(objId.."1")

			elseif objList:instanceOf(modApi.bossList._class) then
				local mission = modApi.missions:get(objId)
				obj = modApi.units:get(mission.BossPawn)

			else
				obj = objList:getObject(objId)
			end

			if obj then
				local icon = DecoObj(obj, obj:getIconDef())

				icon.isHighlighted = isGroupHighlighted

				ui.contentList
					:beginUi()
						:setxpx(width)
						:widthpx(icon.surface:w())
						:decorate{ icon }
						:setVar("data", obj)
						:setCustomTooltip(tooltip.get(obj))
					:endUi()

				if i == #category then
					width = width + icon.surface:w() - gap
				end

				width = width + gap
			end
		end
	end

	enumerate_table(objList:getCategories(), addContent)

	if #ui.children == 0 then
		ui.label = Ui()
		ui.scrollarea = UiScrollAreaH()

		ui
			:heightpx(40)
			:decorate{ createDecoGroupButton() }
			:padding(-5)
			:setVar("padl", 5)
			:beginUi(UiWeightLayout)
				:width(1)
				:height(1)
				:beginUi(ui.scrollarea)
					:setVar("scrollheight", 0)
					:setVar("padb", 0)
				:endUi()
				:beginUi(ui.label)
					:widthpx(200)
				:endUi()
				:setTranslucent(true, true)
			:endUi()
	end

	ui.scrollarea
		:beginUi(ui.contentList)
			:widthpx(width)
		:endUi()

	ui.label
		:decorate{ DecoAlignedText(objList._id, FONT_TITLE, TEXT_SETTINGS_TITLE, "center", "center") }

	ui:enumerateDescendents(function(child)
		child.groupOwner = ui

		if child ~= ui then
			child.onclicked = onGroupClicked
		end
	end)

	return true
end

return staticContentList
