
local extension = {
	id = "easyEdit",
	name = "Easy Edit",
	version = "1.6.0",
	modApiVersion = "2.7.3",
	gameVersion = "1.2.83",
}

function extension:metadata()
	if easyEdit then
		-- Prevent older versions from initializing
		easyEdit = { version = self.version }
	end
end

function extension:init(options)
	local path = self.resourcePath

	easyEdit = {}
	easyEdit.version = self.version
	easyEdit.path = self.resourcePath

	LOGDF("Easy Edit %s initializing", self.version)

	require(path.."datastructures/sort")
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
	require(path.."modules/saveData")
	require(path.."alter")
	require(path.."ui/widget/Ui")
	require(path.."ui/widget/UiCustomTooltip")
	require(path.."ui/widget/UiGroupTooltip")
	require(path.."ui/menues")
	require(path.."ui/editor_cleanProfile")

	LOGDF("Easy Edit %s initialized", self.version)
end

function extension:load(options, version)
	
end

return extension
