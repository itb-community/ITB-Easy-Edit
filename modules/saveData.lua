
-- header
local path = GetParentPath(...)
local serializer = require(path.."serializer")
local explorer = require(path.."explorer")
local direxists = explorer.direxists
local fileexists = explorer.fileexists
local listdirs = explorer.listdirs
local listfiles = explorer.listfiles
local listobjects = explorer.listobjects
local pruneExtension = explorer.pruneExtension
local remdir = explorer.remdir
local isdir = explorer.isdir
local isfile = explorer.isfile
local modConfig

-- defs
local LOGD = easyEdit.LOG
local LOGDF = easyEdit.LOGF
local DIRS = {
	"units",
	"enemyList",
	"bossList",
	"missionList",
	"structureList",
	"islandComposite",
}

local savedata = {}
local saveRoot = GetSavedataLocation()
local saveLoc = modApi:getCurrentProfilePath().."easyEdit/"
local fullSaveLoc = saveRoot..saveLoc

local function getModConfig()
	if modConfig == nil then
		modConfig = mod_loader:getModConfig()
	end

	return modConfig
end

local function isFromUninstalledMod(result)
	local modId = result and result.mod or nil
	if modId then
		local modConfig = getModConfig()
		local mod = modConfig[modId]

		if mod == nil or not mod.enabled then
			return true
		end
	end

	return false
end


local function loadFromFile(path)
	LOGD("EasyEdit - loadFromFile ../"..path)
	local result

	if path:sub(-4, -1) == ".lua" then
		result = serializer.deserialize(saveRoot..path)
	end

	if isFromUninstalledMod(result) then
		return nil
	end

	return result
end

local function loadFromDir(path, depth)
	LOGD("EasyEdit - loadFromDir ../"..path)
	local result = {}

	if not depth or depth > 0 then
		for _, dir in ipairs(listdirs(saveRoot..path)) do
			result[dir] = loadFromDir(path..dir.."/", depth - 1)
		end
	end

	for _, file in ipairs(listfiles(saveRoot..path)) do
		local id = pruneExtension(file)
		result[id] = loadFromFile(path..file)
	end

	if not next(result) then
		LOGD("EasyEdit - discard result ../"..path)
		return nil
	end

	return result
end

local function saveToFile(cache, path)
	LOGD("EasyEdit - saveToFile ../"..path)

	serializer.configureFile(
		path,
		function(obj)
			clear_table(obj)
			clone_table(obj, cache)
		end
	)
end

local function saveToDir(cache, path)
	LOGD("EasyEdit - saveToDir ../"..path)

	for key, value in pairs(cache) do
		saveToFile(value, path..key..".lua")
	end
end

-- Force load savedata from disc.
function savedata:load()
	self.cache = loadFromDir(saveLoc, 2) or {}
	self:updateLiveData()
end

function savedata:saveAsFile(id, data)
	data = copy_table(data)
	self.cache[id] = data
	saveToFile(data, saveLoc..id..".lua")
end

function savedata:saveAsDir(id, data)
	data = copy_table(data)
	self.cache[id] = data

	if pruneExtension(id) ~= id then
		LOGF("EasyEdit - %q is not a directory", id)
		return
	end

	-- delete lua file with same name as dir
	if isfile(fullSaveLoc..id..".lua") then
		LOGD("EasyEdit - delete "..fullSaveLoc..id..".lua")
		os.remove(fullSaveLoc..id..".lua")
	end

	local dir = id.."/"
	saveToDir(data, saveLoc..dir)

	-- delete lua files of removed objects
	for _, file in ipairs(listfiles(fullSaveLoc..dir)) do
		local id = pruneExtension(file)
		if data[id] == nil then
			if isfile(fullSaveLoc..dir..file) then
				LOGD("EasyEdit - delete "..fullSaveLoc..dir..file)
				os.remove(fullSaveLoc..dir..file)
			end
		end
	end

	self:updateLiveData()
end

function savedata:mkdirs()
	os.mkdir(fullSaveLoc)

	for _, dir in pairs(DIRS) do
		os.mkdir(fullSaveLoc..dir)
	end
end

-- Apply cached savedata to lists and update game objects.
function savedata:updateLiveData()
	for category_id, category in pairs(self.cache) do
		local module = modApi[category_id]
		if module then
			module:update()
		end
	end
end


easyEdit.savedata = savedata

modApi.events.onProfileChanged:subscribe(function(_, newProfile)
	for category_id, category in pairs(easyEdit.savedata.cache) do
		local module = modApi[category_id]
		module:reset()
	end

	modConfig = mod_loader:getModConfig()
	saveLoc = modApi:getCurrentProfilePath().."easyEdit/"
	fullSaveLoc = saveRoot..saveLoc
	easyEdit.savedata:mkdirs()
	easyEdit.savedata:load()
end)
