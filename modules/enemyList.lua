
function shuffle_list(list)
	for i = #list, 2, -1 do
		local j = math.random(1, i)

		-- swap entries
		list[i], list[j] = list[j], list[i]
	end
end

local EnemyList = Class.inherit(IndexedEntry)

function EnemyList:new(id, base)
	self.enemies = {}
	self.categories = { "Core", "Core", "Core", "Leaders", "Unique", "Unique" },
	IndexedEntry.new(self, id, base)
end

function EnemyList:copy(base)
	if type(base) ~= 'table' then return end

	self.enemies = copy_table(base.enemies)
	self.categories = copy_table(base.categories)
end

function EnemyList:addEnemy(enemy, category)
	Assert.Equals('string', type(enemy), "Argument #1")
	Assert.Equals('string', type(category), "Argument #2")

	self.enemies[category] = self.enemies[category] or {}
	table.insert(self.enemies[category], enemy)
end

function EnemyList:pickEnemies(islandNumber, timesPicked)
	timesPicked = timesPicked or {}
	local result = {}
	local choices = {}
	local excluded = {}

	local exclusiveReversed = {}
	for i, v in ipairs(ExclusiveElements) do
		exclusiveReversed[v] = i
	end

	local function isUnlocked(unit)
		local lock = IslandLocks[unit] or 4
		return islandNumber == nil or islandNumber >= lock or Game:IsIslandUnlocked(lock-1)
	end

	local function addExclusions(unit)
		if ExclusiveElements[unit] then
			excluded[ExclusiveElements[unit]] = true
		end
		if exclusiveReversed[unit] then
			excluded[exclusiveReversed[unit]] = true
		end
	end

	local function getEnemyChoices(category)
		if type(category) ~= 'string' then
			return {}
		end

		if choices[category] and #choices[category] > 0 then
			return choices[category]
		end

		local leastPicked = INT_MAX

		choices[category] = {}
		self.enemies[category] = self.enemies[category] or {}
		for _, enemy in ipairs(self.enemies[category]) do
			if isUnlocked(enemy) and not excluded[enemy] then
				table.insert(choices[category], enemy)
			end
		end

		shuffle_list(choices[category])
		table.sort(choices[category], function(a,b)
			return (timesPicked[a] or 0) > (timesPicked[b] or 0)
		end)

		return choices[category]
	end

	for _, category in ipairs(self.categories) do
		local enemyChoices = getEnemyChoices(category)
		local choice = "Scorpion"

		for i = #enemyChoices, 1, -1 do
			if not excluded[enemyChoices[i]] then
				choice = enemyChoices[i]
				table.remove(enemyChoices, i)

				break
			end
		end

		timesPicked[choice] = (timesPicked[choice] or 0) + 1
		addExclusions(choice)
		table.insert(result, choice)
	end

	Assert.Equals(6, #result, "Result")

	return result
end


modApi.enemyList = IndexedList(EnemyList)
