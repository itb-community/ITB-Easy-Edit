
local path = GetParentPath(...)
local switch = require(path.."switch")
local helpers = require(path.."helpers")
local DecoIcon = require(path.."deco/DecoIcon")
local DecoUnit = require(path.."deco/DecoUnit")
local DecoTransHeader = require(path.."deco/DecoTransHeader")
local DecoBounceLabel = require(path.."deco/DecoBounceLabel")


-- Default Object
local UiTooltipObject = Class.inherit(Ui)
function UiTooltipObject:new()
	Ui.new(self)

	self._debugName = "UiTooltipObject"
	self:sizepx(60, 60)
	self.decoIcon = DecoIcon()
	self.decoLabel = DecoBounceLabel()
	self.staticTooltip = true
	self.decoIcon.isTooltip = true

	self:decorate{
		DecoFrame(),
		self.decoIcon,
		DecoTransHeader(),
		self.decoLabel,
	}
end

function resize(self, obj)
	if obj == nil then
		return
	end

	local tooltipDef = obj:getTooltipDef()
	if tooltipDef then
		local width = tooltipDef.width
		local height = tooltipDef.height
		local scale = tooltipDef.scale or 1

		self.w = width * scale or self.w
		self.h = height * scale or self.h
	end
end

function UiTooltipObject:onCustomTooltipShown(hoveredUi)
	local obj = hoveredUi.data

	if obj == nil then
		self.decoLabel:setsurface("")
		self.decoIcon:setObject(nil)
		return
	end

	resize(self, obj)
	self.decoIcon:setObject(obj, obj:getTooltipDef())
	self.decoLabel:setsurface(obj:getName())
end


-- Unit
UiTooltipUnit = Class.inherit(UiTooltipObject)
function UiTooltipUnit:new()
	UiTooltipObject.new(self)

	self._debugName = "UiTooltipUnit"
	self.decoIcon = DecoUnit()
	self:replaceDeco(2, self.decoIcon)
end

function UiTooltipUnit:onCustomTooltipShown(hoveredUi)
	local obj = hoveredUi.data

	if obj == nil then
		self.decoLabel:setsurface("")
		self.decoIcon:setObject(nil)
		return
	end

	resize(self, obj)
	self.decoIcon:setObject(obj, obj:getTooltipDef())
	self.decoLabel:setsurface(obj:getName())
end


-- Boss Mission
UiTooltipBossMission = Class.inherit(UiTooltipUnit)
function UiTooltipBossMission:new()
	UiTooltipUnit.new(self)
	self._debugName = "UiTooltipBossMission"
end

function UiTooltipBossMission:onCustomTooltipShown(hoveredUi)
	local obj = hoveredUi.data

	if obj then
		obj = modApi.units:get(obj.BossPawn)
	end

	if obj == nil then
		self.decoLabel:setsurface("")
		self.decoIcon:setObject(nil)
		return
	end

	resize(self, obj)
	self.decoIcon:setObject(obj, obj:getTooltipDef())
	self.decoLabel:setsurface(obj:getName())
end


local tooltips = {
	mission = UiTooltipObject(),
	bossMission = UiTooltipBossMission(),
	unit = UiTooltipUnit(),
	structure = UiTooltipObject(),
	island = UiTooltipObject(),
	ceo = UiTooltipObject(),
	tileset = UiTooltipObject(),
	object = UiTooltipObject(),
}

local function getTooltip(obj)
	if obj.instanceOf == nil then
		return tooltips.object
	elseif obj:instanceOf(modApi.missions._class) then
		if obj.BossPawn then
			return tooltips.bossMission
		else
			return tooltips.mission
		end
	elseif obj:instanceOf(modApi.units._class) then
		return tooltips.unit
	elseif obj:instanceOf(modApi.structures._class) then
		return tooltips.structure
	elseif obj:instanceOf(modApi.islandComposite._class) then
		Assert.Error("Use helper_tooltip_islandComposite.lua")
	elseif obj:instanceOf(modApi.island._class) then
		return tooltips.island
	elseif obj:instanceOf(modApi.ceo._class) then
		return tooltips.ceo
	elseif obj:instanceOf(modApi.tileset._class) then
		return tooltips.tileset
	else
		return tooltips.object
	end
end

return {
	get = getTooltip,
	mission = tooltips.mission,
	bossMission = tooltips.bossMission,
	unit = tooltips.unit,
	structure = tooltips.structure,
	islandComposite = tooltips.islandComposite,
	island = tooltips.island,
	ceo = tooltips.ceo,
	tileset = tooltips.tileset,
	object = tooltips.object,
}
