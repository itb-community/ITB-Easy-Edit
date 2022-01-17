
local vanillaCorporations = { "Corp_Grass", "Corp_Desert", "Corp_Snow", "Corp_Factory" }

modApi.world = {}

function modApi.world:setUnit(unit_id, unit)
	if not unit then return end

	local base = _G[unit_id]

	unit.copy(base, unit)
end

function modApi.world:setWeapon(weapon_id, weapon)
	if not weapon then return end

	local base = _G[weapon_id]

	weapon.copy(base, weapon)
end

function modApi.world:setIsland(islandSlot, island)
	if not island then return end
	Assert.ResourceDatIsOpen()

	local n = islandSlot - 1

	Location[string.format("strategy/island%s.png", n)] = Island_Locations[islandSlot]
	Location[string.format("strategy/island1x_%s.png", n)] = Island_Locations[islandSlot] - island.shift
	Location[string.format("strategy/island1x_%s_out.png", n)] = Island_Locations[islandSlot] - island.shift

	Island_Magic[islandSlot] = island.magic

	for k = 0, 7 do
		Region_Data[string.format("island_%s_%s", n, k)] = island.regionData[k+1]
	end

	for k = 0, 7 do
		_G["Network_Island_".. n][tostring(k)] = island.network[k+1]
	end

	island.copyAssets({_id = n}, island)
end

function modApi.world:setCorp(islandSlot, corp)
	if not corp then return end

	local corp_id = vanillaCorporations[islandSlot]
	local base = _G[corp_id]

	corp.copy(base, corp)
	modApi.modLoaderDictionary[corp_id .."_Name"] = corp.Name
	modApi.modLoaderDictionary[corp_id .."_Description"] = corp.Description
end

function modApi.world:setCeo(islandSlot, ceo)
	if not ceo then return end

	local corp_id = vanillaCorporations[islandSlot]
	local base = _G[corp_id]

	ceo.copy(base, ceo)
	modApi.modLoaderDictionary[corp_id .."_CEO_Name"] = ceo.CEO_Name
end

function modApi.world:setTileset(islandSlot, tileset)
	if not tileset then return end

	local corp_id = vanillaCorporations[islandSlot]
	local base = _G[corp_id]

	base.Tileset = tileset._id
	modApi.modLoaderDictionary[corp_id .."_Environment"] = tileset.climate
end

function modApi.world:setEnemyList(islandSlot, enemyList)
	if not enemyList then return end

	local corp_id = vanillaCorporations[islandSlot]
	local base = _G[corp_id]

	base.EnemyList = enemyList._id
end

function modApi.world:setBossList(islandSlot, bossList)
	if not bossList then return end

	local corp_id = vanillaCorporations[islandSlot]
	local base = _G[corp_id]

	bossList.copy(base, bossList)
end

function modApi.world:setMissionList(islandSlot, missionList)
	if not missionList then return end

	local corp_id = vanillaCorporations[islandSlot]
	local base = _G[corp_id]

	missionList.copy(base, missionList)
end

function modApi.world:setStructureList(islandSlot, structureList)
	if not structureList then return end

	local corp_id = vanillaCorporations[islandSlot]
	local base = _G[corp_id]

	structureList.copy(base, structureList)
end
