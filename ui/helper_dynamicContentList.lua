
local path = GetParentPath(...)
local helpers = require(path.."helpers")
local tooltip = require(path.."helper_tooltip")
local DecoObj = require(path.."deco/DecoObj")
local DecoBounceLabel = require(path.."deco/DecoBounceLabel")
local UiDragSource = require(path.."widget/UiDragSource")
local UiScrollAreaExt = require(path.."widget/UiScrollAreaExt")
local UiScrollAreaH = UiScrollAreaExt.horizontal

local onGroupClicked = helpers.onGroupClicked
local findUiInListAt = helpers.findUiInListAt
local createDecoGroupButtonDropTarget = helpers.createDecoGroupButtonDropTarget

local OBJECT_LIST_HEIGHT = helpers.OBJECT_LIST_HEIGHT
local FONT_TITLE = helpers.FONT_TITLE
local TEXT_SETTINGS_TITLE = helpers.TEXT_SETTINGS_TITLE

local function updatePadding(self)
	if #self.children == 0 then
		self.padl = 0
		self.padr = 0
	else
		local first = self.children[1]
		local last = last_entry(self.children)
		self.padl = first.decorations[1].surface:w() / 2 - 25
		self.padr = last.decorations[1].surface:w() / 2 - 25
	end
end

local function addCategory(self, categoryId)
	categoryLabel = categoryId:upper()..":"

	local decoText = DecoText(categoryLabel, FONT_LABEL, TEXT_SETTINGS_LABEL)
	local labelWidth = sdlext.totalWidth(decoText.surface)
	local category = UiBoxLayout()

	self.categories[categoryId] = category
	self.contentList
		:beginUi(UiBoxLayout)
			:width(nil)
			:hgap(0)
			:beginUi()
				:setDebugName("label_"..tostring(categoryId))
				:widthpx(labelWidth)
				:decorate{ decoText }
			:endUi()
			:beginUi(category)
				:setDebugName("objectList_"..tostring(categoryId))
				:width(nil)
				:hgap(0)
				:setVar("nofitx", false)
				:setVar("nofity", false)
				:setVar("updatePadding", updatePadding)
			:endUi()
		:endUi()

	return category
end

local function updatePosition(self, x)
	local exit = false
		or self.parent == nil

	if exit then return end

	local parent = self.parent
	local children = parent.children
	local indexof = list_indexof(children, self)
	local index = BinarySearchMax(1, #children, x, function(i)
		return children[i].screenx
	end)

	local groupOwner = self:getGroupOwner()
	local scrollarea = groupOwner.scrollarea
	local target = children[index]

	if self.screenx ~= 0 then
		scrollarea:scrollToContain(self.screenx - self.w, self.w * 3)
	end

	children[index], children[indexof] = children[indexof], children[index]
	parent:updatePadding()
end

local function addObject(self, obj, categoryId, x)
	local category

	if categoryId then
		category = self.categories[categoryId]
	else
		categoryId, category = findUiInListAt(self.categories, x)
	end

	if categoryId == nil or category == nil then
		Assert.Error("No category")
	end

	local icon
	local index
	local children = category.children

	icon = DecoObj(obj, obj:getIconDef())

	local ui = UiDragSource(self.dragObject)
		:widthpx(50)
		:heightpx(50)
		:decorate{ icon }
		:setCustomTooltip(tooltip.get(obj))

	ui.data = obj
	ui.groupOwner = self
	ui.categoryId = categoryId
	ui.updatePosition = updatePosition
	ui.onclicked = onGroupClicked

	if x then
		local last = children[#children]
		if last == nil then
			index = 1
		elseif x > last.screenx + last.w then
			index = #children + 1
		else
			index = BinarySearchMax(1, #children, x, function(i)
				return children[i].screenx
			end)
		end
	end

	category:add(ui, index)
	category:updatePadding()

	return ui
end

local function decorate_contentList(ui, objList)
	ui.data = objList
	ui.categories = {}
	ui.addCategory = addCategory
	ui.addObject = addObject

	if ui.contentList then
		ui.contentList:detach()
	end

	ui.contentList = UiBoxLayout()
		:width(nil)
		:hgap(0)
		:setVar("nofitx", false)
		:setVar("nofity", false)

	local function addContent(categoryId, category)
		local exit = false
			or category == nil
			or categoryId == nil

		if exit then return end

		if ui.categories[categoryId] == nil then
			ui:addCategory(categoryId)
		end

		for i, objId in ipairs(category) do
			local obj

			if objList:instanceOf(modApi.enemyList._class) then
				obj = modApi.units:get(objId.."1")

			-- elseif objList:instanceOf(modApi.bossList._class) then
				-- obj = modApi.missions:get(objId)
				-- local mission = modApi.missions:get(objId)
				-- obj = modApi.units:get(mission.BossPawn)
			else
				obj = objList:getObject(objId)
			end

			if obj == nil then
				Assert.Error("No object with id "..tostring(objId))
			end

			ui:addObject(obj, categoryId)
		end
	end

	enumerate_table(objList:getCategories(), addContent)

	if #ui.children == 0 then
		ui.label = Ui()
		ui.scrollarea = UiScrollAreaH()

		ui
			:heightpx(OBJECT_LIST_HEIGHT)
			:decorate{ createDecoGroupButtonDropTarget() }
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
					:padding(5)
				:endUi()
				:setTranslucent(true, true)
			:endUi()
	end

	ui.scrollarea
		:add(ui.contentList)

	ui.label
		:decorate{ DecoBounceLabel(objList._id, FONT_TITLE, TEXT_SETTINGS_TITLE, "center") }

	ui:enumerateDescendents(function(child)
		child.groupOwner = ui

		if child ~= ui then
			child.onclicked = onGroupClicked
		end
	end)

	return true
end

return decorate_contentList
