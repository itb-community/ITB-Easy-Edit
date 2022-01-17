
local function getModPath()
	local mod = modApi:getCurrentMod()
	return mod.resourcePath
end

local Corporation = Class.inherit(IndexedEntry)

function Corporation:new(id, base)
	self:copy(Corp_Default)
	IndexedEntry.new(self, id, base)
end

function Corporation:copy(base)
	if type(base) ~= 'table' then return end

	self.Name = base.Name
	self.Description = base.Description
	self.Bark_Name = base.Bark_Name
	self.Pilot = base.Pilot
	self.Color = base.Color
	self.Music = shallow_copy(base.Music or {})
	self.Map = shallow_copy(base.Map or {})
end


local Ceo = Class.inherit(IndexedEntry)

function Ceo:new(id, base)
	self:copy(Corp_Default)
	IndexedEntry.new(self, id, base)
end

function Ceo:copy(base)
	if type(base) ~= 'table' then return end

	self.Office = base.Office
	self.CEO_Name = base.CEO_Name
	self.CEO_Image = base.CEO_Image
	self.CEO_Personality = base.CEO_Personality
end

function Ceo:setPortrait(path_ceo_image)
	Assert.ModInitializingOrLoading()
	Assert.FileRelativeToCurrentModExists(path_ceo_image, "Argument #1")

	self.CEO_Image = self._id ..".png"

	local modPath = getModPath()
	modApi:appendAsset(string.format("img/portraits/ceo/%s.png", self._id), modPath .. path_ceo_image)
end

function Ceo:setPersonality(personality)
	Assert.Equals('table', type(personality), "Argument #1")

	personality.Label = personality.Label or PilotPersonality.Label
	personality.Name = personality.Name or PilotPersonality.Name
	personality.GetPilotDialog = personality.GetPilotDialog or PilotPersonality.GetPilotDialog

	self.CEO_Name = personality.Name
	self.CEO_Personality = "CEO_".. self._id

	Personality[self.CEO_Personality] = personality
end

function Ceo:setOffice(path_office_large, path_office_small)
	Assert.ModInitializingOrLoading()
	Assert.FileRelativeToCurrentModExists(path_office_large, "Argument #1")
	Assert.FileRelativeToCurrentModExists(path_office_small, "Argument #2")

	self.Office = self._id

	local modPath = getModPath()
	modApi:appendAsset(string.format("img/ui/corps/%s.png", self._id), modPath .. path_office_large)
	modApi:appendAsset(string.format("img/ui/corps/%s_small.png", self._id), modPath .. path_office_small)
end


modApi.corporation = IndexedList(Corporation)
modApi.corporation.ceo = IndexedList(Ceo)
