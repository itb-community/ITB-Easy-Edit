
-- header
local path = GetParentPath(...)
local path_prev = GetParentPath(path)
local UiDragObject = require(path.."UiDragObject")
local DecoIcon = require(path_prev.."deco/DecoIcon")

-- defs
local ISLAND_ICON_DEF = modApi.island:getIconDef()
local ISLAND_ICON_DEF_OUTLINED = copy_table(modApi.island:getIconDef())
ISLAND_ICON_DEF_OUTLINED.outlinesize = 2


local UiDragObject_Island = Class.inherit(UiDragObject)

function UiDragObject_Island:new(...)
	UiDragObject.new(self, ...)
	self:size(nil, nil)
end

function UiDragObject_Island:onDropTargetDropped(dropTarget)
	local islandComposite = self.data

	dropTarget.data = islandComposite
end

function UiDragObject_Island:onDropTargetExited(dropTarget)
	local islandComposite = dropTarget.data
	local island = modApi.island:get(islandComposite.island)

	dropTarget:decorate{
		DecoIcon(island, ISLAND_ICON_DEF_OUTLINED)
	}
end

function UiDragObject_Island:onDropTargetEntered(dropTarget)
	local islandComposite = self.data
	local island = modApi.island:get(islandComposite.island)

	dropTarget:decorate{
		DecoIcon(island, ISLAND_ICON_DEF_OUTLINED)
	}
end

function UiDragObject_Island:onDragSourceGrabbed(dragSource)
	local obj = dragSource.data
	local islandId = obj.island
	local island = modApi.island:get(islandId)
	local decoIcon = DecoIcon(island, ISLAND_ICON_DEF)

	self:sizepx(decoIcon.surface:w(), decoIcon.surface:h())
	self.x = dragSource.screenx + math.floor((dragSource.w - self.w) / 2)
	self.y = dragSource.screeny + math.floor((dragSource.h - self.h) / 2)

	self.data = obj
	self:decorate{ decoIcon }
end

return UiDragObject_Island
