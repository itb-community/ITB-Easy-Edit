
-- header
local path = GetParentPath(...)
local helpers = require(path.."helpers")
local decorate = require(path.."helper_decorate")
local condensedContentList = require(path.."helper_condensedContentList")
local DecoIcon = require(path.."deco/DecoIcon")
local DecoLabel = require(path.."deco/DecoLabel")

-- defs
local LIST_HEIGHT = 20
local LIST_GAP = 30
local HEADER_HEIGHT = 180
local ORIENTATION_HORIZONTAL = helpers.ORIENTATION_HORIZONTAL
local ORIENTATION_VERTICAL = helpers.ORIENTATION_VERTICAL
local CEO_ICON_DEF = modApi.ceo:getIconDef()
local TILESET_ICON_DEF = modApi.tileset:getIconDef()
local PAD_L = 40
local PAD_R = 40
local PAD_T = 20
local PAD_B = 40

-- ui
UiTooltipIslandComposite = Class.inherit(UiWeightLayout)
function UiTooltipIslandComposite:new()
	UiWeightLayout.new(self)
	self._debugName = "UiTooltipIslandComposite"

	self.staticTooltip = true
	self.decoCeo_label = DecoLabel(nil, "center", "bottom")
	self.decoTileset_label = DecoLabel(nil, "center", "bottom")
	self.uiCeo_icon = Ui()
	self.uiTileset_icon = Ui()
	self.uiEnemyList = Ui()
	self.uiBossList = Ui()
	self.uiMissionList = Ui()
	self.uiStructureList = Ui()

	self
		:vgap(0)
		:widthpx(400)
		:setVar("padt", PAD_T)
		:setVar("padb", PAD_B)
		:orientation(ORIENTATION_VERTICAL)
		:heightpx(0
			+ PAD_T + PAD_B
			+ HEADER_HEIGHT
			+ LIST_HEIGHT * 4
			+ LIST_GAP * 5
		)
		:decorate{ DecoFrame() }
		:beginUi()
			:heightpx(HEADER_HEIGHT)
			:beginUi(UiWeightLayout)
				:size(1,1)
				:hgap(0)
				:orientation(ORIENTATION_HORIZONTAL)
				:beginUi()
					:width(0.5)
					:decorate{
						DecoLabel("CEO", "center", "top"),
						DecoAnchor(),
						self.decoCeo_label,
					}
					:beginUi(self.uiCeo_icon)
						:anchor("center", "center")
						:widthpx(CEO_ICON_DEF.width * CEO_ICON_DEF.scale)
						:heightpx(CEO_ICON_DEF.height * CEO_ICON_DEF.scale)
						:decorate{ DecoFrame() }
					:endUi()
				:endUi()
				:beginUi()
					:widthpx(2)
					:decorate{ DecoSolid(deco.colors.buttonborder) }
				:endUi()
				:beginUi()
					:width(0.5)
					:decorate{
						DecoLabel("TILESET", "center", "top"),
						DecoAnchor(),
						self.decoTileset_label,
					}
					:beginUi(self.uiTileset_icon)
						:anchor("center", "center")
						:widthpx(TILESET_ICON_DEF.width * TILESET_ICON_DEF.scale)
						:heightpx(TILESET_ICON_DEF.height * TILESET_ICON_DEF.scale)
						:decorate{ DecoFrame() }
					:endUi()
				:endUi()
			:endUi()
		:endUi()
		:beginUi()
			:heightpx(LIST_GAP * 2)
			:setVar("padl", PAD_L)
			:setVar("padr", PAD_R)
			:beginUi()
				:anchorV("center")
				:heightpx(2)
				:decorate{ DecoSolid(deco.colors.buttonborder) }
			:endUi()
		:endUi()
		:beginUi(UiBoxLayout)
			:setVar("padl", PAD_L)
			:setVar("padr", PAD_R)
			:vgap(LIST_GAP)
			:add(self.uiEnemyList)
			:add(self.uiBossList)
			:add(self.uiMissionList)
			:add(self.uiStructureList)
		:endUi()
end

function UiTooltipIslandComposite:onCustomTooltipShown(hoveredUi)
	local islandComposite = hoveredUi.data

	self.uiCeo_icon:removeDeco(2)
	self.uiTileset_icon:removeDeco(2)

	if islandComposite == nil then
		self.decoCeo_label:setsurface("")
		self.decoTileset_label:setsurface("")
		condensedContentList(self.uiEnemyList, nil)
		condensedContentList(self.uiBossList, nil)
		condensedContentList(self.uiMissionList, nil)
		condensedContentList(self.uiStructureList, nil)
		return
	end

	-- local island = modApi.island:get(islandComposite.island)
	local ceo = modApi.ceo:get(islandComposite.ceo)
	local tileset = modApi.tileset:get(islandComposite.tileset)
	local enemyList = modApi.enemyList:get(islandComposite.enemyList)
	local bossList = modApi.bossList:get(islandComposite.bossList)
	local missionList = modApi.missionList:get(islandComposite.missionList)
	local structureList = modApi.structureList:get(islandComposite.structureList)

	self.decoCeo_label:setsurface(ceo:getName())
	self.decoTileset_label:setsurface(tileset:getName())
	self.uiCeo_icon:insertDeco(2, DecoIcon(ceo, ceo:getIconDef()))
	self.uiTileset_icon:insertDeco(2, DecoIcon(tileset, tileset:getIconDef()))

	condensedContentList(self.uiEnemyList, enemyList)
	condensedContentList(self.uiBossList, bossList)
	condensedContentList(self.uiMissionList, missionList)
	condensedContentList(self.uiStructureList, structureList)
end

return UiTooltipIslandComposite()
