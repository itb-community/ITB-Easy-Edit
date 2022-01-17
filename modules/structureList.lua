
local StructureList = Class.inherit(IndexedEntry)

function StructureList:new(id, base)
	self.PowAssets = {}
	self.TechAssets = {}
	self.RepAssets = {}
	IndexedEntry.new(self, id, base)
end

function StructureList:copy(base)
	if type(base) ~= 'table' then return end

	self.PowAssets = copy_table(base.PowAssets)
	self.TechAssets = copy_table(base.TechAssets)
	self.RepAssets = copy_table(base.RepAssets)
end

function StructureList:addAssets(...)
	local args = select("#", ...)
	for i = 1, args do
		local structure = select(i, ...)
		Assert.Equals('string', type(structure), "Argument #".. i)
		Assert.Equals('table', type(_G[structure]), "Invalid entry")

		local str = _G[structure]
		if str.Reward == REWARD_REP then
			table.insert(self.RepAssets, structure)
		elseif str.Reward == REWARD_POWER then
			table.insert(self.PowAssets, structure)
		elseif str.Reward == REWARD_TECH then
			table.insert(self.TechAssets, structure)
		else
			error("Unexpected structure reward: Expected number in range [0,2], but was "..tostring(str.Reward))
		end
	end
end

function StructureList:addPowAssets(...)
	local args = select("#", ...)
	for i = 1, args do
		local structure = select(i, ...)
		Assert.Equals('string', type(structure), "Argument #".. i)

		table.insert(self.PowAssets, structure)
	end
end

function StructureList:addTechAssets(...)
	local args = select("#", ...)
	for i = 1, args do
		local structure = select(i, ...)
		Assert.Equals('string', type(structure), "Argument #".. i)

		table.insert(self.TechAssets, structure)
	end
end

function StructureList:addRepAssets(...)
	local args = select("#", ...)
	for i = 1, args do
		local structure = select(i, ...)
		Assert.Equals('string', type(structure), "Argument #".. i)

		table.insert(self.RepAssets, structure)
	end
end


modApi.structureList = IndexedList(StructureList)
