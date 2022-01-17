
local DecoButtonExt = Class.inherit(DecoButton)
function DecoButtonExt:new(...)
	DecoButton.new(self, ...)
end

function DecoButtonExt:draw(screen, widget)
	if widget.disabled then
		local bordercolor = self.bordercolor
		local borderhlcolor = self.borderhlcolor
		self.bordercolor = self.disabledcolor
		self.borderhlcolor = self.disabledcolor

		DecoButton.draw(self, screen, widget)

		self.bordercolor = bordercolor
		self.borderhlcolor = borderhlcolor
	else
		DecoButton.draw(self, screen, widget)
	end
end

return DecoButtonExt
