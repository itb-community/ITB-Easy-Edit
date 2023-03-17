
local extension = {
	id = "easyEdit",
	name = "Easy Edit",
	version = "2.0.4",
	modApiVersion = "2.9.0",
	gameVersion = "1.2.88",
	icon = "img/icon.png",
	isExtension = true,
	enabled = false,
}

function extension:metadata()
	easyEdit = {
		version = self.version,
		path = self.resourcePath
	}
end

function extension:init(options)
	local path = self.resourcePath
	--Add randomization
	math.randomseed(os.time())
	math.random()

	require(path.."modules/events")
	require(path.."modules/indexedList")
	require(path.."modules/units")
	require(path.."modules/unitImage")
	require(path.."modules/weapons")
	require(path.."modules/missions")
	require(path.."modules/structures")
	require(path.."modules/corporation")
	require(path.."modules/tileset")
	require(path.."modules/structureList")
	require(path.."modules/enemyList")
	require(path.."modules/bossList")
	require(path.."modules/missionList")
	require(path.."modules/island")
	require(path.."modules/islandComposite")
	require(path.."modules/world")
	require(path.."modules/saveData")
	require(path.."modules/misc")
	require(path.."alter")
	require(path.."ui/widget/UiGroupTooltip")
	require(path.."ui/menues")
	require(path.."ui/editor_cleanProfile")
end

function extension:load(options, version)
	
end

return extension
