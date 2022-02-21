
-- defs
local CATEGORIES = {
	[REWARD_REP] = "RepAssets",
	[REWARD_POWER] = "PowAssets",
	[REWARD_TECH] = "TechAssets",
}

local Structure = Class.inherit(IndexedEntry)
Structure._debugName = "Structure"
Structure._entryType = "structures"
Structure._iconDef = {
	width = 90,
	height = 60,
	scale = 2,
	pathformat = "img/combat/structures/%s_on.png",
	pathtoken = "Image",
}
Structure._tooltipDef = {
	width = 90,
	height = 60,
	scale = 2,
	clip = true,
	pathformat = "img/combat/structures/%s_on.png",
	pathtoken = "Image",
}

function Structure:getName()
	return self.Name or self._id
end

function Structure:getCategory()
	return CATEGORIES[self.Reward]
end

function Structure:getDragType()
	return "STRUCTURE"
end


modApi.structures = IndexedList(Structure)
