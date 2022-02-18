
local DecoEditorObject = Class.inherit(DecoButton)

function DecoEditorObject:draw(screen, widget)
	if easyEdit.selectedEditorButton == widget then
		local color = self.color
		local bordercolor = self.bordercolor
		self.color = self.hlcolor
		self.bordercolor = self.borderhlcolor

		DecoButton.draw(self, screen, widget)

		self.color = color
		self.bordercolor = bordercolor
	else
		DecoButton.draw(self, screen, widget)
	end
end

return DecoEditorObject
