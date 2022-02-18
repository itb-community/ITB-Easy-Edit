
local savedata = {}

-- Force load savedata from disc.
local function load(self)
	sdlext.config(
		modApi:getCurrentProfilePath().."easyEdit.lua",
		function(obj)
			-- flush cache
			clear_table(self.cache)
			-- save obj to cache
			clone_table(self.cache, obj)
		end
	)
end

-- Save cache to savedata on disc.
-- Load savedata from disc first if cache is empty.
local function save(self)
	sdlext.config(
		modApi:getCurrentProfilePath().."easyEdit.lua",
		function(obj)
			-- flush obj
			clear_table(obj)
			-- save cache to obj
			clone_table(obj, self.cache)
		end
	)
end

-- Apply cached savedata to lists and update game objects.
local function apply(self)
	for category_id, category in pairs(self.cache) do
		local module = modApi[category_id]
		if module then
			module:update()
		end
	end
end

savedata.save = save
savedata.load = load
savedata.apply = apply
savedata.cache = {}

easyEdit.savedata = savedata
