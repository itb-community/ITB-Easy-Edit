
-- header
local path = GetParentPath(...)
local DecoImmutable = require(path.."deco/DecoImmutable")
local UiScrollAreaExt = require(path.."widget/UiScrollAreaExt")
local UiScrollAreaH = UiScrollAreaExt.horizontal

local function addStaticContentList1x(self, data)
	self.staticContentList = Ui()
	self.staticContentListLabel = Ui()
	self
		:beginUi(UiWeightLayout)
			:size(1,1)
			:beginUi(UiScrollAreaH)
				:width(1):height(.5)
				:setVar("scrollheight", 0)
				:setVar("padb", 0)
				:beginUi(self.staticContentList)
					:height(1)
					:decorate{ DecoImmutable.ContentList1x }
					:setVar("groupOwner", self)
					:setVar("data", data)
				:endUi()
			:endUi()
			:beginUi(self.staticContentListLabel)
				:widthpx(100):height(1)
				:setVar("data", data)
				:decorate{ DecoImmutable.ObjectNameLabelBounceCenterClip }
			:endUi()
			:setTranslucent(true, true)
		:endUi()
end

local function addStaticContentList2x(self, data)
	self.staticContentList = Ui()
	self.staticContentListLabel = Ui()
	self
		:beginUi(UiWeightLayout)
			:size(1,1)
			:beginUi(UiScrollAreaH)
				:size(1,1)
				:setVar("scrollheight", 0)
				:setVar("padb", 0)
				:beginUi(self.staticContentList)
					:height(1)
					:decorate{ DecoImmutable.ContentList2x }
					:setVar("groupOwner", self)
					:setVar("data", data)
				:endUi()
			:endUi()
			:beginUi(self.staticContentListLabel)
				:widthpx(200):height(1)
				:setVar("data", data)
				:decorate{ DecoImmutable.ObjectNameTitleBounceCenterClip }
			:endUi()
			:setTranslucent(true, true)
		:endUi()
end

local function createStaticContentList1x(id, data)
	return Ui()
		:format(addStaticContentList1x, data)
		:width(1):heightpx(20)
		:decorate{ DecoImmutable.GroupButton }
		:padding(-5)
end

local function createStaticContentList2x(id, data)
	return Ui()
		:format(addStaticContentList2x, data)
		:width(1):heightpx(40)
		:decorate{ DecoImmutable.GroupButton }
		:padding(-5)
end

return {
	addStaticContentList = addStaticContentList1x,
	addStaticContentList2x = addStaticContentList2x,
	createStaticContentList = createStaticContentList1x,
	createStaticContentList2x = createStaticContentList2x,
}
