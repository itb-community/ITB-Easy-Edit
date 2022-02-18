
local path = GetParentPath(...)
local helpers = require(path.."helpers")
local decorate_dynamicContentList = require(path.."helper_dynamicContentList")
local DecoMultiClickButton = require(path.."deco/DecoMultiClickButton")
local DecoButtonExt = require(path.."deco/DecoButtonExt")
local UiDropTarget = require(path.."widget/UiDropTarget")
local UiMultiClickButton = require(path.."widget/UiMultiClickButton")

local getSurface_delete = helpers.getSurface_delete
local getSurface_reset = helpers.getSurface_reset
local getSurface_warning = helpers.getSurface_warning

local OBJECT_LIST_HEIGHT = helpers.OBJECT_LIST_HEIGHT
local ORIENTATION_HORIZONTAL = helpers.ORIENTATION_HORIZONTAL
local COLOR_RED = helpers.COLOR_RED

local function resetContainer(self)
	local container = self.parent
	local contentList = container.contentList
	local objectList = container.data
	objectList:reset()
	decorate_dynamicContentList(contentList, objectList)

	return true
end

local function deleteContainer(self)
	local container = self.parent
	local objectList = container.data
	if objectList:delete() then
		container:detach()
	end

	return true
end

local function createContentListContainer(objectList, dragObject)
	local contentList = UiDropTarget(dragObject:getDragType())
	local resetButton = UiMultiClickButton(2)
	local surface_reset
	local tooltips

	if objectList:isCustom() then
		resetButton.onclicked = deleteContainer
		surface_reset = getSurface_delete()
		tooltips = {
			"Delete content list",
			"WARNING: clicking once more will delete this content list"
		}
	else
		resetButton.onclicked = resetContainer
		surface_reset = getSurface_reset()
		tooltips = {
			"Reset content list",
			"WARNING: clicking once more will reset this content list to its default"
		}
	end

	local container = UiWeightLayout()
	container
		:setVar("data", objectList)
		:setVar("contentList", contentList)
		:width(1)
		:heightpx(OBJECT_LIST_HEIGHT)
		:orientation(ORIENTATION_HORIZONTAL)
		:beginUi(resetButton)
			:widthpx(OBJECT_LIST_HEIGHT)
			:setTooltips(tooltips)
			:decorate{
				DecoButtonExt(nil, COLOR_RED),
				DecoAnchor(),
				DecoMultiClickButton(
					{ surface_reset, getSurface_warning(), },
					"center",
					"center"
				)
			}
		:endUi()
		:beginUi(contentList)
			:setVar("dragObject", dragObject)
			:setVar("resetButton", resetButton)
		:endUi()

	decorate_dynamicContentList(contentList, objectList)

	return container
end

return createContentListContainer
