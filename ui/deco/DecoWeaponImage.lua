
local DecoWeaponImage = Class.inherit(DecoSurfaceAligned)
function DecoWeaponImage:new(weapon, alignH, alignV, scale)
	Assert.Equals('string', type(weapon), "Argument #1")

	DecoSurfaceAligned.new(self)

	self.scale = scale
	self.weapon = weapon
	self.alignH = alignH
	self.alignV = alignV
	self:updateImage()
end

function DecoWeaponImage:updateImage()
	local weapon = _G[self.weapon]
	local image = weapon.Icon

	if image == nil then
		image = "weapons/skill_default.png"
	end

	local transformations = {
		{ scale = self.scale },
	}

	self.surface = sdlext.getSurface{
		path = "img/"..image,
		transformations = transformations,
	}
end

return DecoWeaponImage
