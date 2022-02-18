
local NULLTABLE = {}
local IslandComposite = Class.inherit(IndexedEntry)
IslandComposite._entryType = "IslandComposite"
IslandComposite._iconDef = {
	width = 120,
	height = 120,
	scale = 2,
	clip = true,
	outlinesize = 0,
	pathformat = "img/strategy/island1x_%s.png",
}
IslandComposite._tooltipDef = {
	width = 180,
	height = 180,
	scale = 1,
	clip = true,
	outlinesize = 0,
	pathformat = "img/strategy/island1x_%s.png",
}

function IslandComposite:new(id, base)
	IndexedEntry.new(self, id, base)
end

function IslandComposite:getDragType()
	return "ISLAND_COMPOSITE"
end

local IslandComposites = IndexedList(IslandComposite)

function IslandComposites:save()
	easyEdit.savedata.cache.islandComposite = copy_table(self._children)
	easyEdit.savedata:save()
end

function IslandComposites:update()
	local cache_islandComposites = easyEdit.savedata.cache.islandComposite or NULLTABLE

	for cache_id, cache_islandComposite in pairs(cache_islandComposites) do
		local islandComposite = modApi.islandComposite:get(cache_id)

		if islandComposite then
			clear_table(islandComposite)
			clone_table(islandComposite, cache_islandComposite)
		end
	end

	local cache_world = easyEdit.savedata.cache.world or NULLTABLE

	for islandSlot, cache_data in ipairs(cache_world) do
		local cache_islandComposite = modApi.islandComposite:get(cache_data)

		local island = modApi.island:get(cache_islandComposite.island)
		local corp = modApi.corporation:get(cache_islandComposite.corporation)
		local ceo = modApi.ceo:get(cache_islandComposite.ceo)
		local tileset = modApi.tileset:get(cache_islandComposite.tileset)
		local enemyList = modApi.enemyList:get(cache_islandComposite.enemyList)
		local bossList = modApi.bossList:get(cache_islandComposite.bossList)
		local missionList = modApi.missionList:get(cache_islandComposite.missionList)
		local structureList = modApi.structureList:get(cache_islandComposite.structureList)

		if modApi.resource then
			modApi.world:setIsland(islandSlot, island)
		end

		modApi.world:setCorporation(islandSlot, corp)
		modApi.world:setCeo(islandSlot, ceo)
		modApi.world:setTileset(islandSlot, tileset)
		modApi.world:setEnemyList(islandSlot, enemyList)
		modApi.world:setBossList(islandSlot, bossList)
		modApi.world:setMissionList(islandSlot, missionList)
		modApi.world:setStructureList(islandSlot, structureList)
	end
end

modApi.islandComposite = IslandComposites
