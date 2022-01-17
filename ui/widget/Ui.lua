
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

-- sizepx has also been added.

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
