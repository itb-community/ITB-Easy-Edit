
local UiEditorButton = Class.inherit(Ui)
function UiEditorButton:new(scrollarea)
	Ui.new(self)
	self._debugName = "UiEditorButton"
	self.scrollarea = scrollarea
end

function UiEditorButton:resetGlobalVariables()
	easyEdit.events.onEditorButtonSet:unsubscribeAll()
	easyEdit.selectedEditorButton = nil
	easyEdit.displayedEditorButton = nil
end

function UiEditorButton:clicked(button)
	easyEdit.selectedEditorButton = self
	Ui.clicked(self, button)

	return true
end

function UiEditorButton:updateState()
	local hovered_prev = self.hovered_prev
	local hovered = self.hovered
	self.hovered_prev = hovered

	local displayedEditorButton = easyEdit.displayedEditorButton
	local selectedEditorButton = easyEdit.selectedEditorButton
	local isDisplayedEditorButtonHovered = true
		and easyEdit.displayedEditorButton
		and easyEdit.displayedEditorButton.hovered

	if hovered ~= hovered_prev then
		if hovered then
			if displayedEditorButton ~= self then
				easyEdit.displayedEditorButton = self
				easyEdit.events.onEditorButtonSet:dispatch(self)
			end
		else
			if not isDisplayedEditorButtonHovered then
				if displayedEditorButton ~= selectedEditorButton then
					easyEdit.displayedEditorButton = selectedEditorButton
					easyEdit.events.onEditorButtonSet:dispatch(selectedEditorButton)
				end
			end
		end
	end

	Ui.updateState(self)
end

function UiEditorButton:relayout()
	local scrollarea = self.scrollarea

	if scrollarea then
		local y = self.screeny
		local h = self.h
		local scroll_y = scrollarea.screeny
		local scroll_h = scrollarea.h

		local cull = false
			or y > scroll_y + scroll_h
			or y + h < scroll_y

		if cull then
			return
		end
	end

	Ui.relayout(self)
end

function UiEditorButton:draw(screen)
	local scrollarea = self.scrollarea

	if scrollarea then
		local y = self.screeny
		local h = self.h
		local scroll_y = scrollarea.screeny
		local scroll_h = scrollarea.h

		local cull = false
			or y > scroll_y + scroll_h
			or y + h < scroll_y

		if cull then
			return
		end
	end

	Ui.draw(self, screen)
end

return UiEditorButton
