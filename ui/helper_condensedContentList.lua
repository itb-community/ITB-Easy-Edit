
local path = GetParentPath(...)
local DecoObj = require(path.."deco/DecoObj")
local UiScrollAreaExt = require(path.."widget/UiScrollAreaExt")
local UiScrollAreaH = UiScrollAreaExt.horizontal


local function condensedContentList(ui, objList)
	ui.data = objList._id

	if ui.contentList then
		ui.contentList:detach()
	end

	if objList == nil then
		return
	end

	ui.contentList = Ui()
	local width = 0
	local gap = 25
	local iconDef

	if objList:instanceOf(modApi.enemyList._class) then
		iconDef = modApi.units:getIconDef()
	elseif objList:instanceOf(modApi.bossList._class) then
		iconDef = modApi.units:getIconDef()
	elseif objList:instanceOf(modApi.missionList._class) then
		iconDef = modApi.missions:getIconDef()
	elseif objList:instanceOf(modApi.structureList._class) then
		iconDef = modApi.structures:getIconDef()
	else
		Assert.Error("Not a content list")
	end

	iconDef = copy_table(iconDef)
	iconDef.scale = 1

	local function addContent(label, category)
		local exit = false
			or category == nil
			or #category == 0

		if exit then return end

		ui.contentList
			:setVar("nofitx", false)
			:setVar("nofity", false)

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
				local decoIcon = DecoObj(obj, iconDef)

				ui.contentList
					:beginUi()
						:setxpx(width)
						:widthpx(decoIcon.surface:w())
						:decorate{ decoIcon }
					:endUi()

				width = width + gap
			end
		end
	end

	enumerate_table(objList:getCategories(), addContent)

	if #ui.children == 0 then
		ui.scrollarea = UiScrollAreaH()

		ui
			:heightpx(20)
			:decorate{ DecoFrame() }
			:setVar("padl", 5)
			:setVar("padr", 5)
			:beginUi(ui.scrollarea)
				:setVar("scrollheight", 0)
				:setVar("padb", 0)
			:endUi()
	end

	ui.scrollarea:add(ui.contentList)

	return true
end

return condensedContentList
