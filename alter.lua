
local path = GetParentPath(...)

local vanillaCorporations = { "Corp_Grass", "Corp_Desert", "Corp_Snow", "Corp_Factory" }
local difficulties = { DIFF_EASY, DIFF_NORMAL, DIFF_HARD }

local islands = { "archive", "rst", "pinnacle", "detritus", "final" }
local tileTypes = { TERRAIN_FOREST, TERRAIN_SAND, TERRAIN_ICE, TERRAIN_ACID }
local islandShifts = { Point(14,5), Point(16,15), Point(17,12), Point(18,15), Point(0,0) }

local corporations = { "archive", "rst", "pinnacle", "detritus" }
local ceos = { "dewey", "jessica", "zenith", "vikram" }
local missionLists = corporations
local bossLists = corporations

local tilesets = { "grass", "sand", "snow", "acid", "lava", "volcano", "vine", "hologram" }
local climate = { "", "", "", "", "Scorching", "Fiery", "Lush", "Holograpic" }
local rainChance = { 0, 0, 0, 0, 0, 0, 70, 30 }
local environmentChance = { 0, 0, 0, 0, 0, 0, { [TERRAIN_FOREST] = 60 }, 0 }

local mechList = {
	"PunchMech", "TankMech", "ArtiMech",
	"JetMech", "RocketMech", "PulseMech",
	"LaserMech", "ChargeMech", "ScienceMech",
	"ElectricMech", "WallMech", "RockartMech",
	"JudoMech", "DStrikeMech", "GravMech",
	"FlameMech", "IgniteMech", "TeleMech",
	"GuardMech", "MirrorMech", "IceMech",
	"LeapMech", "UnstableTank", "NanoMech",
}

local function registerUnits()
	for id, base in pairs(_G) do
		local isUnit = true
			and type(base) == 'table'
			and type(base.Name) == 'string'
			and type(base.Class) == 'string'
			and type(base.Image) == 'string'
			and type(base.Health) == 'number'
			and type(base.MoveSpeed) == 'number'
			and type(base.SkillList) == 'table'

		if isUnit then
			if not modApi.units:get(id) then
				modApi.units:addSoundBase(base.SoundLocation)

				local anim = ANIMS[base.Image]
				local isValidUnit
				local isMech
				local isEnemy
				local isBot
				local isMission
				local isImage = true
					and type(anim) == 'table'
					and type(anim.Image) == 'string'
					and modApi:assetExists("img/"..anim.Image)

				if isImage then
					if anim.Image:find("^units/player/") then
						isValidUnit = true
						isMech = true

					elseif anim.Image:find("^units/aliens/") then
						isValidUnit = true
						isEnemy = true

					elseif anim.Image:find("^units/snowbots/") then
						isValidUnit = true
						isEnemy = true
						isBot = true

					elseif anim.Image:find("^units/mission/") then
						isValidUnit = true
						isMission = true
					end

					if isValidUnit then
						local unit = modApi.units:add(id)
						unit:copy(base)
						unit.Name = GetText(id) or base.Name
						unit._isUnit = isValidUnit
						unit._isMech = isMech
						unit._isEnemy = isEnemy
						unit._isBot = isBot
						unit._isMission = isMission
					end
				end
			end
		end
	end
end

local function registerWeapons()
	for id, _ in pairs(modApi.weaponDeck) do
		local base = _G[id]

		if not modApi.weapons:get(id) then
			local weapon = modApi.weapons:add(id)
			weapon:copy(base)
			weapon.__Id = id
			weapon.Name = GetText(id.."_Name") or base.Name
			weapon.Description = GetText(id.."_Description") or base.Description
		end
	end
end

local function registerMissions()
	for i, id in ipairs(corporations) do
		local corp_id = vanillaCorporations[i]
		local base = _G[corp_id]

		local function addMissions(missionTable)
			for _, mission_id in ipairs(missionTable) do
				if not modApi.missions:get(mission_id) then
					local base = _G[mission_id]
					local mission = modApi.missions:add(mission_id)
					mission:copy(base)
				end
			end
		end

		addMissions(base.Missions_High)
		addMissions(base.Missions_Low)
		addMissions(base.Bosses)
		addMissions(base.UniqueBosses)
	end
end

local function registerStructures()
	for i, id in ipairs(corporations) do
		local corp_id = vanillaCorporations[i]
		local base = _G[corp_id]

		local function addStructures(structureTable)
			for _, structure_id in ipairs(structureTable) do
				if not modApi.structures:get(structure_id) then
					local base = _G[structure_id]
					local structure = modApi.structures:add(structure_id)
					structure:copy(base)
				end
			end
		end

		addStructures(base.PowAssets)
		addStructures(base.TechAssets)
		addStructures(base.RepAssets)
	end
end

local function registerIslands()
	for i, id in ipairs(islands) do
		local island = modApi.island:add(id)
		local n = i-1

		island:copyAssets({_id = tostring(n)})
		island.shift = islandShifts[i]
		island.magic = Island_Magic[i]
		island.regionData = {}
		island.network = {}

		if i <= 4 then
			for k = 0, 7 do
				table.insert(island.regionData, Region_Data[string.format("island_%s_%s", n, k)])
			end

			for k = 0, 7 do
				table.insert(island.network, _G["Network_Island_".. n][tostring(k)])
			end
		end
	end
end

local function registerCorporations()
	for i, id in ipairs(corporations) do
		local corp = modApi.corporation:add(id)
		local corp_id = vanillaCorporations[i]
		local base = _G[corp_id]

		corp:copy(base)
		corp.Name = GetText(corp_id .."_Name") or ""
		corp.Description = GetText(corp_id .."_Description") or ""
	end
end

local function registerCEOs()
	for i, id in ipairs(ceos) do
		local ceo = modApi.corporation.ceo:add(id)
		local corp_id = vanillaCorporations[i]
		local base = _G[corp_id]

		ceo:copy(base)
		ceo.CEO_Name = GetText(corp_id .."_CEO_Name") or ""
	end
end

local function registerTilesets()
	modApi:appendAsset(
		"img/strategy/corp/lava_env.png",
		path.."img/env/lava_env.png")
	modApi:appendAsset(
		"img/strategy/corp/volcano_env.png",
		path.."img/env/volcano_env.png")
	modApi:appendAsset(
		"img/strategy/corp/vine_env.png",
		path.."img/env/vine_env.png")
	modApi:appendAsset(
		"img/strategy/corp/hologram_env.png",
		path.."img/env/hologram_env.png")
	modApi:copyAsset(
		"img/combat/tiles_grass/building_sheet_vines.png",
		"img/combat/tiles_vine/building_sheet.png")

	-- temporarily override GetRealDifficulty
	-- while extracting environmentChance for
	-- vanilla tilesets
	local oldGetDifficulty = GetRealDifficulty
	local difficulty
	function GetRealDifficulty()
		return difficulty
	end

	for i, id in ipairs(tilesets) do
		local corp_id = vanillaCorporations[i]

		if corp_id then
			local tileset = modApi.tileset:add(id)
			-- fill in missing conveyor assets
			tileset:copyAssets({_id = "acid"}, false)

			tileset.climate = GetText(corp_id .."_Environment") or ""
			tileset.rainChance = getRainChance(id)
			tileset.environmentChance = {}

			for _, diff in ipairs(difficulties) do
				difficulty = diff
				tileset.environmentChance[diff] = {}

				for _, tileType in ipairs(tileTypes) do
					tileset.environmentChance[diff][tileType] = getEnvironmentChance(id, tileType)
				end
			end
		else
			local tileset = modApi.tileset:add(id)
			-- set missing locations
			tileset:copyAssets(tileset)
			-- fill in missing assets
			tileset:copyAssets({_id = "grass"}, false)
			tileset:copyAssets({_id = "acid"}, false)

			tileset.climate = climate[i]
			tileset.rainChance = rainChance[i]
			tileset.environmentChance = environmentChance[i]
		end
	end

	GetRealDifficulty = oldGetDifficulty

	function getRainChance(sectorType)
		local tileset = modApi.tileset:get(sectorType)
		local noDataFound = not tileset or not tileset.getRainChance

		if noDataFound then
			return 0
		end

		return tileset:getRainChance()
	end

	function getEnvironmentChance(sectorType, tileType)
		local tileset = modApi.tileset:get(sectorType)
		local noDataFound = not tileset or not tileset.getEnvironmentChance

		if noDataFound then
			return 0
		end

		return tileset:getEnvironmentChance(tileType, GetDifficulty())
	end

	modApi.events.onTilesetChanged:subscribe(function(newTileset, oldTileset)
		local oldTileset = modApi.tileset:get(oldTileset)
		local newTileset = modApi.tileset:get(newTileset)

		oldTileset:onDisabled()
		newTileset:onEnabled()
	end)
end

local function registerEnemyLists()
	local id = "vanilla"
	local enemyList = modApi.enemyList:add(id)
	enemyList.enemies = copy_table(EnemyLists)

	for i, corp_id in ipairs(vanillaCorporations) do
		local corp = _G[corp_id]
		corp.EnemyList = id
	end

	local oldStartNewGame = startNewGame
	function startNewGame()
		oldStartNewGame()

		local timesPicked = {}
		for i, corp_id in ipairs(vanillaCorporations) do
			local corp = _G[corp_id]
			local enemyList = modApi.enemyList:get(corp.EnemyList)

			GAME.Enemies[i] = enemyList:pickEnemies(i, timesPicked)
		end
	end
end

local function registerBossLists()
	for i, id in ipairs(corporations) do
		local bossList = modApi.bossList:add(id)
		local corp_id = vanillaCorporations[i]
		local base = _G[corp_id]

		bossList:copy(base)
	end
end

local function registerMissionLists()
	for i, id in ipairs(corporations) do
		local missionList = modApi.missionList:add(id)
		local corp_id = vanillaCorporations[i]
		local base = _G[corp_id]

		missionList:copy(base)
	end
end

local function registerStructureLists()
	local id = "vanilla"
	local structureList = modApi.structureList:add(id)
	structureList:copy(Corp_Default)
end

local function markRegisteredAsVanilla()
	local function markAsVanilla(indexedList)
		for _, indexedEntry in pairs(indexedList._children) do
			indexedEntry._vanilla = true
		end
	end

	markAsVanilla(modApi.units)
	markAsVanilla(modApi.weapons)
	markAsVanilla(modApi.missions)
	markAsVanilla(modApi.structures)
	markAsVanilla(modApi.corporation)
	markAsVanilla(modApi.tileset)
	markAsVanilla(modApi.structureList)
	markAsVanilla(modApi.enemyList)
	markAsVanilla(modApi.bossList)
	markAsVanilla(modApi.missionList)
	markAsVanilla(modApi.island)
end

registerUnits()
registerWeapons()
registerMissions()
registerStructures()
registerIslands()
registerCorporations()
registerCEOs()
registerTilesets()
registerEnemyLists()
registerBossLists()
registerMissionLists()
registerStructureLists()

modApi.events.onModsInitialized:subscribe(markRegisteredAsVanilla)
modApi.events.onModsInitialized:subscribe(registerUnits)
modApi.events.onModsInitialized:subscribe(registerWeapons)
modApi.events.onModsInitialized:subscribe(registerMissions)
modApi.events.onModsInitialized:subscribe(registerStructures)
