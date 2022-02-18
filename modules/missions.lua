
local Mission = Class.inherit(IndexedEntry)
Mission._debugName = "Mission"
Mission._entryType = "missions"
Mission._iconDef = {
	width = 90,
	height = 60,
	scale = 2,
	pathformat = "img/strategy/mission/small/%s.png",
}
Mission._tooltipDef = {
	width = 120,
	height = 120,
	scale = 2,
	pathformat = "img/strategy/mission/%s.png",
}

function Mission:getName()
	return self.Name or self._id
end

function Mission:getCategory()
	return nil
end

function Mission:getDragType()
	return "MISSION"
end

modApi.missions = IndexedList(Mission)
