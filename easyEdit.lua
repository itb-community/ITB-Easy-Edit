
local skipInit = true
	and easyEdit ~= nil
	and easyEdit.initialized == true

if skipInit then
	return easyEdit
end

local VERSION = "0.0.0"
local path = GetParentPath(...)

local function finalizeInit(self)
	LOGDF("Easy Edit %s initializing", self.version)
	Assert.Traceback = true

	require(path.."global")
	require(path.."datastructures/binarySearch")
	require(path.."datastructures/sort")
	require(path.."modules/saveData")
	require(path.."modules/events")
	require(path.."modules/gameState")
	require(path.."modules/indexedList")
	require(path.."modules/units")
	require(path.."modules/unitImage")
	require(path.."modules/weapons")
	require(path.."modules/missions")
	require(path.."modules/structures")
	require(path.."modules/corporation")
	require(path.."modules/tileset")
	require(path.."modules/structure")
	require(path.."modules/structureList")
	require(path.."modules/enemyList")
	require(path.."modules/bossList")
	require(path.."modules/missionList")
	require(path.."modules/island")
	require(path.."modules/islandComposite")
	require(path.."modules/world")
	require(path.."modules/currentTileset")
	require(path.."alter")
	require(path.."ui/widget/Ui")
	require(path.."ui/widget/UiTooltip")
	require(path.."ui/textevent")
	require(path.."ui/widget/UiTextBox")
	require(path.."ui/deco/DecoTextBox")
	require(path.."ui/menues")

	LOGDF("Easy Edit %s initialized", self.version)
end

local function onModsMetadataDone()
	local exit = false
		or easyEdit.initialized
		or easyEdit.version > VERSION

	if exit then
		return
	end

	easyEdit:finalizeInit()
	easyEdit.initialized = true
end


local isNewestVersion = false
	or easyEdit == nil
	or modApi:isVersion(VERSION, easyEdit.version) == false

if isNewestVersion then
	easyEdit = easyEdit or {}
	easyEdit.version = VERSION
	easyEdit.path = path
	easyEdit.finalizeInit = finalizeInit

	-- easyEdit needs to be initialized after all mods have been enumerated,
	-- but before any mod begins initializing. onModsMetadataDone will suffice.
	modApi.events.onModsMetadataDone:subscribe(onModsMetadataDone)
end

return easyEdit
