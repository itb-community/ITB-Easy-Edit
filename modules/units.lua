
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

function Unit:copy(base)
	if type(base) ~= 'table' then return end

	for _, key in ipairs(keys) do
		self[key] = copy_table(base[key])
	end
end

local Units = IndexedList(Unit)
Units._soundBases = {}

function Units:addSoundBase(soundBase)
	local addSound = true
		and type(soundBase) == 'string'
		and soundBase ~= ""
		and not list_contains(self._soundBases, soundBase)

	if addSound then
		table.insert(self._soundBases, soundBase)
	end
end

modApi.units = Units
