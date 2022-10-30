
local path = GetParentPath(...)
local DecoUnit = require(path.."DecoUnit")
local DecoIcon = require(path.."DecoIcon")

return function(obj, ...)
	if obj:instanceOf(easyEdit.units._class) then
		return DecoUnit(obj, ...)
	elseif obj:instanceOf(easyEdit.missions._class) then
		if obj.BossPawn then
			local missionObj = obj
			obj = easyEdit.units:get(missionObj.BossPawn)
			if obj == nil then
				Assert.Error("Invalid BossPawn")
			end
			return DecoUnit(obj, ...)
		end
	elseif not obj:instanceOf(IndexedEntry) then
		return DecoUnit(obj, ...)
	end

	return DecoIcon(obj, ...)
end
