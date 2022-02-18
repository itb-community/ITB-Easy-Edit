
local DecoMultiClickButton = Class.inherit(DecoSurfaceAligned)

function DecoMultiClickButton:new(surfaces, alignH, alignV)
	DecoSurfaceAligned.new(self, surfaces[1], alignH, alignV)

	self.surfaces = shallow_copy(surfaces)
end

function DecoMultiClickButton:draw(screen, widget)
	local index = (widget.clickCount or 0) + 1
	self.surface = self.surfaces[index]

	DecoSurfaceAligned.draw(self, screen, widget)
end

return DecoMultiClickButton
