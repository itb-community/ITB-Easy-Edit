
local BASE_PAWN = TankMech.__index

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
	local hasAnim = true
		and type(image) == 'string'
		and type(ANIMS[image]) == 'table'

	if hasAnim == false then
		return nil
	end

	return ANIMS[image]
end

function Unit:getImagePath()
	local anim = Unit.getAnim(self)
	local hasImage = true
		and type(anim) == 'table'
		and type(anim.Image) == 'string'

	if hasImage == false then
		return ""
	end

	return anim.Image
end

function Unit:getName()
	return self.Name
end

function Unit:isValid()
	return Unit.getImagePath(self):sub(1,6) == "units/"
end

function Unit:isMech()
	return Unit.getImagePath(self):sub(1,13) == "units/player/"
end

function Unit:isEnemy()
	return Unit.getImagePath(self):sub(1,13) == "units/aliens/"
end

function Unit:isBot()
	return Unit.getImagePath(self):sub(1,15) == "units/snowbots/"
end

function Unit:isMission()
	return Unit.getImagePath(self):sub(1,14) == "units/mission/"
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
	local entryType = self:getEntryType()
	local cache_savedata = easyEdit.savedata.cache[entryType] or NULLTABLE

	for cache_id, cache_data in pairs(cache_savedata) do
		local livedata = modApi[entryType]:get(cache_id)

		if _G[cache_id] == nil then
			_G[cache_id] = BASE_PAWN:new(cache_data)
		end

		if livedata == nil then
			livedata = modApi[entryType]:add(cache_id)
			livedata:lock()
		end

		if livedata then
			clear_table(livedata)
			clone_table(livedata, cache_data)

			modApi.world:setUnit(cache_id, livedata)
		end
	end
end

modApi.units = Units
