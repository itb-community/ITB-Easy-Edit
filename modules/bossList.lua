
local BossList = Class.inherit(IndexedEntry)

function BossList:new(id, base)
	self.Bosses = {}
	self.UniqueBosses = {}
	IndexedEntry.new(self, id, base)
end

function BossList:copy(base)
	if type(base) ~= 'table' then return end

	self.Bosses = copy_table(base.Bosses)
	self.UniqueBosses = copy_table(base.UniqueBosses)
end

function BossList:addBoss(boss)
	Assert.Equals('string', type(boss), "Argument #1")

	table.insert(self.UniqueBosses, boss)
end


modApi.bossList = IndexedList(BossList)
