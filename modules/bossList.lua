
local BossList = Class.inherit(IndexedEntry)
BossList._debugName = "BossList"
BossList._entryType = "bossList"

function BossList:new(id, base)
	IndexedEntry.new(self, id, base)
	self["Bosses"] = {}
end

function BossList:copy(base)
	if type(base) ~= 'table' then return end

	if base.UniqueBosses then
		self.Bosses = add_arrays(base.Bosses, base.UniqueBosses)
	else
		self.Bosses = copy_table(base.Bosses)
	end
end

function BossList:addBoss(boss)
	Assert.Equals('string', type(boss), "Argument #1")

	table.insert(self.Bosses, boss)
end

function BossList:getCategories()
	return self
end

function BossList:getObject(missionId)
	return modApi.missions:get(missionId)
end

function BossList:isContentList()
	return true
end

function BossList:getContentType()
	return modApi.missions
end


modApi.bossList = IndexedList(BossList)
