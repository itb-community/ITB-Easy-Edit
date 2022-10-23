
local path = GetParentPath(...)

local UiNumberBox = Class.inherit(UiInputField)

function UiNumberBox:new(minValue, maxValue)
	UiInputField.new(self)

	self.minValue = minValue
	self.maxValue = maxValue
end

function UiNumberBox:init()
	UiInputField.init(self)
	self.alphabet = self._ALPHABET_NUMBERS
end

function UiNumberBox:setText(text)
	local value = tonumber(text)

	if value < self.minValue then
		self:setText(tostring(self.minValue))
	elseif value > self.maxValue then
		self:setText(tostring(self.maxValue))
	else
		UiInputField.setText(self, text)
	end
end

function UiNumberBox:addText(input)
	UiInputField.addText(self, input)

	local value = tonumber(self.textfield)
	if value < self.minValue then
		self:setText(tostring(self.minValue))
	elseif value > self.maxValue then
		self:setText(tostring(self.maxValue))
	end
end

return UiNumberBox
