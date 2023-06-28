
local Squad = Class.inherit(IndexedEntry)
Squad._debugName = "Squad"
Squad._entryType = "squad"

function Squad:new(id, base)
	IndexedEntry.new(self, id, base)
	self._default.name = "Unnamed Squad"
	self._default.mechs = {}
end

function Squad:copy(base)
	if type(base) ~= 'table' then return end

	self.mechs = copy_table(base.mechs)
end

function Squad:addMech(mech)
	Assert.Equals('string', type(mech), "Argument #1")

	table.insert(self.mechs, mech)
end

function Squad:getCategories()
	return { Mechs = self.mechs }
end

function Squad:getObject(unitId)
	return easyEdit.units:get(unitId)
end

function Squad:getContentType()
	return easyEdit.units
end

function Squad:isInvalid()
	return #self.mechs ~= 3
end


easyEdit.squads = IndexedList(Squad)
