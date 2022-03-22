
local function appendAssets(gameRoot, modPath)
	local modRoot = (modApi:getCurrentMod().resourcePath..modPath):gsub("^.*[^\\/]$","%1/")
	local files = mod_loader:enumerateFilesIn(modRoot)
	for _, file in ipairs(files) do
		modApi:appendAsset(gameRoot..file, modRoot..file)
	end
end

function modApi:appendPlayerUnitAssets(path)
	appendAssets("img/units/player/", path)
end

function modApi:appendEnemyUnitAssets(path)
	appendAssets("img/units/aliens/", path)
end

function modApi:appendMissionUnitAssets(path)
	appendAssets("img/units/mission/", path)
end

function modApi:appendBotUnitAssets(path)
	appendAssets("img/units/snowbots/", path)
end

function modApi:appendIconAssets(path)
	appendAssets("img/icon/", path)
end

function modApi:appendCombatAssets(path)
	appendAssets("img/combat/", path)
end

function modApi:appendEffectAssets(path)
	appendAssets("img/effects/", path)
end

modApi.appendMechAssets = modApi.appendPlayerUnitAssets
modApi.appendVekAssets = modApi.appendEnemyUnitAssets
modApi.appendBotAssets = modApi.appendBotUnitAssets
