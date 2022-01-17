
IndexedList = Class.new()

function IndexedList:new(class)
	self._class = class
	self._children = {}
end

function IndexedList:add(id, base)
	Assert.Equals('string', type(id), "Argument #1")
	Assert.Equals({'nil', 'string'}, type(base), "Argument #2")
	Assert.Equals('nil', type(self:get(id)), "Entry already exists")

	if type(base) == 'string' then
		base = self:get(base)
	end

	local entry = self._class(id, base)
	self._children[id] = entry

	return entry
end

function IndexedList:get(id)
	return self._children[id]
end

function IndexedList:rem(id)
	self._children[id] = nil
end


IndexedEntry = Class.new()

function IndexedEntry:new(id, base)
	Assert.Equals('string', type(id), "Argument #1")
	Assert.Equals({'nil', 'table'}, type(base), "Argument #2")

	self._id = id
	self:copy(base)
end

function IndexedEntry:copy(base)
	if type(base) ~= 'table' then return end

	for key, value in pairs(base) do
		if not modApi:stringStartsWith(key, "_") then
			self[key] = copy_table(value)
		end
	end
end
