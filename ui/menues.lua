
local path = GetParentPath(...)
local unitEditor = require(path.."editor_unit")
local enemyListEditor = require(path.."editor_enemyList")
local bossListEditor = require(path.."editor_bossList")
local missionListEditor = require(path.."editor_missionList")
local structureListEditor = require(path.."editor_structureList")
local islandEditor = require(path.."editor_island")
local worldEditor = require(path.."editor_world")

local UNIT_TITLE = "Unit Editor"
local UNIT_TOOLTIP = "Create new units, or edit existing ones"
local ENEMY_LIST_TITLE = "Enemy Lists Editor"
local ENEMY_LIST_TOOLTIP = "Create new enemy lists, or edit existing ones"
local BOSS_LIST_TITLE = "Boss Lists Editor"
local BOSS_LIST_TOOLTIP = "Create new boss lists, or edit existing ones"
local MISSION_LIST_TITLE = "Mission Lists Editor"
local MISSION_LIST_TOOLTIP = "Create new mission lists, or edit existing ones"
local STRUCTURE_LIST_TITLE = "Structure Lists Editor"
local STRUCTURE_LIST_TOOLTIP = "Create new structure lists, or edit existing ones"
local ISLAND_TITLE = "Island Editor"
local ISLAND_TOOLTIP = "Create new islands, or edit existing ones"
local WORLD_TITLE = "World Editor"
local WORLD_TOOLTIP = "Arrange the content of the 4 playable islands"

sdlext.addModContent(UNIT_TITLE, unitEditor.mainButton, UNIT_TOOLTIP)
sdlext.addModContent(ENEMY_LIST_TITLE, enemyListEditor.mainButton, ENEMY_LIST_TOOLTIP)
sdlext.addModContent(BOSS_LIST_TITLE, bossListEditor.mainButton, BOSS_LIST_TOOLTIP)
sdlext.addModContent(MISSION_LIST_TITLE, missionListEditor.mainButton, MISSION_LIST_TOOLTIP)
sdlext.addModContent(STRUCTURE_LIST_TITLE, structureListEditor.mainButton, STRUCTURE_LIST_TOOLTIP)
sdlext.addModContent(ISLAND_TITLE, islandEditor.mainButton, ISLAND_TOOLTIP)
sdlext.addModContent(WORLD_TITLE, worldEditor.mainButton, WORLD_TOOLTIP)
