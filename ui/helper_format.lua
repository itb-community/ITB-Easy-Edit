
local helpers = {}

function helpers.setIconDef(self, iconDef)
	if iconDef == nil then
		return
	end

	local scale = iconDef.scale or 1
	local width = iconDef.width
	local height = iconDef.height

	if width then
		self:widthpx(width * scale)
	end

	if height then
		self:heightpx(height * scale)
	end
end

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
function helpers.makeCullable(self)
	self._relayout = self.relayout
	self._draw = self.draw
	self.relayout = relayoutCullable
	self.draw = drawCullable
end

return helpers
