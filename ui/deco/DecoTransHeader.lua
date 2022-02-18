
-- defs
local LABEL_HEIGHT = 19

local DecoTransHeader = Class.inherit(UiDeco)
local rect = sdl.rect(0,0,0,0)

function DecoTransHeader:new(height)
	UiDeco.new(self)

	self.color = deco.colors.halfblack
	self.height = height or LABEL_HEIGHT
end

function DecoTransHeader:draw(screen, widget)
	local r = widget.rect
	local padr = widget.padr
	local padl = widget.padl
	local padt = widget.padt
	local padb = widget.padb

	rect.x = r.x + padr
	rect.y = r.y + padt
	rect.w = r.w - padr - padl
	rect.h = math.min(r.h - padt - padb, self.height)

	screen:drawrect(self.color, rect)
end

return DecoTransHeader
