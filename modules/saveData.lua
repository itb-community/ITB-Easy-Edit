
-- header
local path = GetParentPath(...)

local modules = {
	easyEdit.enemyList,
	easyEdit.missionList,
	easyEdit.bossList,
	easyEdit.structureList,
	easyEdit.islandComposite,
	easyEdit.world,
}

-- defs
local DIRS = {
	"enemyList",
	"bossList",
	"missionList",
	"structureList",
	"islandComposite",
}

local savedata = {}
local profilePath
local modConfig

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
	LOGD("EasyEdit - Load from file ../"..path)
	local result

	local file = Directory.savedata():file(path)
	if file:extension() == "lua" and file:exists() then
		result = persistence.load(file:path())
	end

	if isFromUninstalledMod(result) then
		return nil
	end

	return result
end

local function loadFromDir(path, depth)
	LOGD("EasyEdit - Load from dir ../"..path)
	local result = {}

	if not depth or depth > 0 then
		for _, dir in ipairs(Directory.savedata():directory(path):directories()) do
			local name = dir:name()
			result[dir:name()] = loadFromDir(path..name.."/", depth - 1)
		end
	end

	for _, file in ipairs(Directory.savedata():directory(path):files()) do
		local name = file:name()
		local id = file:name_without_extension()
		result[id] = loadFromFile(path..name)
	end

	if not next(result) then
		LOGD("EasyEdit - Nothing to load from ../"..path)
		return nil
	end

	LOGD("EasyEdit - Loading from ../"..path)

	return result
end

local function saveToFile(cache, path)
	LOGD("EasyEdit - Save to file ../"..path)

	sdlext.config(
		path,
		function(obj)
			clear_table(obj)
			merge_table(obj, cache)
		end
	)
end

local function saveToDir(cache, path)
	LOGD("EasyEdit - Save to dir ../"..path)

	for key, value in pairs(cache) do
		saveToFile(value, path..key..".lua")
	end
end

-- Force load savedata from disc.
function savedata:load()
	if self.currentProfile == nil then
		Assert.Error("No current profile")
	end

	LOGF("EasyEdit - Load savedata for profile [%s]", self.currentProfile)
	self.cache = loadFromDir(profilePath, 2) or {}
	self:updateLiveData()
end

function savedata:saveAsFile(id, data)
	if self.currentProfile == nil then
		Assert.Error("No current profile")
	end

	data = copy_table(data)
	self.cache[id] = data
	saveToFile(data, profilePath..id..".lua")
end

function savedata:saveAsDir(id, data)
	if self.currentProfile == nil then
		Assert.Error("No current profile")
	end

	data = copy_table(data)
	self.cache[id] = data

	if File(id):extension() ~= nil then
		LOGF("EasyEdit - %q is not a directory", id)
		return
	end

	-- delete lua file with same name as dir
	local file = Directory.savedata():directory(profilePath):file(id..".lua")
	if file:exists() then
		LOGD("EasyEdit - delete "..file:path())
		file:delete()
	end

	local dir = id.."/"
	saveToDir(data, profilePath..dir)

	-- delete lua files of removed objects
	local files = Directory.savedata():directory(profilePath):directory(dir):files()
	for _, file in ipairs(files) do
		local id = file:name_without_extension()
		if data[id] == nil then
			LOGD("EasyEdit - delete "..file:path())
			file:delete()
		end
	end

	self:updateLiveData()
end

function savedata:mkdirs()
	if self.currentProfile == nil then
		Assert.Error("No current profile")
	end

	local root = Directory.savedata():directory(profilePath)
	root:make_directories()

	for _, dir in pairs(DIRS) do
		root:directory(dir):make_directories()
	end
end

-- Apply cached savedata to lists and update game objects.
function savedata:updateLiveData()
	LOG("EasyEdit - Update livedata")
	for _, module in ipairs(modules) do
		module:update()
	end
end

local function changeEasyEditProfile(_, newProfile)
	local oldProfile = easyEdit.savedata.currentProfile
	if oldProfile ~= nil then
		LOGF("EasyEdit - Unset profile [%s]", oldProfile)
		LOGF("EasyEdit - Unload savedata for profile [%s]", oldProfile)
		LOG("EasyEdit - Update livedata")
		for _, module in ipairs(modules) do
			module:reset()
		end
	end

	if newProfile == "" then
		newProfile = nil
	end

	easyEdit.savedata.currentProfile = newProfile
	if newProfile == nil then
		return
	end

	LOGF("EasyEdit - Set profile [%s]", newProfile)
	modConfig = mod_loader:getModConfig()
	profilePath = "easyEdit_"..newProfile.."/"
	easyEdit.savedata:mkdirs()
	easyEdit.savedata:load()
end

function savedata:init()
	if savedata.initialized then
		return
	end

	savedata.initialized = true
	changeEasyEditProfile(nil, Settings.last_profile)
end

easyEdit.savedata = savedata

modApi.events.onProfileChanged:subscribe(changeEasyEditProfile)
