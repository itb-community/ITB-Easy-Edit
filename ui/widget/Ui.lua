
-- Changes to Ui Class
-- Targets mod loader v2.6.4

-- The mod loader's Ui Class defaults to
-- being of size 0,0.
-- Rarely is this desired, and a lot of
-- Ui object start by inheriting the size
-- of the parent ui element.

-- This file changes the default behavior
-- of the Ui Class to inherit the size of
-- its parent by default, by setting both
-- wPercent and hPercent to 1.

-- In order to leave the option to set
-- fixed values with widthpx and
-- heightpx, these functions will now
-- clear wPercent and hPercent,
-- respectively.

-- Ui
-- added updateGroupHoverState
-- extended updateTooltipState
-- added setGroupOwner
-- added getGroupOwner
-- added isGroupHovered
-- added isGroupDragHovered
-- added compact
-- added makeCullable

-- UiRoot
-- extended updateStates

function Ui:updateGroupHoverState()
	self.groupHovered = false
	self.groupDragHovered = false

	if self.hovered then
		self:getGroupOwner().groupHovered = true
	end

	if self.dragHovered then
		self:getGroupOwner().groupDragHovered = true
	end

	for _, child in ipairs(self.children) do
		child:updateGroupHoverState()
	end
end

-- Adds more steps to the update phase of uiRoot.
old_UiRoot_updateStates = UiRoot.updateStates
function UiRoot:updateStates()
	old_UiRoot_updateStates(self)

	self:updateGroupHoverState()
end

-- Adjust Ui.updateTooltipState to take into account
-- tooltips which explicitly set tooltip_static
local old_Ui_updateTooltipState = Ui.updateTooltipState
function Ui:updateTooltipState()
	if old_Ui_updateTooltipState(self) then return end

	if self.tooltip_static then
		self.root.tooltip_static = self.tooltip_static
	else
		self.root.tooltip_static = self.draggable and self.dragged
	end
end

function Ui:setGroupOwner(groupOwner)
	self.groupOwner = groupOwner
	return self
end

function Ui:getGroupOwner()
	return self.groupOwner or self
end

function Ui:isGroupHovered()
	return self:getGroupOwner().groupHovered
end

function Ui:isGroupDragHovered()
	return self:getGroupOwner().groupDragHovered
end

-- Ui.crop does much the same as UiWeightLayout.compact
-- Syncronize names.
function Ui:crop(flag)
	if flag == nil then flag = true end

	self.isCompact = flag
	self.cropped = flag

	return self
end

Ui.compact = Ui.crop

local function relayoutCullable(self)
	self._nocull = self.parent.rect:intersects(self.rect)

	if self._nocull then
		self:_relayout()
	end
end

local function drawCullable(self, screen)
	if self._nocull then
		self:_draw(screen)
	end
end

-- Make ui element cullable by wrapping its
-- relayout and draw functions in a function
-- which checks whether the element intersects
-- its parent. This can be reversed by setting
-- self.relayout = self._relayout
-- self.draw = self._draw
function Ui:makeCullable()
	self._relayout = self.relayout
	self._draw = self.draw
	self.relayout = relayoutCullable
	self.draw = drawCullable

	return self
end
