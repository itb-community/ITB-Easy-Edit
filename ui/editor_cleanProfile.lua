
local EDITOR_TITLE = "Easy Edit Savedata"
local DIALOG_TEXT = ""
	.."Old Easy Edit savedata detected in the following "
	.."profiles:\n%s\n\n"
	.."Extra folders in a profile folder prevents Into the "
	.."Breach from being able to delete the profile.\n"
	.."Easy Edit no longer stores its savedata directly in "
	.."the profile folder, but instead in separate folder "
	.."one level up.\n"
	.."If this data is valuable to you, you should make "
	.."a backup of it now, so you can transfer it to the "
	.."new location.\n"
	.."NOTE: any lingering bugs in the "
	.."old savedata that might have been fixed would then "
	.."be transfered as well.\n\n"
	.."Please manually delete the old Easy Edit savedata."

local easyEditDirectoriesText

local function getProfileDirsSorted()
	local profileDirs = {}
	local dirs = Directory.savedata():directories()

	for _, dir in ipairs(dirs) do
		local name = dir:name()
		if name:sub(1,8):lower() == "profile_" then
			profileDirs[#profileDirs + 1] = name
		end
	end

	stablesort(profileDirs, function(a, b)
		return alphanum(a:lower(), b:lower())
	end)

	return profileDirs
end

local function openSavedata()
	local command = ('"explorer "'..Directory.savedata():path()..'""'):gsub("/","\\")
	io.popen(command)
end

local function buildFrameContent(scroll)
	local text = string.format(DIALOG_TEXT, easyEditDirectoriesText)
	local font = deco.uifont.tooltipTextLarge.font
	local textset = deco.uifont.tooltipTextLarge.set
	scroll.wrap = UiWrappedText(text, font, textset)
		:size(1,1)
		:addTo(scroll)
end

local function buildFrameButtons(buttonLayout)
	sdlext.buildButton(
		"Open savedata",
		"Opens the savedata folder on your computer.",
		openSavedata
 	):addTo(buttonLayout)
end

modApi.events.onUiRootCreated:subscribe(function()
	local profileDirs = getProfileDirsSorted()
	local easyEditDirs = {}

	for _, profileDir in ipairs(profileDirs) do
		local easyEditDir = Directory(Directory.savedata():path().."/"..profileDir.."/easyEdit/")
		if easyEditDir:exists() then
			easyEditDirs[#easyEditDirs + 1] = easyEditDir:name()
		end
	end

	if #easyEditDirs == 0 then
		return
	end

	easyEditDirectoriesText = table.concat(easyEditDirs, "\n")

	sdlext.showDialog(function(ui, quit)
		ui.onDialogExit = onExit

		local frame = sdlext.buildButtonDialog(
			EDITOR_TITLE,
			buildFrameContent,
			buildFrameButtons
		)

		frame
			:addTo(ui)
			:sizepx(700, 600)
			:anchor("center", "center")
		frame:relayout()
		frame.scroll.wrap.pixelWrap = true
		frame.scroll.wrap:rebuild()
	end)
end)
