
modApi:appendAsset("img/units/nullUnit.png", "resources/mods/game/img/placeholders/mech.png")

local keys = {}
for key, _ in pairs(Pawn) do
	local addKey = true
		and key ~= "new"
		and key:find("^_") == nil
		and key:find("^Get") == nil

	if addKey then
		keys[#keys+1] = key
	end
end

local Unit = Class.inherit(IndexedEntry)
Unit._debugName = "Unit"
Unit._entryType = "units"
Unit._iconDef = {
	width = 90,
	height = 60,
	scale = 2,
}
Unit._tooltipDef = {
	width = 90,
	height = 60,
	scale = 2,
	clip = true,
}

function Unit:new(id, base)
	IndexedEntry.new(self, id, base)
end

function Unit:getAnim()
	local image = self.Image

	if image == nil then
		return nil
	end

	return ANIMS[image] or nil
end

function Unit:getImagePath(anim)
	local anim = anim or Unit.getAnim(self)

	if anim == nil then
		return "img/units/nullUnit.png"
	end

	return anim.Image and ("img/"..anim.Image) or "img/units/nullUnit.png"
end

function Unit:getImageRows(anim)
	local anim = anim or Unit.getAnim(self)

	if anim == nil then
		return 1
	end

	return anim.Height or 1
end

function Unit:getImageColumns(anim)
	local anim = anim or Unit.getAnim(self)

	if anim == nil then
		return 1
	end

	return anim.Frames and #anim.Frames or anim.NumFrames or 1
end

function Unit:getImageOffset()
	return self.ImageOffset or 0
end

function Unit:getName()
	return self.Name
end

function Unit:isValid()
	return Unit.getImagePath(self):sub(1,10) == "img/units/"
end

function Unit:isMech()
	return Unit.getImagePath(self):sub(1,17) == "img/units/player/"
end

function Unit:isEnemy()
	return Unit.getImagePath(self):sub(1,17) == "img/units/aliens/"
end

function Unit:isBot()
	return Unit.getImagePath(self):sub(1,19) == "img/units/snowbots/"
end

function Unit:isMission()
	return Unit.getImagePath(self):sub(1,18) == "img/units/mission/"
end

function Unit:isBaseEnemy()
	local isBaseEnemy = true
		and (self:isEnemy() or self:isBot())
		and tonumber(self._id:sub(-1,-1)) == 1

	return isBaseEnemy
end

function Unit:copy(base)
	if type(base) ~= 'table' then return end

	for _, key in ipairs(keys) do
		self[key] = copy_table(base[key])
	end
end

function Unit:getCategory()
	return nil
end

function Unit:getDragType()
	return "UNIT"
end

local Units = IndexedList(Unit)
Units._soundBases = {}
Units._basePawn = TankMech.__index
Units._baseMech = PunchMech:new()

function Units:addSoundBase(unit)
	local soundBase = unit.SoundLocation
	local addSound = true
		and type(soundBase) == 'string'
		and soundBase ~= ""
		and not list_contains(self._soundBases, soundBase)

	if addSound then
		table.insert(self._soundBases, soundBase)
	end
end

function Units:update()
	local cache_units = easyEdit.savedata.cache.units or NULLTABLE

	for unit_id, unit_data in pairs(cache_units) do
		local livedata = modApi.units:get(unit_id)
		local unit = _G[unit_id]

		if unit == nil then
			unit = self._baseMech:new(unit_data)
			_G[unit_id] = unit
		end

		if livedata == nil then
			livedata = modApi.units:add(unit_id, self._baseMech)
			livedata:lock()
		end

		if livedata then
			clear_table(livedata)
			clone_table(livedata, unit_data)
			livedata.copy(unit, livedata)
		end
	end
end

modApi.units = Units
