
local BossList = Class.inherit(IndexedEntry)
BossList._debugName = "BossList"
BossList._entryType = "bossList"

function BossList:new(id, base)
	IndexedEntry.new(self, id, base)
	self["Bosses"] = {}
end

function BossList:copy(base)
	if type(base) ~= 'table' then return end

	if base.OldUniqueBosses then
		self.Bosses = add_arrays(base.Bosses, base.OldUniqueBosses)
	else
		self.Bosses = copy_table(base.Bosses)
	end
end

function BossList:addBoss(boss)
	Assert.Equals('string', type(boss), "Argument #1")

	table.insert(self.Bosses, boss)
end

function BossList:getCategories()
	return { Bosses = self.Bosses }
end

function BossList:getObject(missionId)
	return easyEdit.missions:get(missionId)
end

function BossList:isContentList()
	return true
end

function BossList:getContentType()
	return easyEdit.missions
end

function BossList:isInvalid()
	for categoryId, category in pairs(self:getCategories()) do
		for _, bossMissionId in ipairs(category) do
			if _G[bossMissionId] == nil then
				return true
			end
		end
	end

	return false
end

local BossLists = IndexedList(BossList)

function BossLists:update()
	IndexedList.update(self)

	local bossList = easyEdit.bossList:get("finale1")
	local unitList = {}

	for _, bossMissionId in ipairs(bossList.Bosses) do
		local bossMission = easyEdit.missions:get(bossMissionId)
		if bossMission then
			unitList[#unitList+1] = bossMission.BossPawn
		end
	end
	Mission_Final.BossList = unitList

	local bossList = easyEdit.bossList:get("finale2")
	local unitList = {}

	for _, bossMissionId in ipairs(bossList.Bosses) do
		local bossMission = easyEdit.missions:get(bossMissionId)
		if bossMission then
			unitList[#unitList+1] = bossMission.BossPawn
		end
	end
	Mission_Final_Cave.BossList = unitList
end


easyEdit.bossList = BossLists
