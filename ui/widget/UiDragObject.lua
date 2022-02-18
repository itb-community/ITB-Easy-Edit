
local UiDragObject = Class.inherit(Ui)

function UiDragObject:new(dragObjectType)
	Ui.new(self)

	self._debugName = "UiDragObject"
	self.draggable = true
	self.dragObjectType = dragObjectType or "UNDEFINED_TYPE"
	self:hide()
end

function UiDragObject:getDragType()
	return self.dragObjectType
end

function UiDragObject:onDragSourceGrabbed(dragSource)
	-- overridable method
end

function UiDragObject:onDropTargetDropped(dropTarget)
	-- overridable method
end

function UiDragObject:onDropTargetExited(dropTarget)
	-- overridable method
end

function UiDragObject:onDropTargetEntered(dropTarget)
	-- overridable method
end

function UiDragObject:processDropTargets()
	local dropped = false
		or self.root == nil
		or self.visible == false
		or self.dragged == false

	if dropped then
		local dropTarget = self.dropTarget

		if dropTarget then
			if dropTarget.onDragObjectDropped then
				dropTarget:onDragObjectDropped(self)
			end

			self:onDropTargetDropped(dropTarget)
			self.dropTarget = nil
		end

		return
	end

	local root = self.root
	local hoveredChild = root.draghoveredchild
	local old_dropTarget = self.dropTarget
	local new_dropTarget

	-- Only consider targets with dropTargetType
	-- equal to this element's dragObjectType.
	if hoveredChild then
		local target = hoveredChild:getGroupOwner()
		if target:getDropTargetType() == self:getDragObjectType() then
			new_dropTarget = target
		end
	end

	if old_dropTarget and new_dropTarget ~= old_dropTarget then

		self.dropTarget = new_dropTarget

		if old_dropTarget.onDragObjectExited then
			old_dropTarget:onDragObjectExited(self)
		end

		self:onDropTargetExited(old_dropTarget)
	end

	if new_dropTarget and new_dropTarget ~= old_dropTarget then

		self.dropTarget = new_dropTarget

		if new_dropTarget.onDragObjectEntered then
			new_dropTarget:onDragObjectEntered(self)
		end

		self:onDropTargetEntered(new_dropTarget)
	end
end

function UiDragObject:startDrag(mx, my)
	self.dragX = mx
	self.dragY = my

	self:addTo(sdlext.getUiRoot().draggableUi)
	self:show()
	self:setfocus()

	self:onDragSourceGrabbed(self.dragSource)
	self:processDropTargets()
end

function UiDragObject:stopDrag(mx, my)
	self:detach()
	self:hide()
	self:processDropTargets()
end

function UiDragObject:dragWheel()
	self:processDropTargets()
	return false
end

function UiDragObject:wheel()
	return false
end

function UiDragObject:dragMove(mx, my)
	local diffx = mx - self.dragX
	local diffy = my - self.dragY
	self.x = self.x + diffx
	self.y = self.y + diffy
	self.screenx = self.screenx + diffx
	self.screeny = self.screeny + diffy
	self.dragX = mx
	self.dragY = my

	self:processDropTargets()
end

function UiDragObject:keydown(keycode)
	if keycode == SDLKeycodes.ESCAPE then
		self.root:setPressedChild(nil)
		self.root:setDraggedChild(nil)
		self:processDropTargets()
	end

	return true
end

return UiDragObject
