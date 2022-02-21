
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
-- changed widthpx
-- changed heightpx
-- added sizepx
-- added containChildren
-- added beginUi
-- added endUi
-- added resizeOnce
-- added setVar
-- added format
-- added getDebugName
-- added setDebugName
-- added debug names to known ui elements in UiRoot
-- added updateFrozenSizeState
-- added updateDragHoverState
-- added onGameWindowResized
-- added gameWindowResized
-- added isTooltipUi
-- changed updateTooltipState
-- added enumerateAncestors
-- added enumerateDescendents
-- added findDescendentWhere
-- added findAncestorWhere
-- added isDescendentOf
-- added isAncestorOf
-- added setGroupOwner
-- added getGroupOwner
-- added getDragSourceType
-- added setCustomTooltip
-- added addDeco
-- added replaceDeco
-- added insertDeco
-- added removeDeco
-- added compact

-- UiRoot
-- added setDragHoveredChild
-- extended updateStates
-- changed relayoutDragDropPriorityUi
-- changed relayoutTooltipUi

-- UiTooltip
-- added isTooltipui

local old_ui_new = Ui.new
function Ui:new(...)
	old_ui_new(self, ...)
	self.wPercent = 1
	self.hPercent = 1
end

function Ui:widthpx(w)
	self.w = w
	self.wPercent = nil
	return self
end

function Ui:heightpx(h)
	self.h = h
	self.hPercent = nil
	return self
end

function Ui:sizepx(w, h)
	self.w = w
	self.h = h
	self.wPercent = nil
	self.hPercent = nil
	return self
end

-- Limits children's width/height to be contained
-- within parent ui element
function Ui:containChildren(containChildren)
	local noFit = containChildren == false or nil

	self.nofitx = noFit
	self.nofity = noFit

	return self
end

-- Adds a ui instance of class 'class' (or Ui if nil)
-- to itself, and returns the new ui instance.
-- Intended to be used in function chaining when
-- setting up the Ui hierarchy.
function Ui:beginUi(class)
	if class == nil then
		class = Ui
	end

	if Class.instanceOf(class, class.__index) then
		-- if 'class' is a ui instance
		return class:addTo(self)
	elseif Class.isSubclassOf(class, Ui) then
		-- if 'class' is a ui class
		return class():addTo(self)
	end

	Assert.True(false, "Invalid Argument #1")
end

-- Ends the current Ui instance when function chaining;
-- returning its parent.
function Ui:endUi()
	return self.parent
end

-- Freezes the size of the Ui instance after the first
-- update
function Ui:resizeOnce()
	self.freezeSize = true
	return self
end

-- Sets a variable in the table to the given value
function Ui:setVar(var, value)
	self[var] = value
	return self
end

function Ui:format(fn)
	fn(self)
	return self
end

function Ui:getDebugName()
	return self._debugName or "nonameUi"
end

function Ui:setDebugName(debugName)
	self._debugName = debugName
	return self
end

modApi.events.onUiRootCreated:subscribe(function(screen, root)
	root:setDebugName("UiRoot")
	root.priorityUi:setDebugName("priorityUi")
	root.tooltipUi:setDebugName("tooltipUi")
	root.draggableUi:setDebugName("draggableUi")
	root.dropdownUi:setDebugName("dropdownUi")
end)

function UiRoot:setDragHoveredChild(child)
	if self.draghoveredchild then
		self.draghoveredchild.dragHovered = false
	end

	self.draghoveredchild = child

	if child then
		child.dragHovered = true
	end
end

function Ui:updateFrozenSizeState()
	local isDynamicSize = false
		or self.wPercent ~= nil
		or self.hPercent ~= nil

	local isFreezeSize = true
		and isDynamicSize == true
		and self.freezeSize == true
		and self.w > 0
		and self.h > 0

	if isFreezeSize then
		self.wPercent = nil
		self.hPercent = nil
		self.freezeSize = nil
	end

	for _, child in ipairs(self.children) do
		child:updateFrozenSizeState()
	end
end


-- New terms:
-- UiRoot.draghoveredchild
-- Ui.dragHovered
--
-- While dragging a ui element, UiRoot.hoveredchild
-- will be fixed to this element, and no other
-- elements can be hovered.
-- This update step enumerates every ui element,
-- so that any ui elements other than the one being
-- dragged can be identified as the
-- 'UiRoot.draghoveredchild'. This element will also
-- be flagged as 'dragHovered'
-- 'dragHovered' will be kept up to date regardless
-- if any element is dragged or not.
function Ui:updateDragHoverState()
	local root = self.root
	if root == self then
		root:setDragHoveredChild(nil)
	end

	local exit = false
		or root == nil
		or self.visible ~= true
		or self.ignoreMouse == true
		or self.containsMouse ~= true

	if exit then
		return false
	end

	if root.draggedchild ~= self then
		if self.translucent ~= true then
			root:setDragHoveredChild(self)
		end

		for _, child in ipairs(self.children) do
			if child:updateDragHoverState() then
				return true
			end
		end
	end

	return self.dragHovered
end

-- Adds more steps to the update phase of uiRoot.
old_UiRoot_updateStates = UiRoot.updateStates
function UiRoot:updateStates()
	old_UiRoot_updateStates(self)

	self:updateFrozenSizeState()
	self:updateDragHoverState()
end

function Ui:onGameWindowResized(screen, oldSize)
	-- overridable method
end

function Ui:gameWindowResized(screen, oldSize)
	self:onGameWindowResized(screen, oldSize)

	for _, child in ipairs(self.children) do
		child:gameWindowResized(screen, oldSize)
	end
end

-- The UiTooltip object in the UiRoot object
-- changes its size without the use of widthpx
-- and heightpx, altering w and h directly.
-- wPercent and hPercent must be nil for this
-- to work.
modApi.events.onUiRootCreated:subscribe(function(screen, root)
	root.tooltipUi.wPercent = nil
	root.tooltipUi.hPercent = nil
end)

-- UiWrappedText adjusts its size with widthpx
-- and heightpx internally.
-- wPercent and hPercent must be nil for this
-- to work.
local old_UiWrappedText_new = UiWrappedText.new
function UiWrappedText:new(...)
	old_UiWrappedText_new(self, ...)
	self.wPercent = nil
	self.hPercent = nil
end

modApi.events.onGameWindowResized:subscribe(function(screen, oldSize)
	sdlext:getUiRoot():gameWindowResized(screen, oldSize)
end)

-- Make it possible to identify tooltip ui
-- unambiguously.
function Ui:isTooltipUi()
	return false
end
function UiTooltip:isTooltipUi()
	return true
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


-- Enumerates all ancestors (including itself)
-- and calls the function 'func(uiElement)', for
-- each ancestor.
--
-- Search depth can be specified.
-- A depth of 0 only queries itself.
-- A depth of 1 queries itself and its parent.
-- A depth of 2 queries itself, its parent and
-- its grand parent.
-- etc.
function Ui:enumerateAncestors(func, depth)
	depth = depth or INT_MAX

	func(self)

	if depth > 0 then
		depth = depth - 1
		if self.parent then
			self.parent:enumerateAncestors(func, depth)
		end
	end
end

-- Enumerates all descendents (including itself)
-- and calls the function 'func(uiElement)', for
-- each descendent.
--
-- Search depth can be specified.
-- A depth of 0 only queries itself.
-- A depth of 1 queries itself and its children.
-- A depth of 2 queries itself, its children and
-- its grand children.
-- etc.
function Ui:enumerateDescendents(func, depth)
	depth = depth or INT_MAX

	func(self)

	if depth > 0 then
		depth = depth - 1
		for _, child in ipairs(self.children) do
			child:enumerateDescendents(func, depth)
		end
	end
end

-- Returns true if _any_ descendent (including
-- itself) returns true for the function
-- 'bool predicate(uiElement)'
-- Returns false otherwise.
--
-- Search depth can be specified.
-- A depth of 0 only queries itself.
-- A depth of 1 queries itself and its parent.
-- A depth of 2 queries itself, its parent and
-- its grand parent.
-- etc.
function Ui:findDescendentWhere(predicate, depth)
	depth = depth or INT_MAX

	if predicate(self) then
		return true
	end

	if depth > 0 then
		depth = depth - 1
		for _, child in ipairs(self.children) do
			if child:findDescendentWhere(predicate, depth) then
				return true
			end
		end
	end

	return false
end

-- Returns true if _any_ ancestor (including
-- itself) returns true for the function
-- 'bool predicate(uiElement)'
-- Returns false otherwise.
--
-- Search depth can be specified.
-- A depth of 0 only queries itself.
-- A depth of 1 queries itself and its children.
-- A depth of 2 queries itself, its children and
-- its grand children.
-- etc.
function Ui:findAncestorWhere(predicate, depth)
	depth = depth or INT_MAX

	if predicate(self) then
		return true
	end

	if depth > 0 then
		depth = depth - 1
		for _, child in ipairs(self.children) do
			if child:findAncestorWhere(predicate, depth) then
				return true
			end
		end
	end

	return false
end

function Ui:isDescendentOf(ancestor)
	return self:findAncestorWhere(function(element)
		return element == ancestor
	end)
end

function Ui:isAncestorOf(descendent)
	return self:findDescendentWhere(function(element)
		return element == descendent
	end)
end

function Ui:setGroupOwner(groupOwner)
	self.groupOwner = groupOwner
	return self
end

function Ui:getGroupOwner()
	return self.groupOwner or self
end

-- A drag source can initiate drag objects.
function Ui:getDragSourceType()
	return self.dragSourceType
end

-- A drag object is a draggable object
-- which will react to hovering drop targets
-- of the same type.
function Ui:getDragObjectType()
	return self.dragObjectType
end

-- A drop target is an object that will
-- react to drag objects hovering it.
function Ui:getDropTargetType()
	return self.dropTargetType
end

function Ui:setCustomTooltip(ui)
	Assert.True(Ui.instanceOf(ui, Ui), "Argument #1")
	self.customTooltip = ui
	return self
end

function Ui:addDeco(decoration)
	self:insertDeco(#self.decorations + 1)

	return self
end

function Ui:replaceDeco(index, decoration)
	self:removeDeco(index)
	self:insertDeco(index, decoration)

	return self
end

function Ui:insertDeco(index, decoration)
	local decorations = self.decorations
	if index < 1 or index > #decorations + 1 then
		index = #decorations + 1
	end

	if decoration then
		table.insert(decorations, decoration)
		decoration:apply(self)
	end

	return self
end

function Ui:removeDeco(index)
	local decorations = self.decorations
	local decoration = decorations[index]

	if decoration then
		table.remove(decorations, index)
		decoration:unapply(self)
	end

	return self
end

-- Adjust UiRoot. Make it so anything added to
-- priorityUi only relays out once per update.
local tooltipUis = {}
local otherUis = {}
function UiRoot:relayoutDragDropPriorityUi()
	clear_table(tooltipUis)
	clear_table(otherUis)

	for _, child in ipairs(self.priorityUi.children) do
		if child:isTooltipUi() then
			tooltipUis[#tooltipUis+1] = child
			child.visible = false
		else
			otherUis[#otherUis+1] = child
			child.visible = true
		end
	end

	self.priorityUi:relayout()

	for _, child in ipairs(tooltipUis) do
		child.visible = true
	end
end

function UiRoot:relayoutTooltipUi()
	for _, child in ipairs(otherUis) do
		child.visible = false
	end

	self.priorityUi:relayout()

	for _, child in ipairs(otherUis) do
		child.visible = true
	end
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
