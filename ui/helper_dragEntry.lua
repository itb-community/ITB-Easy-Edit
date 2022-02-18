
-- header
local path = GetParentPath(...)
local helpers = require(path.."helpers")
local findKeyOfListInParentTable = helpers.findKeyOfListInParentTable
local findUiInListAt = helpers.findUiInListAt
local DecoObj = require(path.."deco/DecoObj")
local UiDragObject = require(path.."widget/UiDragObject")

local function getSaveId(obj)
	local id = obj._id

	if obj:instanceOf(modApi.units._class) then
		if obj:isEnemy() or obj:isBot() then
			if type(tonumber(id:sub(-1,-1))) == 'number' then
				id = id:sub(1,-2)
			end
		end
	end

	return id
end

local function addSaveEntry(ui)

	local obj = ui.data
	local categoryId = ui.categoryId
	local groupOwner = ui:getGroupOwner()
	local objList = groupOwner.data
	local saveId = getSaveId(obj)
	local saveCategories = objList:getCategories()

	table.insert(saveCategories[categoryId], saveId)
end

local function remSaveEntry(ui)

	local obj = ui.data
	local categoryId = ui.categoryId
	local groupOwner = ui:getGroupOwner()
	local objList = groupOwner.data
	local saveId = getSaveId(obj)
	local saveCategories = objList:getCategories()

	remove_element(saveId, saveCategories[categoryId])
end

-- class
local DragEntry = Class.inherit(UiDragObject)

function DragEntry:new(indexedEntryType)
	Assert.Equals(true, IndexedList.instanceOf(indexedEntryType, IndexedList), "Argument #1")

	UiDragObject.new(self, indexedEntryType:getDragType())

	self
		:widthpx(indexedEntryType:getIconDef().width)
		:heightpx(indexedEntryType:getIconDef().height)
end

function DragEntry:onDragSourceGrabbed(dragSource)
	local obj = dragSource.data

	self.dragX = dragSource.screenx + dragSource.w / 2 - 40
	self.dragY = dragSource.screeny + dragSource.h / 2 - 50

	local dragObjectType = self:getGroupOwner().dragObjectType
	local dropTargetType = dragSource:getGroupOwner().dropTargetType
	if dragObjectType == dropTargetType then
		self.dropTarget = dragSource:getGroupOwner()
		self.droppedObject = dragSource
	end

	self.data = obj
	self:decorate{ DecoObj(obj, obj:getIconDef()) }
end

function DragEntry:onDropTargetDropped(dropTarget)
	self.droppedObject = nil
end

function DragEntry:onDropTargetEntered(dropTarget)
	if self.droppedObject ~= nil then
		return
	end

	local mouse_x = sdl.mouse.x()
	local obj = self.data
	local categoryId = obj:getCategory()

	if categoryId == nil then
		categoryId = findUiInListAt(dropTarget.categories, mouse_x)
	end

	self.droppedObject = dropTarget:addObject(obj, categoryId, mouse_x)

	addSaveEntry(self.droppedObject)
end

function DragEntry:onDropTargetExited(dropTarget)
	if self.droppedObject == nil then
		return
	end

	remSaveEntry(self.droppedObject)

	local parent = self.droppedObject.parent

	self.droppedObject:detach()
	self.droppedObject = nil

	parent:updatePadding()
end

function DragEntry:dragMove(mx, my)
	local droppedObject = self.droppedObject

	if droppedObject then
		local mouse_x = sdl.mouse.x()
		local obj = droppedObject.data
		local groupOwner = droppedObject:getGroupOwner()
		local categories = groupOwner.categories
		local categoryId_fixed = obj:getCategory()
		local categoryId_current = droppedObject.categoryId
		local categoryId_cursor
		local category_cursor

		if categoryId_fixed == nil then
			categoryId_cursor, category_cursor = findUiInListAt(categories, mouse_x)
		end

		local changeCategory = true
			and categoryId_fixed == nil
			and categoryId_current ~= categoryId_cursor

		if changeCategory then
			remSaveEntry(droppedObject)
			droppedObject:detach()
			droppedObject:addTo(category_cursor)
			droppedObject.categoryId = categoryId_cursor
			addSaveEntry(droppedObject)
		else
			droppedObject:updatePosition(mouse_x)
		end
	end

	UiDragObject.dragMove(self, mx, my)
end

return DragEntry
