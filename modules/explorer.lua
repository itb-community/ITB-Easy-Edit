
local LOGD = easyEdit.LOG
local LOGDF = easyEdit.LOGF
local ATTEMPTS = 20
local PC_ROOT

local function findroot()
	LOG("EasyEdit - Start search for pc root..")
	local attempts = ATTEMPTS
	local saveLoc = GetSavedataLocation():match("^.*:[\\/](.+)$")
	local saveRoot = saveLoc:match("^([^\\/]+)[\\/].*$")
	LOGD("Savedata path: "..tostring(saveLoc))
	LOGD("Savedata root: "..tostring(saveRoot))

	local root = ""

	while attempts > 0 do
		root = root.."../"
		LOGD("Test prefix: "..root)
		local dirs = mod_loader:enumerateDirectoriesIn(root)
		if list_contains(dirs, saveRoot) then
			LOGD("Found candidate: "..root..saveLoc)
			local saveData = mod_loader:enumerateFilesIn(root..saveLoc)
			if list_contains(saveData, "io_test.txt") then
				LOG("Successfully found pc root!")
				PC_ROOT = root
				break
			end
		end

		attempts = attempts - 1
	end

	if PC_ROOT == nil then
		LOG("Failed to find pc root. Using backup method for searching directories.")
	end
end

local function listdirs(directory)
	directory = directory:gsub("^.*:[\\/]", "")

	if PC_ROOT then
		return os.listdirs(PC_ROOT..directory)
	else
		local i, folders, popen = 0, {}, io.popen
		local pfile = popen(string.format("dir %q /b /ad", directory))

		for foldername in pfile:lines() do
			i = i + 1
			folders[i] = foldername
		end

		pfile:close()

		return folders
	end
end

local function listfiles(directory)
	directory = directory:gsub("^.*:[\\/]", "")

	if PC_ROOT then
		return os.listfiles(PC_ROOT..directory)
	else
		local i, files, popen = 0, {}, io.popen
		local pfile = popen(string.format("dir %q /b /a-d", directory))

		for filename in pfile:lines() do
			i = i + 1
			files[i] = filename
		end

		pfile:close()

		return files
	end
end

local function listobjects(directory)
	directory = directory:gsub("^.*:[\\/]", "")

	if PC_ROOT then
		return os.listfiles(PC_ROOT..directory)
	else
		local i, objects, popen = 0, {}, io.popen
		local pfile = popen(string.format("dir %q /b", directory))

		for name in pfile:lines() do
			i = i + 1
			objects[i] = name
		end

		pfile:close()

		return objects
	end
end

local function isdir(path)
	return modApi:directoryExists(path)
end

local function isfile(path)
	return modApi:fileExists(path)
end

local function pruneExtension(path)
	return string.gsub(path, "[.][^.]*$", "")
end


return {
	findroot = findroot,
	listdirs = listdirs,
	listfiles = listfiles,
	listobjects = listobjects,
	pruneExtension = pruneExtension,
	isdir = isdir,
	isfile = isfile,
}
