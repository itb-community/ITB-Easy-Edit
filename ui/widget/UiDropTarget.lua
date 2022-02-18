
local UiDropTarget = Class.inherit(Ui)

function UiDropTarget:new(dropTargetType)
	Ui.new(self)

	self._debugName = "UiDropTarget"
	self.dropTargetType = dropTargetType
end

function UiDropTarget:getDragType()
	return self.dropTargetType
end

function UiDropTarget:onDragObjectDropped(dragObject)
	-- overridable method
end

function UiDropTarget:onDragObjectEntered(dragObject)
	-- overridable method
end

function UiDropTarget:onDragObjectExited(dragObject)
	-- overridable method
end

return UiDropTarget
