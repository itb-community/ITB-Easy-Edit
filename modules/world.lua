
-- defs
local DEFAULT_ISLAND_SLOTS = { "archive", "rst", "pinnacle", "detritus" }
local LOGDF = easyEdit.LOGF


local vanillaCorporations = { "Corp_Grass", "Corp_Desert", "Corp_Snow", "Corp_Factory" }

modApi.world = {
	{
		bossList = "archive",
		ceo = "dewey",
		corporation = "archive",
		enemyList = "vanilla",
		island = "archive",
		missionList = "archive",
		structureList = "vanilla",
		tileset = "grass",
	},
	{
		bossList = "rst",
		ceo = "jessica",
		corporation = "rst",
		enemyList = "vanilla",
		island = "rst",
		missionList = "rst",
		structureList = "vanilla",
		tileset = "sand",
	},
	{
		bossList = "pinnacle",
		ceo = "zenith",
		corporation = "pinnacle",
		enemyList = "vanilla",
		island = "pinnacle",
		missionList = "pinnacle",
		structureList = "vanilla",
		tileset = "snow",
	},
	{
		bossList = "detritus",
		ceo = "vikram",
		corporation = "detritus",
		enemyList = "vanilla",
		island = "detritus",
		missionList = "detritus",
		structureList = "vanilla",
		tileset = "acid",
	},
}

function modApi.world:update()
	local cache_world = easyEdit.savedata.cache.world or DEFAULT_ISLAND_SLOTS

	for islandSlot, cache_data in ipairs(cache_world) do
		local cache_islandComposite = modApi.islandComposite:get(cache_data)

		if cache_islandComposite then
			if modApi.resource then
				self:setIsland(islandSlot, cache_islandComposite.island)
			end

			self:setCorporation(islandSlot, cache_islandComposite.corporation)
			self:setCeo(islandSlot, cache_islandComposite.ceo)
			self:setTileset(islandSlot, cache_islandComposite.tileset)
			self:setEnemyList(islandSlot, cache_islandComposite.enemyList)
			self:setBossList(islandSlot, cache_islandComposite.bossList)
			self:setMissionList(islandSlot, cache_islandComposite.missionList)
			self:setStructureList(islandSlot, cache_islandComposite.structureList)
		end
	end
end

function modApi.world:reset()
	easyEdit.savedata.cache.world = nil
	self:update()
end

function modApi.world:setIsland(islandSlot, islandId)
	Assert.Equals('number', type(islandSlot), "Argument #1")
	Assert.Range(1, 4, islandSlot, "Argument #1")
	Assert.Equals('string', type(islandId), "Argument #2")
	Assert.ResourceDatIsOpen()

	local island = modApi.island:get(islandId)
	if island == nil then
		LOGDF("EasyEdit - Ignore missing island %q for island slot %s", islandId, islandSlot)
		return
	elseif island:isInvalid() then
		LOGDF("EasyEdit - Ignore malformed island %q for island slot %s", islandId, islandSlot)
		return
	else
		self[islandSlot].island = islandId
		LOGDF("EasyEdit - set island %q for island slot %s", islandId, islandSlot)
	end

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

function modApi.world:setCorporation(islandSlot, corpId)
	Assert.Equals('number', type(islandSlot), "Argument #1")
	Assert.Range(1, 4, islandSlot, "Argument #1")
	Assert.Equals('string', type(corpId), "Argument #2")

	local corp = modApi.corporation:get(corpId)
	if corp == nil then
		LOGDF("EasyEdit - Ignore missing corporation %q for island slot %s", corpId, islandSlot)
		return
	elseif corp:isInvalid() then
		LOGDF("EasyEdit - Ignore malformed corporation %q for island slot %s", corpId, islandSlot)
		return
	else
		self[islandSlot].corporation = corpId
		LOGDF("EasyEdit - set corporation %q for island slot %s", corpId, islandSlot)
	end

	local baseCorpId = vanillaCorporations[islandSlot]
	local base = _G[baseCorpId]

	corp.copy(base, corp)
	modApi.modLoaderDictionary[baseCorpId .."_Name"] = corp.Name
	modApi.modLoaderDictionary[baseCorpId .."_Description"] = corp.Description
end

function modApi.world:setCeo(islandSlot, ceoId)
	Assert.Equals('number', type(islandSlot), "Argument #1")
	Assert.Range(1, 4, islandSlot, "Argument #1")
	Assert.Equals('string', type(ceoId), "Argument #2")

	local ceo = modApi.ceo:get(ceoId)
	if ceo == nil then
		LOGDF("EasyEdit - Ignore missing ceo %q for island slot %s", ceoId, islandSlot)
		return
	elseif ceo:isInvalid() then
		LOGDF("EasyEdit - Ignore malformed ceo %q for island slot %s", ceoId, islandSlot)
		return
	else
		self[islandSlot].ceo = ceoId
		LOGDF("EasyEdit - set ceo %q for island slot %s", ceoId, islandSlot)
	end

	local baseCorpId = vanillaCorporations[islandSlot]
	local base = _G[baseCorpId]

	ceo.copy(base, ceo)
	modApi.modLoaderDictionary[baseCorpId .."_CEO_Name"] = ceo.CEO_Name
end

function modApi.world:setTileset(islandSlot, tilesetId)
	Assert.Equals('number', type(islandSlot), "Argument #1")
	Assert.Range(1, 4, islandSlot, "Argument #1")
	Assert.Equals('string', type(tilesetId), "Argument #2")

	local tileset = modApi.tileset:get(tilesetId)
	if tileset == nil then
		LOGDF("EasyEdit - Ignore missing tileset %q for island slot %s", tilesetId, islandSlot)
		return
	elseif tileset:isInvalid() then
		LOGDF("EasyEdit - Ignoring malformed tileset %q for island slot %s", tilesetId, islandSlot)
		return
	else
		self[islandSlot].tileset = tilesetId
		LOGDF("EasyEdit - set tileset %q for island slot %s", tilesetId, islandSlot)
	end

	local baseCorpId = vanillaCorporations[islandSlot]
	local base = _G[baseCorpId]

	base.Tileset = tileset._id
	modApi.modLoaderDictionary[baseCorpId .."_Environment"] = tileset.climate
end

function modApi.world:setEnemyList(islandSlot, enemyListId)
	Assert.Equals('number', type(islandSlot), "Argument #1")
	Assert.Range(1, 4, islandSlot, "Argument #1")
	Assert.Equals('string', type(enemyListId), "Argument #2")

	local enemyList = modApi.enemyList:get(enemyListId)
	if enemyList == nil then
		LOGDF("EasyEdit - Ignore missing enemy list %q for island slot %s", enemyListId, islandSlot)
		return
	elseif enemyList:isInvalid() then
		LOGDF("EasyEdit - Ignoring malformed enemy list %q for island slot %s", enemyListId, islandSlot)
		return
	else
		self[islandSlot].enemyList = enemyListId
		LOGDF("EasyEdit - set enemy list %q for island slot %s", enemyListId, islandSlot)
	end

	local baseCorpId = vanillaCorporations[islandSlot]
	local base = _G[baseCorpId]

	base.EnemyList = enemyList._id
end

function modApi.world:setBossList(islandSlot, bossListId)
	Assert.Equals('number', type(islandSlot), "Argument #1")
	Assert.Range(1, 4, islandSlot, "Argument #1")
	Assert.Equals('string', type(bossListId), "Argument #2")

	local bossList = modApi.bossList:get(bossListId)
	if not bossList then
		LOGDF("EasyEdit - Ignore missing boss list %q for island slot %s", bossListId, islandSlot)
		return
	elseif bossList:isInvalid() then
		LOGDF("EasyEdit - Ignore malformed boss list %q for island slot %s", bossListId, islandSlot)
		return
	else
		self[islandSlot].bossList = bossListId
		LOGDF("EasyEdit - set boss list %q for island slot %s", bossListId, islandSlot)
	end

	local baseCorpId = vanillaCorporations[islandSlot]
	local base = _G[baseCorpId]

	bossList.copy(base, bossList)
end

function modApi.world:setMissionList(islandSlot, missionListId)
	Assert.Equals('number', type(islandSlot), "Argument #1")
	Assert.Range(1, 4, islandSlot, "Argument #1")
	Assert.Equals('string', type(missionListId), "Argument #2")

	local missionList = modApi.missionList:get(missionListId)
	if not missionList then
		LOGDF("EasyEdit - Ignore missing mission list %q for island slot %s", missionListId, islandSlot)
		return
	elseif missionList:isInvalid() then
		LOGDF("EasyEdit - Ignore malformed mission list %q for island slot %s", missionListId, islandSlot)
		return
	else
		self[islandSlot].missionList = missionListId
		LOGDF("EasyEdit - set mission list %q for island slot %s", missionListId, islandSlot)
	end

	local baseCorpId = vanillaCorporations[islandSlot]
	local base = _G[baseCorpId]

	missionList.copy(base, missionList)
end

function modApi.world:setStructureList(islandSlot, structureListId)
	Assert.Equals('number', type(islandSlot), "Argument #1")
	Assert.Range(1, 4, islandSlot, "Argument #1")
	Assert.Equals('string', type(structureListId), "Argument #2")

	local structureList = modApi.structureList:get(structureListId)
	if not structureList then
		LOGDF("EasyEdit - Ignore missing structure list %q for island slot %s", structureListId, islandSlot)
		return
	elseif structureList:isInvalid() then
		LOGDF("EasyEdit - Ignore malformed structure list %q for island slot %s", structureListId, islandSlot)
		return
	else
		self[islandSlot].structureList = structureListId
		LOGDF("EasyEdit - set structure list %q for island slot %s", structureListId, islandSlot)
	end

	local baseCorpId = vanillaCorporations[islandSlot]
	local base = _G[baseCorpId]

	structureList.copy(base, structureList)
end
