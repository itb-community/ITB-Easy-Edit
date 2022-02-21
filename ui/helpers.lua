
local path = GetParentPath(...)
local DecoButtonExt = require(path.."deco/DecoButtonExt")
local DecoMultiClickButton = require(path.."deco/DecoMultiClickButton")
local DecoObj = require(path.."deco/DecoObj")
local DecoBounceLabel = require(path.."deco/DecoBounceLabel")
local UiMultiClickButton = require(path.."widget/UiMultiClickButton")
local UiScrollAreaExt = require(path.."widget/UiScrollAreaExt")
local UiScrollArea = UiScrollAreaExt.vertical
local UiScrollAreaH = UiScrollAreaExt.horizontal
local UiEditBox = require(path.."widget/UiEditBox")
local UiDragObject = require(path.."widget/UiDragObject")
local UiDragSource = require(path.."widget/UiDragSource")
local UiDropTarget = require(path.."widget/UiDropTarget")
local DEBUG_COLOR_CONTENT = sdl.rgba(100, 100, 255, 100)
local DEBUG_COLOR_SCROLL = sdl.rgba(255, 100, 100, 100)
local DEBUG_COLOR_ENTRY = sdl.rgba(100, 255, 100, 100)
local FONT_TITLE = sdlext.font("fonts/JustinFont12Bold.ttf", 16)
local TEXT_SETTINGS_TITLE = deco.uifont.default.set
local FONT_LABEL = sdlext.font("fonts/JustinFont12Bold.ttf", 12)
local TEXT_SETTINGS_LABEL = deco.uifont.default.set
local ENTRY_HEIGHT = 60
local LABEL_HEIGHT = 19
local OBJECT_LIST_HEIGHT = 40
local OBJECT_LIST_PADDING = 23
local OBJECT_LIST_GAP = 53
local SCROLL_BAR_WIDTH = 16
local COLOR_GREEN = sdl.rgb(64, 196, 64)
local COLOR_YELLOW = sdl.rgb(192, 192, 64)
local COLOR_RED = sdl.rgb(192, 32, 32)
local ORIENTATION_VERTICAL = false
local ORIENTATION_HORIZONTAL = true

local function getSurface_delete()
	return sdlext.getSurface{
		path = "img/ui/easyEdit/delete.png",
		transformations = { { multiply = COLOR_RED } }
	}
end

local function getSurface_reset()
	return sdlext.getSurface{
		path = "img/ui/easyEdit/reset.png",
		transformations = { { multiply = COLOR_RED } }
	}
end

local function getSurface_warning()
	return sdlext.getSurface{
		path = "img/ui/warning_symbol.png",
		transformations = { { multiply = COLOR_RED } }
	}
end

local function getSurface_delete_small()
	return sdlext.getSurface{
		path = "img/ui/easyEdit/delete_small.png",
		transformations = { { multiply = COLOR_RED } }
	}
end

local function getSurface_reset_small()
	return sdlext.getSurface{
		path = "img/ui/easyEdit/reset_small.png",
		transformations = { { multiply = COLOR_RED } }
	}
end

local function getSurface_warning_small()
	return sdlext.getSurface{
		path = "img/ui/easyEdit/warning_small.png",
		transformations = { { multiply = COLOR_RED } }
	}
end


local function createUiTitle(text)
	return Ui()
		:heightpx(ENTRY_HEIGHT)
		:decorate{
			DecoFrame(),
			DecoText(text, FONT_TITLE, TEXT_SETTINGS_TITLE),
		}
end

local function createUiLabel(...)
	local ui = Ui()

	ui:anchorH("center")
	ui:decorate{ DecoText(...) }
	ui:widthpx(ui.decorations[1].surface:w())
	ui:heightpx(ui.decorations[1].surface:h())

	return ui
end

local function createUiEditBox(class, ...)
	local ui = class(...)
	UiEditBox.registerAsEditBox(ui)

	return ui
end

local function isGroupHighlighted(deco, widget)
	local groupOwner = widget:getGroupOwner()

	return groupOwner:findDescendentWhere(function(descendent)
		return descendent.hovered or descendent.dragHovered
	end)
end

local function isGroupDropTarget(deco, widget, draggedElement)
	return draggedElement ~= nil
end

local function createDecoGroupButtonDropTarget()
	local decoration = DecoButtonExt()
	decoration.droptargetcolor = deco.colors.buttonhl
	decoration.borderdroptargetcolor = deco.colors.buttonborder
	decoration.isHighlighted = isGroupHighlighted
	decoration.isDropTarget = isGroupDropTarget

	return decoration
end

local function createDecoGroupButton()
	local decoration = DecoButtonExt()
	decoration.isHighlighted = isGroupHighlighted

	return decoration
end

local function onGroupClicked(self)
	local groupOwner = self:getGroupOwner()

	if groupOwner.onclicked then
		return groupOwner:onclicked()
	end

	return false
end

local function findUiInListAt(list, x)
	local key, value = next(list)
	for k, ui in pairs(list) do
		if x < value.screenx then
			if ui.screenx < value.screenx then
				key, value = k, ui
			end
		elseif x > value.screenx + value.w then
			if ui.screenx > value.screenx then
				key, value = k, ui
			end
		else
			break
		end
	end

	return key, value
end

return {
	ORIENTATION_HORIZONTAL = ORIENTATION_HORIZONTAL,
	ORIENTATION_VERTICAL = ORIENTATION_VERTICAL,
	COLOR_GREEN = COLOR_GREEN,
	COLOR_YELLOW = COLOR_YELLOW,
	COLOR_RED = COLOR_RED,
	FONT_TITLE = FONT_TITLE,
	FONT_LABEL = FONT_LABEL,
	ENTRY_HEIGHT = ENTRY_HEIGHT,
	LABEL_HEIGHT = LABEL_HEIGHT,
	TEXT_SETTINGS_TITLE = TEXT_SETTINGS_TITLE,
	TEXT_SETTINGS_LABEL = TEXT_SETTINGS_LABEL,
	OBJECT_LIST_HEIGHT = OBJECT_LIST_HEIGHT,
	OBJECT_LIST_PADDING = OBJECT_LIST_PADDING,
	OBJECT_LIST_GAP = OBJECT_LIST_GAP,
	SCROLL_BAR_WIDTH = SCROLL_BAR_WIDTH,
	getSurface_delete = getSurface_delete,
	getSurface_reset = getSurface_reset,
	getSurface_warning = getSurface_warning,
	getSurface_reset_small = getSurface_reset_small,
	getSurface_delete_small = getSurface_delete_small,
	getSurface_warning_small = getSurface_warning_small,
	onGroupClicked = onGroupClicked,
	isGroupHighlighted = isGroupHighlighted,
	createUiTitle = createUiTitle,
	createUiLabel = createUiLabel,
	createUiEditBox = createUiEditBox,
	createDecoGroupButton = createDecoGroupButton,
	createDecoGroupButtonDropTarget = createDecoGroupButtonDropTarget,
	createDecoIcon = createDecoIcon,
	findUiInListAt = findUiInListAt,
}
