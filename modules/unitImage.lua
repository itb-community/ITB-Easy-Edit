
local Unit = modApi.units._class
local UnitImage = Class.inherit(IndexedEntry)
UnitImage._debugName = "UnitImage"
UnitImage._entryType = "unitImage"
UnitImage._iconDef = {
	width = 60,
	height = 60,
	scale = 2,
	outlinecolor = deco.colors.buttonborder,
	outlinecolorhl = deco.colors.buttonborderhl,
}

UnitImage.isMech = Unit.isMech
UnitImage.isEnemy = Unit.isEnemy
UnitImage.isBot = Unit.isBot
UnitImage.isMission = Unit.isMission

modApi.unitImage = IndexedList(UnitImage)
