
local PALETTE_INDEX_BASE = 1
local clipRect = sdl.rect(0,0,0,0)
local colorMapBase = {}
local basePalette = GetColorMap(PALETTE_INDEX_BASE)
for i, gl_color in ipairs(basePalette) do
	local rgb = sdl.rgb(gl_color.r, gl_color.g, gl_color.b)
	colorMapBase[i*2-1] = rgb
	colorMapBase[i*2] = rgb
end

local function buildSdlColorMap(palette)
	local res = shallow_copy(colorMapBase)

	for i = 1, 8 do
		local gl_color = palette[i]
		if gl_color ~= nil then
			res[i*2] = sdl.rgb(gl_color.r, gl_color.g, gl_color.b)
		end
	end

	return res
end

local DecoUnitImage = Class.inherit(DecoSurfaceAligned)
function DecoUnitImage:new(unit, alignH, alignV, scale)
	Assert.Equals(true, Class.instanceOf(unit, IndexedEntry), "Argument #1")

	DecoSurfaceAligned.new(self)

	self.scale = scale
	self.unit = unit
	self.alignH = alignH
	self.alignV = alignV
	self:updateImage()
end

function DecoUnitImage:updateImage()
	local unit = _G[self.unit._id]

	local imageMissing = false
		or unit.Image == nil
		or ANIMS[unit.Image] == nil

	if imageMissing then
		self.anim = ANIMS["Animation"]
	else
		self.anim = ANIMS[unit.Image]
	end

	local transformations = {
		{ scale = self.scale },
		{ outline = { border = self.scale, color = deco.colors.buttonborder } }
	}

	if self.unit._isMech then
		local palette = modApi:getPalette((unit.ImageOffset + 1) or 1)
		local colormap = buildSdlColorMap(palette.colorMap)
		table.insert(transformations, 1, { colormap = colormap })
	end

	self.surface = sdlext.getSurface{
		path = "img/"..self.anim.Image,
		transformations = transformations,
	}
end

function DecoUnitImage:draw(screen, widget)
	local surface = self.surface
	if surface == nil then return end
	local r = widget.rect
	local alignV = self.alignV
	local alignH = self.alignH
	local unit = self.unit
	local anim = self.anim
	local columns = anim.Frames and #anim.Frames or anim.NumFrames
	local rows = unit._isMech and 1 or anim.Height or 1
	local imageOffset = unit._isMech and 0 or unit.ImageOffset or 0
	local w = math.floor(surface:w() / columns)
	local h = math.floor(surface:h() / rows)
	local x = 0
	local y = 0

	if alignH == "center" then
		x = x + math.floor(r.x + widget.decorationx + r.w / 2 - w / 2)
	elseif alignH == "right" then
		x = x + r.x - widget.decorationx + r.w - w
	else
		x = x + r.x + widget.decorationx
	end

	if alignV == "center" then
		y = y + math.floor(r.y + widget.decorationy + r.h / 2 - h / 2)
	elseif alignV == "bottom" then
		y = y + r.y + widget.decorationy + r.h - h
	else
		y = y + r.y + widget.decorationy
	end

	clipRect.x = x
	clipRect.y = y
	clipRect.w = w
	clipRect.h = h

	local currentClipRect = screen:getClipRect()
	if currentClipRect then
		clipRect = clipRect:getIntersect(currentClipRect)
	end

	screen:clip(clipRect)
	screen:blit(surface, nil, x, y - imageOffset * h)
	screen:unclip()
end

return DecoUnitImage
