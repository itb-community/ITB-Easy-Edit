
local MissionList = Class.inherit(IndexedEntry)
MissionList._debugName = "MissionList"
MissionList._entryType = "missionList"

function MissionList:new(id, base)
	IndexedEntry.new(self, id, base)
	self.Missions_High = {}
	self.Missions_Low = {}
end

function MissionList:copy(base)
	if type(base) ~= 'table' then return end

	self.Missions_High = copy_table(base.Missions_High)
	self.Missions_Low = copy_table(base.Missions_Low)
end

function MissionList:addMission(mission, isHighThreat)
	Assert.Equals('string', type(mission), "Argument #1")
	Assert.Equals('boolean', type(isHighThreat), "Argument #2")

	if isHighThreat then
		table.insert(self.Missions_High, mission)
	else
		table.insert(self.Missions_Low, mission)
	end
end

function MissionList:getCategories()
	return self
end

function MissionList:getObject(missionId)
	return modApi.missions:get(missionId)
end

function MissionList:isContentList()
	return true
end

function MissionList:getContentType()
	return modApi.missions
end


modApi.missionList = IndexedList(MissionList)
