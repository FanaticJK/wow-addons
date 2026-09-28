--[[
	style.lua
		Bagnon's shared design system: spacing, colors, backdrops and widget factories.
		Every Bagnon window (and the guild bank / config addons) builds its chrome through
		these helpers so the whole suite looks and behaves like one product.

		Only WotLK 3.3.x widget APIs are used here (SetBackdrop, SetTexture(r, g, b, a),
		SetWidth/SetHeight). Avoid SetSize/SetShown/SetColorTexture, which do not exist there.
--]]

local Bagnon = LibStub('AceAddon-3.0'):GetAddon('Bagnon')
local Style = {}
Bagnon.Style = Style


--[[ Metrics ]]--

Style.PADDING = 8 --space between a window edge and its contents
Style.GAP = 4 --space between sibling widgets
Style.MENU_BUTTON_SIZE = 22 --toolbar buttons in a window header
Style.BAG_BUTTON_SIZE = 30 --bag / guild tab buttons
Style.FOOTER_HEIGHT = 18
Style.MIN_FRAME_WIDTH = 180


--[[ Textures ]]--

Style.TEXTURE_FLAT = [[Interface\Buttons\WHITE8X8]]
Style.TEXTURE_BACKGROUND = [[Interface\ChatFrame\ChatFrameBackground]]
Style.TEXTURE_BORDER = [[Interface\Tooltips\UI-Tooltip-Border]]
Style.TEXTURE_GLOW = [[Interface\Buttons\UI-ActionButton-Border]]
Style.TEXTURE_CHECKED = [[Interface\Buttons\CheckButtonHilight]]


--[[ Colors ]]--

Style.colors = {
	accent = {1, 0.82, 0}, --Blizzard gold, matches NORMAL_FONT_COLOR
	text = {0.93, 0.93, 0.93},
	muted = {0.62, 0.62, 0.65},
	good = {0.3, 0.9, 0.4},
	warning = {1, 0.72, 0.2},
	bad = {1, 0.3, 0.25},

	buttonBackground = {0, 0, 0, 0.55},
	buttonBorder = {0.3, 0.3, 0.33, 1},
	inputBackground = {0, 0, 0, 0.65},
	inputBorder = {0.34, 0.34, 0.37, 1},
	divider = {1, 1, 1, 0.08},
	headerBand = {1, 1, 1, 0.035},
}

--the main window chrome: the classic tooltip border, slightly slimmer than stock
Style.frameBackdrop = {
	bgFile = Style.TEXTURE_BACKGROUND,
	edgeFile = Style.TEXTURE_BORDER,
	edgeSize = 14,
	tile = true, tileSize = 16,
	insets = {left = 3, right = 3, top = 3, bottom = 3},
}

--crisp 1px chrome for small controls (buttons, inputs)
Style.flatBackdrop = {
	bgFile = Style.TEXTURE_FLAT,
	edgeFile = Style.TEXTURE_FLAT,
	edgeSize = 1,
	insets = {left = 1, right = 1, top = 1, bottom = 1},
}


--[[ Text Helpers ]]--

local function toHex(c)
	return string.format('%02x%02x%02x', (c[1] or 1) * 255, (c[2] or 1) * 255, (c[3] or 1) * 255)
end

function Style:ColorText(text, color)
	return '|cff' .. toHex(color) .. tostring(text) .. '|r'
end

--returns a class colored name when the class token is known, otherwise the plain name
function Style:ClassColorName(name, classToken)
	local color = classToken and RAID_CLASS_COLORS and RAID_CLASS_COLORS[classToken]
	if color then
		return string.format('|cff%02x%02x%02x%s|r', color.r * 255, color.g * 255, color.b * 255, name)
	end
	return name
end

local GOLD_ICON = [[|TInterface\MoneyFrame\UI-GoldIcon:0:0:2:0|t]]
local SILVER_ICON = [[|TInterface\MoneyFrame\UI-SilverIcon:0:0:2:0|t]]
local COPPER_ICON = [[|TInterface\MoneyFrame\UI-CopperIcon:0:0:2:0|t]]

--formats copper as "12g 3s 4c" using coin icons, omitting empty denominations
function Style:FormatMoney(money)
	money = math.floor(tonumber(money) or 0)

	local gold = math.floor(money / (COPPER_PER_SILVER * SILVER_PER_GOLD))
	local silver = math.floor((money % (COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER)
	local copper = money % COPPER_PER_SILVER

	local text = ''
	if gold > 0 then
		text = string.format('%d%s', gold, GOLD_ICON)
	end
	if silver > 0 then
		text = string.format('%s%s%d%s', text, (text ~= '' and ' ' or ''), silver, SILVER_ICON)
	end
	if copper > 0 or text == '' then
		text = string.format('%s%s%d%s', text, (text ~= '' and ' ' or ''), copper, COPPER_ICON)
	end
	return text
end


--[[ Tooltips ]]--

--anchors the tooltip on whichever side of the owner has more room.
--compares in screen space so it stays correct for scaled Bagnon windows.
function Style:AnchorTooltip(owner, tooltip)
	tooltip = tooltip or GameTooltip

	local x = owner:GetCenter()
	local screenCenter = UIParent:GetWidth() * UIParent:GetEffectiveScale() / 2
	if x and (x * owner:GetEffectiveScale()) > screenCenter then
		tooltip:SetOwner(owner, 'ANCHOR_LEFT')
	else
		tooltip:SetOwner(owner, 'ANCHOR_RIGHT')
	end
	return tooltip
end

--sets a title line plus optional description lines ("\n" separated)
function Style:SetTooltip(tooltip, title, description)
	tooltip:SetText(title, 1, 1, 1)
	if description and description ~= '' then
		tooltip:AddLine(description, nil, nil, nil, true)
	end
	tooltip:Show()
end


--[[ Textures & Dividers ]]--

function Style:CreateDivider(parent, layer)
	local line = parent:CreateTexture(nil, layer or 'BORDER')
	line:SetTexture(unpack(self.colors.divider))
	line:SetHeight(1)
	return line
end

--a translucent band behind a window's header row
function Style:CreateHeaderBand(parent)
	local band = parent:CreateTexture(nil, 'BACKGROUND', nil)
	band:SetTexture(unpack(self.colors.headerBand))
	return band
end


--[[ Buttons ]]--

function Style:ApplyButtonChrome(button)
	button:SetBackdrop(self.flatBackdrop)
	button:SetBackdropColor(unpack(self.colors.buttonBackground))
	button:SetBackdropBorderColor(unpack(self.colors.buttonBorder))

	local highlight = button:CreateTexture(nil, 'HIGHLIGHT')
	highlight:SetTexture(self.TEXTURE_FLAT)
	highlight:SetVertexColor(1, 1, 1, 0.14)
	highlight:SetPoint('TOPLEFT', 1, -1)
	highlight:SetPoint('BOTTOMRIGHT', -1, 1)
	button:SetHighlightTexture(highlight)

	local pushed = button:CreateTexture(nil, 'OVERLAY')
	pushed:SetTexture(self.TEXTURE_FLAT)
	pushed:SetVertexColor(0, 0, 0, 0.35)
	pushed:SetPoint('TOPLEFT', 1, -1)
	pushed:SetPoint('BOTTOMRIGHT', -1, 1)
	button:SetPushedTexture(pushed)

	if button:GetObjectType() == 'CheckButton' then
		local checked = button:CreateTexture(nil, 'OVERLAY')
		checked:SetTexture(self.TEXTURE_CHECKED)
		checked:SetBlendMode('ADD')
		checked:SetAllPoints(button)
		button:SetCheckedTexture(checked)
	end
end

--a small square toolbar button with an icon
function Style:CreateIconButton(parent, texture, checkable, size, name)
	size = size or self.MENU_BUTTON_SIZE

	local b = CreateFrame(checkable and 'CheckButton' or 'Button', name, parent)
	b:SetWidth(size)
	b:SetHeight(size)
	b:RegisterForClicks('anyUp')
	self:ApplyButtonChrome(b)

	local icon = b:CreateTexture(nil, 'ARTWORK')
	icon:SetPoint('TOPLEFT', 2, -2)
	icon:SetPoint('BOTTOMRIGHT', -2, 2)
	icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	if texture then
		icon:SetTexture(texture)
	end
	b.icon = icon

	return b
end

--[[
	a bag style slot button (bags, guild bank tabs).
	Creates the named IconTexture and Count regions expected by Blizzard's
	SetItemButtonTexture / SetItemButtonDesaturated helpers, so <name> is required.
--]]
function Style:CreateSlotButton(parent, name, size)
	size = size or self.BAG_BUTTON_SIZE

	local b = CreateFrame('CheckButton', name, parent)
	b:SetWidth(size)
	b:SetHeight(size)
	b:RegisterForClicks('anyUp')
	self:ApplyButtonChrome(b)

	local icon = b:CreateTexture(name .. 'IconTexture', 'BORDER')
	icon:SetPoint('TOPLEFT', 2, -2)
	icon:SetPoint('BOTTOMRIGHT', -2, 2)
	icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	b.icon = icon

	local count = b:CreateFontString(name .. 'Count', 'OVERLAY')
	count:SetFontObject('NumberFontNormalSmall')
	count:SetJustifyH('RIGHT')
	count:SetPoint('BOTTOMRIGHT', -2, 2)
	count:Hide()
	b.count = count

	return b
end

--a text button matching the icon button chrome (used for small inline actions)
function Style:CreateTextButton(parent, text, width, height)
	local b = CreateFrame('Button', nil, parent)
	b:SetWidth(width or 20)
	b:SetHeight(height or self.MENU_BUTTON_SIZE)
	b:RegisterForClicks('anyUp')
	b:SetNormalFontObject('GameFontNormalSmall')
	b:SetHighlightFontObject('GameFontHighlightSmall')
	b:SetDisabledFontObject('GameFontDisableSmall')
	b:SetText(text)
	return b
end


--[[
	Item Borders
		A quality/state border drawn inside an item button.
		'thin' draws four 2px edges (crisp, modern); 'glow' uses the classic action button glow.
--]]

local Border = {}
local Border_MT = {__index = Border}

function Style:CreateItemBorder(button, thickness)
	thickness = thickness or 2

	local border = setmetatable({edges = {}}, Border_MT)

	local function edge()
		local t = button:CreateTexture(nil, 'OVERLAY')
		t:SetTexture(self.TEXTURE_FLAT)
		t:Hide()
		table.insert(border.edges, t)
		return t
	end

	local top = edge()
	top:SetPoint('TOPLEFT', 0, 0)
	top:SetPoint('TOPRIGHT', 0, 0)
	top:SetHeight(thickness)

	local bottom = edge()
	bottom:SetPoint('BOTTOMLEFT', 0, 0)
	bottom:SetPoint('BOTTOMRIGHT', 0, 0)
	bottom:SetHeight(thickness)

	local left = edge()
	left:SetPoint('TOPLEFT', 0, -thickness)
	left:SetPoint('BOTTOMLEFT', 0, thickness)
	left:SetWidth(thickness)

	local right = edge()
	right:SetPoint('TOPRIGHT', 0, -thickness)
	right:SetPoint('BOTTOMRIGHT', 0, thickness)
	right:SetWidth(thickness)

	local glow = button:CreateTexture(nil, 'OVERLAY')
	glow:SetWidth(67)
	glow:SetHeight(67)
	glow:SetPoint('CENTER', button)
	glow:SetTexture(self.TEXTURE_GLOW)
	glow:SetBlendMode('ADD')
	glow:Hide()
	border.glow = glow

	border.style = 'thin'
	return border
end

function Border:SetStyle(style)
	if self.style ~= style then
		local shown = self:IsShown()
		self:Hide()
		self.style = (style == 'glow') and 'glow' or 'thin'
		if shown then
			self:Show()
		end
	end
end

function Border:SetVertexColor(r, g, b, a)
	for _, edge in ipairs(self.edges) do
		edge:SetVertexColor(r, g, b, a)
	end
	self.glow:SetVertexColor(r, g, b, a)
end

function Border:Show()
	self.shown = true
	if self.style == 'glow' then
		self.glow:Show()
	else
		for _, edge in ipairs(self.edges) do
			edge:Show()
		end
	end
end

function Border:Hide()
	self.shown = nil
	self.glow:Hide()
	for _, edge in ipairs(self.edges) do
		edge:Hide()
	end
end

function Border:IsShown()
	return self.shown
end
