
local path = GetParentPath(...)
local switch = require(path.."switch")
local helpers = require(path.."helpers")
local DecoUnit = require(path.."deco/DecoUnit")
local DecoIcon = require(path.."deco/DecoIcon")
local DecoBounceLabel = require(path.."deco/DecoBounceLabel")
local DecoTransHeader = require(path.."deco/DecoTransHeader")

-- defs
local NULL_ICON_DEF = {}
local NULL_DECO = UiDeco()
local LABEL_HEIGHT = helpers.LABEL_HEIGHT
local FONT_LABEL = helpers.FONT_LABEL
local TEXT_SETTINGS_LABEL = helpers.TEXT_SETTINGS_LABEL

local function getIconDef(obj)
	local iconDef = NULL_ICON_DEF

	if obj and obj.getIconDef then
		iconDef = obj:getIconDef() or NULL_ICON_DEF
	end

	return iconDef
end

local getDecoration = switch()
local getName = switch()
local getReward = switch()

function getDecoration.unit(unit)
	local iconDef = getIconDef(unit)
	return DecoUnit(unit, iconDef)
end

function getDecoration.default(obj)
	local iconDef = getIconDef(obj)
	return DecoIcon(obj, iconDef)
end

function getName.default(obj)
	return obj:getName() or ""
end

getReward[REWARD_REP] = function()
	return "img/ui/star.png"
end

getReward[REWARD_POWER] = function()
	return "img/ui/power.png"
end

getReward[REWARD_TECH] = function()
	return "img/ui/core.png"
end

getReward.default = function()
	return "img/ui/star.png"
end

local function applyIconDef(ui, obj)
	local iconDef = getIconDef(obj)
	local width = iconDef.width
	local height = iconDef.height
	local scale = iconDef.scale or 2

	if width then
		ui:widthpx(width * scale)
	end

	if height then
		ui:heightpx(height * scale)
	end
end

local function button_base(ui, obj, type)
	local decoObj = NULL_DECO
	local name = ""

	if obj then
		decoObj = getDecoration(type, obj)
		name = getName(type, obj)
	end

	local decorations = {
		DecoButton(),
		DecoAnchor(),
		decoObj,
		DecoTransHeader(),
		DecoBounceLabel(name),
	}

	if ui then
		ui:decorate(decorations)
		applyIconDef(ui, obj)
	end

	return decorations
end

local function button_unit(ui, unit)
	return button_base(ui, unit, "unit")
end

local function button_obj(ui, obj)
	return button_base(ui, obj, "default")
end

local function button_structure(ui, obj)
	local decorations = button_obj(nil, obj)
	local decoReward = DecoIcon(
		nil,
		{
			outlinesize = 0,
			alignV = "bottom",
			alignH = "right",
		}
	)
	table.insert(decorations, 4, DecoAlign(0, -4))
	table.insert(decorations, 5, decoReward)
	table.insert(decorations, 6, DecoAnchor())

	if ui then
		ui:decorate(decorations)
		applyIconDef(ui, obj)
	end

	if obj then
		decoReward:setObject(getReward(obj.Reward))
	end

	return base
end

local function button_islandComposite(ui, islandComposite)
	local island = modApi.island:get(islandComposite.island)
	local decorations = button_base(ui, island)
	local decoBounceLabel = decorations[5]
	decoBounceLabel:setsurface(islandComposite:getName())

	return decorations
end

return {
	button = {
		unit = button_unit,
		weapon = button_obj,
		mission = button_obj,
		structure = button_structure,
		islandComposite = button_islandComposite,
		obj = button_obj,
	},
	unit = getDecoration.unit,
	island = getDecoration.default,
	weapon = getDecoration.default,
	icon = getDecoration.default,
}
