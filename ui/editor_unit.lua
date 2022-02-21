
local path = GetParentPath(...)
local helpers = require(path.."helpers")
local decorate = require(path.."helper_decorate")
local DecoEditorButton = require(path.."deco/DecoEditorButton")
local DecoHealth = require(path.."deco/DecoHealth")
local DecoMove = require(path.."deco/DecoMove")
local DecoCheckbox = require(path.."deco/DecoCheckbox")
local DecoLabel = require(path.."deco/DecoLabel")
local UiEditorButton = require(path.."widget/UiEditorButton")
local UiEditBox = require(path.."widget/UiEditBox")
local UiNumberBox = require(path.."widget/UiNumberBox")
local UiWeightLayout = require(path.."widget/UiWeightLayoutExt")
local UiScrollAreaExt = require(path.."widget/UiScrollAreaExt")
local UiScrollArea = UiScrollAreaExt.vertical
local UiScrollAreaH = UiScrollAreaExt.horizontal
local UiPopup = require(path.."widget/UiPopup")

local createUiEditBox = helpers.createUiEditBox
local createUiTitle = helpers.createUiTitle
local decorate_button = decorate.button

-- defs
local EDITOR_TITLE = "Mech Editor"
local SCROLL_BAR_WIDTH = helpers.SCROLL_BAR_WIDTH
local PADDING = 8
local ORIENTATION_VERTICAL = helpers.ORIENTATION_VERTICAL
local ORIENTATION_HORIZONTAL = helpers.ORIENTATION_HORIZONTAL
local FONT_TITLE = helpers.FONT_TITLE
local TEXT_SETTINGS_TITLE = helpers.TEXT_SETTINGS_TITLE
local FONT_LABEL = helpers.FONT_LABEL
local TEXT_SETTINGS_LABEL = helpers.TEXT_SETTINGS_LABEL
local TEXT_SETTINGS_NUMBER = deco.textset(deco.colors.white, deco.colors.black, 2, false)
local CHECKBOX_WIDTH = 25
local CHECKBOX_HEIGHT = 25
local CHECKBOX_CONTAINER_WIDTH = 120
local CHECKBOX_CONTAINER_HEIGHT = 50

-- debug
local DEBUG_COLOR_CONTENT = sdl.rgba(100, 100, 255, 100)
local DEBUG_COLOR_SCROLL = sdl.rgba(255, 100, 100, 100)
local DEBUG_COLOR_ENTRY = sdl.rgba(100, 255, 100, 100)

local CLASSES = { "Prime", "Brute", "Ranged", "Science", "TechnoVek" }

local TEAMS = {
	[TEAM_PLAYER] = "Player",
	[TEAM_ENEMY] = "Enemy",
	[TEAM_NONE] = "None",
}
local IMPACT_MATERIALS = {
	[IMPACT_METAL] = "Metal",
	[IMPACT_INSECT] = "Insect",
	[IMPACT_ROCK] = "Rock",
	[IMPACT_BLOB] = "Blob",
	[IMPACT_FLESH] = "Flesh",
}
local TIERS = {
	[TIER_NORMAL] = "Normal",
	[TIER_ALPHA] = "Alpha",
	[TIER_BOSS] = "Boss",
}
local LEADER = {
	[LEADER_NONE] = "None",
	[LEADER_HEALTH] = "Health",
	[LEADER_VINES] = "Vines",
	[LEADER_ARMOR] = "Armor",
	[LEADER_REGEN] = "Regen",
	[LEADER_EXPLODE] = "Explode",
	[LEADER_TENTACLE] = "Tentacle",
}

-- ui
local currentContent
local unitList
local uiEditBox
local unitEditor = {}

local function onPopupEntryClicked(self)
	local popupButton = self.popupOwner

	popupButton.id = self.id
	popupButton.data = self.data

	if easyEdit.displayedEditorButton then
		popupButton:send()
	end

	popupButton.popupWindow:quit()

	return true
end

local function onCheckboxClicked(self)
	if easyEdit.displayedEditorButton then
		self:send()
	end

	return true
end

local function onTextBoxEnter(self)
	if easyEdit.displayedEditorButton then
		self:send()
	end
end

local function onRecieve_id(reciever, sender)
	reciever:updateText(sender.data._id)
end

local function onSend_name(sender, reciever)
	local unit = reciever.data
	local unitId = unit._id
	local name = sender.textfield

	modApi.modLoaderDictionary[unit._id] = name
	unit.Name = name

	sender:updateText(name)
	reciever.decoName:setsurface(name)
end

local function onRecieve_name(reciever, sender)
	reciever:updateText(sender.data.Name)
end

local function onSend_class(sender, reciever)
	
end

local function onRecieve_class(reciever, sender)
	reciever:updateText(sender.data.Class)
end

local function onSend_image(sender, reciever)
	local unit = reciever.data
	local unitImage = sender.data

	unit.Image = unitImage.Image
	unit.ImageOffset = unitImage.ImageOffset

	decorate_button.unit(sender, unitImage)
	reciever.decoImage:setObject(unitImage)
end

local function onRecieve_image(reciever, sender)
	local unit = sender.data
	local unitImage = modApi.unitImage:get(unit.Image)
	decorate_button.unit(reciever, unitImage)
end

local function onSend_weapon(sender, reciever, weaponSlot)
	local unit = reciever.data
	local weapon = sender.data
	local weaponId = weapon and weapon._id
	if weaponId then
		weapon = modApi.weapons:get(weaponId)
		if weapon then
			unit.SkillList[weaponSlot] = weaponId
		end
	end

	decorate_button.weapon(sender, weapon)
end

local function onRecieve_weapon(reciever, sender, weaponSlot)
	local unit = sender.data
	local weaponId = unit.SkillList[weaponSlot]
	local weapon
	if weaponId ~= nil then
		weapon = modApi.weapons:get(weaponId)
	end

	decorate_button.weapon(reciever, weapon)
end

local function onSend_weaponPrimary(sender, reciever)
	onSend_weapon(sender, reciever, 1)
end

local function onSend_weaponSecondary(sender, reciever)
	onSend_weapon(sender, reciever, 2)
end

local function onRecieve_weaponPrimary(reciever, sender)
	onRecieve_weapon(reciever, sender, 1)
end

local function onRecieve_weaponSecondary(reciever, sender)
	onRecieve_weapon(reciever, sender, 2)
end

local function onSend_health(sender, reciever)
	local unit = reciever.data
	local decoHealth = sender.decorations[1]
	local health = tonumber(sender.textfield)
	unit.Health = health
	decoHealth.healthMax = health
	decoHealth.health = health
end

local function onRecieve_health(reciever, sender)
	local unit = sender.data
	local decoHealth = reciever.decorations[1]
	local health = unit.Health
	decoHealth.healthMax = health
	decoHealth.health = health
	reciever.textfield = tostring(health)
end

local function onSend_moveSpeed(sender, reciever)
	local unit = reciever.data
	local moveSpeed = tonumber(sender.textfield)
	unit.MoveSpeed = moveSpeed
end

local function onRecieve_moveSpeed(reciever, sender)
	local unit = sender.data
	reciever.textfield = tostring(unit.MoveSpeed)
end

local function onSend_massive(sender, reciever)
	local unit = reciever.data
	unit.Massive = sender.checked == true
end

local function onSend_pushable(sender, reciever)
	local unit = reciever.data
	unit.Pushable = sender.checked == true
end

local function onSend_armor(sender, reciever)
	local unit = reciever.data
	unit.Armor = sender.checked == true
end

local function onSend_flying(sender, reciever)
	local unit = reciever.data
	unit.Flying = sender.checked == true
end

local function onSend_teleporter(sender, reciever)
	local unit = reciever.data
	unit.Teleporter = sender.checked == true
end

local function onSend_jumper(sender, reciever)
	local unit = reciever.data
	unit.Jumper = sender.checked == true
end

local function onSend_burrows(sender, reciever)
	local unit = reciever.data
	unit.Burrows = sender.checked == true
end

local function onSend_explodes(sender, reciever)
	local unit = reciever.data
	unit.Explodes = sender.checked == true
end

local function onSend_ignoreFire(sender, reciever)
	local unit = reciever.data
	unit.IgnoreFire = sender.checked == true
end

local function onSend_ignoreSmoke(sender, reciever)
	local unit = reciever.data
	unit.IgnoreSmoke = sender.checked == true
end

local function onRecieve_massive(reciever, sender)
	local unit = sender.data
	reciever.checked = unit.Massive == true
end

local function onRecieve_pushable(reciever, sender)
	local unit = sender.data
	reciever.checked = unit.Pushable == true
end

local function onRecieve_armor(reciever, sender)
	local unit = sender.data
	reciever.checked = unit.Armor == true
end

local function onRecieve_flying(reciever, sender)
	local unit = sender.data
	reciever.checked = unit.Flying == true
end

local function onRecieve_teleporter(reciever, sender)
	local unit = sender.data
	reciever.checked = unit.Teleporter == true
end

local function onRecieve_jumper(reciever, sender)
	local unit = sender.data
	reciever.checked = unit.Jumper == true
end

local function onRecieve_burrows(reciever, sender)
	local unit = sender.data
	reciever.checked = unit.Burrows == true
end

local function onRecieve_explodes(reciever, sender)
	local unit = sender.data
	reciever.checked = unit.Explodes == true
end

local function onRecieve_ignoreFire(reciever, sender)
	local unit = sender.data
	reciever.checked = unit.IgnoreFire == true
end

local function onRecieve_ignoreSmoke(reciever, sender)
	local unit = sender.data
	reciever.checked = unit.IgnoreSmoke == true
end

local onSend = {
	name = onSend_name,
	class = onSend_class,
	image = onSend_image,
	weaponPrimary = onSend_weaponPrimary,
	weaponSecondary = onSend_weaponSecondary,
	health = onSend_health,
	moveSpeed = onSend_moveSpeed,
	massive = onSend_massive,
	pushable = onSend_pushable,
	armor = onSend_armor,
	flying = onSend_flying,
	teleporter = onSend_teleporter,
	jumper = onSend_jumper,
	burrows = onSend_burrows,
	explodes = onSend_explodes,
	ignoreFire = onSend_ignoreFire,
	ignoreSmoke = onSend_ignoreSmoke,
}

local onRecieve = {
	id = onRecieve_id,
	name = onRecieve_name,
	class = onRecieve_class,
	image = onRecieve_image,
	weaponPrimary = onRecieve_weaponPrimary,
	weaponSecondary = onRecieve_weaponSecondary,
	health = onRecieve_health,
	moveSpeed = onRecieve_moveSpeed,
	massive = onRecieve_massive,
	pushable = onRecieve_pushable,
	armor = onRecieve_armor,
	flying = onRecieve_flying,
	teleporter = onRecieve_teleporter,
	jumper = onRecieve_jumper,
	burrows = onRecieve_burrows,
	explodes = onRecieve_explodes,
	ignoreFire = onRecieve_ignoreFire,
	ignoreSmoke = onRecieve_ignoreSmoke,
}

local function reset(reciever)
	reciever = reciever or easyEdit.displayedEditorButton
	if reciever == nil then return end

	local unit = reciever.data

	if unit:isCustom() then
		-- TODO: test if this makes sense
		if reciever == easyEdit.displayedEditorButton then
			easyEdit.displayedEditorButton = nil
		end
		-- TODO: test what happens to custom created units
		if unit:delete() then
			reciever:detach()
		end
	else
		unit:reset()

		modApi.modLoaderDictionary[unit._id] = nil
		reciever.decoName:setsurface(unit.Name)
		reciever.decoImage:setObject(unit)
	end

	for _, ui in pairs(uiEditBox) do
		ui:recieve()
	end
end

local function resetAll()
	for i = #unitList.children, 1, -1 do
		reset(unitList.children[i])
	end
end

local function buildFrameContent(parentUi)
	unitList = UiBoxLayout()
	currentContent = UiScrollArea()

	uiEditBox = {
		id = createUiEditBox(createUiTitle, "Selected Mech"),
		name = createUiEditBox(UiTextBox),
		class = createUiEditBox(Ui),
		health = createUiEditBox(UiNumberBox, 1, 12),
		moveSpeed = createUiEditBox(UiNumberBox, 0, 14),
		image = createUiEditBox(UiPopup, "Mech Images"),
		weaponPrimary = createUiEditBox(UiPopup, "Weapons"),
		weaponSecondary = createUiEditBox(UiPopup, "Weapons"),
		massive = createUiEditBox(UiCheckbox),
		pushable = createUiEditBox(UiCheckbox),
		armor = createUiEditBox(UiCheckbox),
		flying = createUiEditBox(UiCheckbox),
		teleporter = createUiEditBox(UiCheckbox),
		jumper = createUiEditBox(UiCheckbox),
		burrows = createUiEditBox(UiCheckbox),
		explodes = createUiEditBox(UiCheckbox),
		ignoreFire = createUiEditBox(UiCheckbox),
		ignoreSmoke = createUiEditBox(UiCheckbox),
	}

	local images_filtered = filter_table(modApi.unitImage._children, function(k, unitImage)
		return unitImage:isMech()
	end)

	local images_sorted = to_sorted_array(images_filtered, function(a, b)
		local imageOffset_a = a.ImageOffset or INT_MAX
		local imageOffset_b = b.ImageOffset or INT_MAX

		return imageOffset_a < imageOffset_b
	end)

	local weapons_filtered = filter_table(modApi.weapons._children, function(k, weapon)
		return weapon:isMechWeapon()
	end)

	local weapons_sorted = to_sorted_array(weapons_filtered, function(a, b)
		local class_a = a.Class or ""
		local class_b = b.Class or ""

		return class_a < class_b
	end)

	local iconDef_unit = modApi.units:getIconDef()
	local icon_unit_width = iconDef_unit.width * iconDef_unit.scale
	local icon_unit_height = iconDef_unit.height * iconDef_unit.scale

	local iconDef_weapon = modApi.weapons:getIconDef()
	local icon_weapon_width = iconDef_weapon.width * iconDef_weapon.scale
	local icon_weapon_height = iconDef_weapon.height * iconDef_weapon.scale

	local unitBox = UiBoxLayout()

	unitBox
		:widthpx(500)
		:heightpx(120)
		:dynamicResize(false)
		:anchor("center", "center")
		:hgap(5)
		:beginUi()
			:width(.3)
			:beginUi(uiEditBox.image)
				:widthpx(icon_unit_width)
				:heightpx(icon_unit_height)
				:anchor("center", "center")
				:setVar("onRecieve", onRecieve.image)
				:setVar("onSend", onSend.image)
				:decorate( decorate_button.unit() )
				:addList(
					images_sorted,
					decorate_button.unit,
					onPopupEntryClicked
				)
			:endUi()
		:endUi()
		:beginUi()
			:width(.7)
			:beginUi(UiBoxLayout)
				:vgap(5)
				:beginUi(uiEditBox.name)
					:heightpx(28)
					:setVar("onEnter", onTextBoxEnter)
					:setVar("onRecieve", onRecieve.name)
					:setVar("onSend", onSend.name)
					:decorate{
						DecoTextBox{
							font = FONT_TITLE,
							textset = TEXT_SETTINGS_TITLE,
							alignV = "bottom",
						}
					}
				:endUi()
				:beginUi()
					:heightpx(2)
					:decorate{ DecoSolid(deco.colors.buttonborder) }
				:endUi()
				:beginUi(UiWeightLayout)
					:heightpx(icon_weapon_height)
					:hgap(5)
					:orientation(ORIENTATION_HORIZONTAL)
					:beginUi(uiEditBox.weaponPrimary)
						:widthpx(icon_weapon_width)
						:setVar("onRecieve", onRecieve.weaponPrimary)
						:setVar("onSend", onSend.weaponPrimary)
						:decorate( decorate_button.weapon() )
						:addList(
							weapons_sorted,
							decorate_button.weapon,
							onPopupEntryClicked
						)
					:endUi()
					:beginUi(uiEditBox.weaponSecondary)
						:widthpx(icon_weapon_width)
						:setVar("onRecieve", onRecieve.weaponSecondary)
						:setVar("onSend", onSend.weaponSecondary)
						:decorate( decorate_button.weapon() )
						:addList(
							weapons_sorted,
							decorate_button.weapon,
							onPopupEntryClicked
						)
					:endUi()
					:beginUi(UiWeightLayout)
						:width(1)
						:vgap(0)
						:orientation(ORIENTATION_VERTICAL)
						:beginUi(UiBoxLayout)
							:height(0.5)
							:hgap(3)
							:beginUi(uiEditBox.health)
								:sizepx(30,21)
								:setVar("onEnter", onTextBoxEnter)
								:setVar("onRecieve", onRecieve.health)
								:setVar("onSend", onSend.health)
								:decorate{
									DecoHealth(),
									DecoTextBox{
										textset = TEXT_SETTINGS_NUMBER,
										alignH = "center",
									}
								}
							:endUi()
							:beginUi(uiEditBox.moveSpeed)
								:sizepx(30,21)
								:setVar("onEnter", onTextBoxEnter)
								:setVar("onRecieve", onRecieve.moveSpeed)
								:setVar("onSend", onSend.moveSpeed)
								:decorate{
									DecoMove(),
									DecoTextBox{
										textset = TEXT_SETTINGS_NUMBER,
										alignH = "center",
									}
								}
							:endUi()
						:endUi()
						:beginUi(uiEditBox.class)
							:height(0.5)
							:setVar("onRecieve", onRecieve.class)
							:decorate{
								DecoText("Class"),
							}
						:endUi()
					:endUi()
				:endUi()
			:endUi()
		:endUi()
		
	local content = UiWeightLayout()
		:hgap(0)
		-- left area - scrollbar with all mechs
		:beginUi()
			:widthpx(0
				+ icon_unit_width
				+ SCROLL_BAR_WIDTH
				+ PADDING * 4
			)
			:padding(PADDING)
			:beginUi(UiWeightLayout)
				:width(1)
				:vgap(8)
				:orientation(ORIENTATION_VERTICAL)
				-- title on top
				:add(createUiTitle("Mechs"))
				-- mech list
				:beginUi(UiScrollArea)
					:decorate{ DecoFrame() }
					:beginUi(unitList)
						:padding(PADDING)
						:vgap(7)
					:endUi()
				:endUi()
			:endUi()
		:endUi()
		-- right area - selected mech details
		:beginUi()
			:padding(PADDING)
			:beginUi(UiWeightLayout)
				:width(1)
				:vgap(8)
				:orientation(ORIENTATION_VERTICAL)
				-- id on top
				:beginUi(uiEditBox.id)
					:setVar("onRecieve", onRecieve.id)
				:endUi()
				-- mech details
				:beginUi(currentContent)
					:hide()
					:padding(60)
					:decorate{ DecoFrame() }
					:beginUi(UiBoxLayout)
						:padding(PADDING)
						:vgap(40)
						:add(unitBox)
						:beginUi()
							:heightpx(2)
							:decorate{ DecoSolid(deco.colors.buttonborder) }
						:endUi()
						:beginUi(UiFlowLayout)
							:hgap(7)
							:vgap(25)
							:beginUi(uiEditBox.massive)
								:widthpx(CHECKBOX_CONTAINER_WIDTH)
								:heightpx(CHECKBOX_CONTAINER_HEIGHT)
								:setVar("onRecieve", onRecieve.massive)
								:setVar("onSend", onSend.massive)
								:setVar("onclicked", onCheckboxClicked)
								:decorate{
									DecoLabel("MASSIVE", "center", "top"),
									DecoCheckbox(
										CHECKBOX_WIDTH,
										CHECKBOX_HEIGHT,
										"center",
										"bottom"
									)
								}
							:endUi()
							:beginUi(uiEditBox.pushable)
								:widthpx(CHECKBOX_CONTAINER_WIDTH)
								:heightpx(CHECKBOX_CONTAINER_HEIGHT)
								:setVar("onRecieve", onRecieve.pushable)
								:setVar("onSend", onSend.pushable)
								:setVar("onclicked", onCheckboxClicked)
								:decorate{
									DecoLabel("PUSHABLE", "center", "top"),
									DecoCheckbox(
										CHECKBOX_WIDTH,
										CHECKBOX_HEIGHT,
										"center",
										"bottom"
									)
								}
							:endUi()
							:beginUi(uiEditBox.armor)
								:widthpx(CHECKBOX_CONTAINER_WIDTH)
								:heightpx(CHECKBOX_CONTAINER_HEIGHT)
								:setVar("onRecieve", onRecieve.armor)
								:setVar("onSend", onSend.armor)
								:setVar("onclicked", onCheckboxClicked)
								:decorate{
									DecoLabel("ARMOR", "center", "top"),
									DecoCheckbox(
										CHECKBOX_WIDTH,
										CHECKBOX_HEIGHT,
										"center",
										"bottom"
									)
								}
							:endUi()
							:beginUi(uiEditBox.flying)
								:widthpx(CHECKBOX_CONTAINER_WIDTH)
								:heightpx(CHECKBOX_CONTAINER_HEIGHT)
								:setVar("onRecieve", onRecieve.flying)
								:setVar("onSend", onSend.flying)
								:setVar("onclicked", onCheckboxClicked)
								:decorate{
									DecoLabel("FLYING", "center", "top"),
									DecoCheckbox(
										CHECKBOX_WIDTH,
										CHECKBOX_HEIGHT,
										"center",
										"bottom"
									)
								}
							:endUi()
							:beginUi(uiEditBox.teleporter)
								:widthpx(CHECKBOX_CONTAINER_WIDTH)
								:heightpx(CHECKBOX_CONTAINER_HEIGHT)
								:setVar("onRecieve", onRecieve.teleporter)
								:setVar("onSend", onSend.teleporter)
								:setVar("onclicked", onCheckboxClicked)
								:decorate{
									DecoLabel("TELEPORTER", "center", "top"),
									DecoCheckbox(
										CHECKBOX_WIDTH,
										CHECKBOX_HEIGHT,
										"center",
										"bottom"
									)
								}
							:endUi()
							:beginUi(uiEditBox.jumper)
								:widthpx(CHECKBOX_CONTAINER_WIDTH)
								:heightpx(CHECKBOX_CONTAINER_HEIGHT)
								:setVar("onRecieve", onRecieve.jumper)
								:setVar("onSend", onSend.jumper)
								:setVar("onclicked", onCheckboxClicked)
								:decorate{
									DecoLabel("JUMPER", "center", "top"),
									DecoCheckbox(
										CHECKBOX_WIDTH,
										CHECKBOX_HEIGHT,
										"center",
										"bottom"
									)
								}
							:endUi()
							:beginUi(uiEditBox.burrows)
								:widthpx(CHECKBOX_CONTAINER_WIDTH)
								:heightpx(CHECKBOX_CONTAINER_HEIGHT)
								:setVar("onRecieve", onRecieve.burrows)
								:setVar("onSend", onSend.burrows)
								:setVar("onclicked", onCheckboxClicked)
								:decorate{
									DecoLabel("BURROWS", "center", "top"),
									DecoCheckbox(
										CHECKBOX_WIDTH,
										CHECKBOX_HEIGHT,
										"center",
										"bottom"
									)
								}
							:endUi()
							:beginUi(uiEditBox.explodes)
								:widthpx(CHECKBOX_CONTAINER_WIDTH)
								:heightpx(CHECKBOX_CONTAINER_HEIGHT)
								:setVar("onRecieve", onRecieve.explodes)
								:setVar("onSend", onSend.explodes)
								:setVar("onclicked", onCheckboxClicked)
								:decorate{
									DecoLabel("EXPLODES", "center", "top"),
									DecoCheckbox(
										CHECKBOX_WIDTH,
										CHECKBOX_HEIGHT,
										"center",
										"bottom"
									)
								}
							:endUi()
							:beginUi(uiEditBox.ignoreFire)
								:widthpx(CHECKBOX_CONTAINER_WIDTH)
								:heightpx(CHECKBOX_CONTAINER_HEIGHT)
								:setVar("onRecieve", onRecieve.ignoreFire)
								:setVar("onSend", onSend.ignoreFire)
								:setVar("onclicked", onCheckboxClicked)
								:decorate{
									DecoLabel("FIRE IMMUNE", "center", "top"),
									DecoCheckbox(
										CHECKBOX_WIDTH,
										CHECKBOX_HEIGHT,
										"center",
										"bottom"
									)
								}
							:endUi()
							:beginUi(uiEditBox.ignoreSmoke)
								:widthpx(CHECKBOX_CONTAINER_WIDTH)
								:heightpx(CHECKBOX_CONTAINER_HEIGHT)
								:setVar("onRecieve", onRecieve.ignoreSmoke)
								:setVar("onSend", onSend.ignoreSmoke)
								:setVar("onclicked", onCheckboxClicked)
								:decorate{
									DecoLabel("SMOKE IMMUNE", "center", "top"),
									DecoCheckbox(
										CHECKBOX_WIDTH,
										CHECKBOX_HEIGHT,
										"center",
										"bottom"
									)
								}
							:endUi()
						:endUi()
					:endUi()
				:endUi()
			:endUi()
		:endUi()

	local units_filtered = filter_table(modApi.units._children, function(k, unit)
		return unit._default:isMech()
	end)

	local mechs_sorted = to_sorted_array(units_filtered, function(a, b)
		local imageOffset_a = a.ImageOffset or INT_MAX
		local imageOffset_b = b.ImageOffset or INT_MAX

		return imageOffset_a < imageOffset_b
	end)

	-- populate unit list
	for _, obj in ipairs(mechs_sorted) do
		local scrollarea = unitList.parent
		local decorations = decorate_button.unit(nil, obj)
		decorations[1] = DecoEditorButton()
		local entry = UiEditorButton(scrollarea)
			:widthpx(icon_unit_width)
			:heightpx(icon_unit_height)
			:setVar("data", obj)
			:setVar("decoImage", decorations[3])
			:setVar("decoName", decorations[5])
			:decorate(decorations)
			:addTo(unitList)

	end

	local function onEditorButtonSet(widget)
		if widget then
			currentContent:show()
			for _, ui in pairs(uiEditBox) do
				ui:recieve()
			end
		else
			currentContent:hide()
			uiEditBox.id:updateText("Selected Mech")
		end
	end

	easyEdit.events.onEditorButtonSet:unsubscribeAll()
	easyEdit.events.onEditorButtonSet:subscribe(onEditorButtonSet)

	return content
end

local function buildFrameButtons(buttonLayout)

	sdlext.buildButton(
		"Default",
		"Reset everything to default\n\nWARNING: This will delete all custom mechs",
		resetAll
 	):addTo(buttonLayout)

	sdlext.buildButton(
		"Reset",
		"Reset currently selected mech",
		reset
 	):addTo(buttonLayout)
end

local function onExit()
	UiEditorButton:resetGlobalVariables()

	modApi.units:save()
end

function unitEditor.mainButton()
	UiEditorButton:resetGlobalVariables()

	sdlext.showDialog(function(ui, quit)
		ui.onDialogExit = onExit

		local frame = sdlext.buildButtonDialog(
			EDITOR_TITLE,
			buildFrameContent,
			buildFrameButtons
		)

		function frame:onGameWindowResized(screen, oldSize)
			local minW = 800
			local minH = 600
			local maxW = 1000
			local maxH = 800
			local width = math.min(maxW, math.max(minW, ScreenSizeX() - 200))
			local height = math.min(maxH, math.max(minH, ScreenSizeY() - 100))

			self
				:widthpx(width)
				:heightpx(height)
		end

		frame
			:addTo(ui)
			:anchor("center", "center")
			:onGameWindowResized()
	end)
end

return unitEditor
