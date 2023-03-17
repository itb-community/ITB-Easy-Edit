
local vanillaCorporationNames = { "Corp_Grass_Name", "Corp_Desert_Name", "Corp_Snow_Name", "Corp_Factory_Name" }

function easyEdit:getCurrentIslandSlot()
	return list_indexof(vanillaCorporationNames, Game:GetCorp().name)
end
