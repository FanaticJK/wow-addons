--[[
	colorOptions.lua
		Item highlighting and slot coloring settings
--]]

local Bagnon = LibStub('AceAddon-3.0'):GetAddon('Bagnon')
local L = LibStub('AceLocale-3.0'):GetLocale('Bagnon-Config')
local ColorOptions = Bagnon.OptionsPanel:New('BagnonOptions_Colors', 'Bagnon', L.ColorSettings, L.ColorSettingsTitle)
ColorOptions:Hide()

Bagnon.ColorOptions = ColorOptions

local ITEM_SLOT_COLOR_TYPES = {'ammo', 'trade', 'shard', 'keyring'}


--[[
	Startup
--]]

function ColorOptions:Load()
	self:SetScript('OnShow', self.OnShow)
	self:SetScript('OnHide', self.OnHide)
	self:AddWidgets()
end

function ColorOptions:ShowFrame(frameID)
	self:SetFrameID(frameID)
	InterfaceOptionsFrame_OpenToCategory(self)
	InterfaceOptionsFrame_OpenToCategory(self)
end


--[[
	Messages
--]]

function ColorOptions:UpdateMessages()
	self:UnregisterAllMessages()

	if self:IsVisible() then
		self:RegisterMessage('ITEM_HIGHLIGHT_QUALITY_UPDATE')
		self:RegisterMessage('ITEM_HIGHLIGHT_QUEST_UPDATE')
		self:RegisterMessage('ITEM_HIGHLIGHT_STYLE_UPDATE')
		self:RegisterMessage('ITEM_SLOT_COLOR_ENABLED_UPDATE')
		self:RegisterMessage('ITEM_SLOT_COLOR_UPDATE')
		self:RegisterMessage('ITEM_HIGHLIGHT_OPACITY_UPDATE')
	end
end

function ColorOptions:ITEM_HIGHLIGHT_QUALITY_UPDATE(msg, enable)
	self:GetHighlightItemsByQualityCheckbox():UpdateChecked()
end

function ColorOptions:ITEM_HIGHLIGHT_QUEST_UPDATE(msg, enable)
	self:GetHighlightQuestItemsCheckbox():UpdateChecked()
end

function ColorOptions:ITEM_HIGHLIGHT_STYLE_UPDATE(msg, style)
	self:GetBorderStyleDropdown():UpdateValue()
end

function ColorOptions:ITEM_SLOT_COLOR_ENABLED_UPDATE(msg, enable)
	self:GetColorItemSlotsCheckbox():UpdateChecked()
end

function ColorOptions:ITEM_SLOT_COLOR_UPDATE(msg, type, r, g, b)
	local selector = self:GetItemSlotColorSelector(type)
	if selector then
		selector:UpdateColor()
	end
end

function ColorOptions:ITEM_HIGHLIGHT_OPACITY_UPDATE(msg, value)
	self:GetHighlightOpacitySlider():UpdateValue()
end


--[[
	Frame Events
--]]

function ColorOptions:OnShow()
	self:UpdateMessages()
	self:UpdateWidgets()
end

function ColorOptions:OnHide()
	self:UpdateMessages()
end


--[[
	Components
--]]

function ColorOptions:AddWidgets()
	--one column: the 3.3.5 options window is too narrow for two columns of these labels
	local left = self.LEFT
	local _

	--highlighting
	local y = self.CONTENT_TOP
	_, y = self:CreateSection(L.SectionHighlighting, left, y)

	self:Place(self:CreateHighlightItemsByQualityCheckbox(), left, y)
	y = y + self.CHECK_HEIGHT
	self:Place(self:CreateHighlightQuestItemsCheckbox(), left, y)
	y = y + self.CHECK_HEIGHT + 18 --room for the dropdown's title

	self:Place(self:CreateBorderStyleDropdown(), left - 16, y)
	y = y + 32 + 18 --room for the slider's title

	local opacity = self:CreateHighlightOpacitySlider()
	opacity:SetWidth(self.CONTENT_WIDTH - 8)
	self:Place(opacity, left + 4, y)
	y = y + opacity.layoutHeight + self.SECTION_GAP

	--empty slot colors, as a two by two grid of swatches
	_, y = self:CreateSection(L.SectionSlotColors, left, y)

	self:Place(self:CreateColorItemSlotsCheckbox(), left, y)
	y = y + self.CHECK_HEIGHT + 4

	local columnWidth = math.floor(self.CONTENT_WIDTH / 2)
	--20px swatch + 6px gap before the label, minus a little breathing room between columns
	local slotColorLabelWidth = columnWidth - 26 - 8
	for i, type in ipairs(ITEM_SLOT_COLOR_TYPES) do
		local column, row = (i - 1) % 2, math.floor((i - 1) / 2)
		self:Place(self:CreateItemSlotColorSelector(type, slotColorLabelWidth), left + 4 + column * columnWidth, y + row * 24)
	end
end

function ColorOptions:UpdateWidgets()
	if not self:IsVisible() then
		return
	end

	self:GetHighlightItemsByQualityCheckbox():UpdateChecked()
	self:GetHighlightQuestItemsCheckbox():UpdateChecked()
	self:GetColorItemSlotsCheckbox():UpdateChecked()
	self:GetBorderStyleDropdown():UpdateValue()
	self:GetHighlightOpacitySlider():UpdateValue()

	for i, type in ipairs(ITEM_SLOT_COLOR_TYPES) do
		self:GetItemSlotColorSelector(type):UpdateColor()
	end
end


--[[ Check Boxes ]]--

--highlight items by quality
function ColorOptions:CreateHighlightItemsByQualityCheckbox()
	local button = Bagnon.OptionsCheckButton:New(L.HighlightItemsByQuality, self, L.Tip_HighlightItemsByQuality)

	button.OnEnableSetting = function(self, enable)
		Bagnon.Settings:SetHighlightItemsByQuality(enable)
	end

	button.IsSettingEnabled = function(self)
		return Bagnon.Settings:HighlightingItemsByQuality()
	end

	self.highlightItemsByQualityCheckbox = button
	return button
end

function ColorOptions:GetHighlightItemsByQualityCheckbox()
	return self.highlightItemsByQualityCheckbox
end


--highlight quest items
function ColorOptions:CreateHighlightQuestItemsCheckbox()
	local button = Bagnon.OptionsCheckButton:New(L.HighlightQuestItems, self, L.Tip_HighlightQuestItems)

	button.OnEnableSetting = function(self, enable)
		Bagnon.Settings:SetHighlightQuestItems(enable)
	end

	button.IsSettingEnabled = function(self)
		return Bagnon.Settings:HighlightingQuestItems()
	end

	self.highlightQuestItemsCheckbox = button
	return button
end

function ColorOptions:GetHighlightQuestItemsCheckbox()
	return self.highlightQuestItemsCheckbox
end


--color item slots
function ColorOptions:CreateColorItemSlotsCheckbox()
	local button = Bagnon.OptionsCheckButton:New(L.ColorItemSlotsByBagType, self, L.Tip_ColorItemSlotsByBagType)

	button.OnEnableSetting = function(self, enable)
		Bagnon.Settings:SetColorBagSlots(enable)
	end

	button.IsSettingEnabled = function(self)
		return Bagnon.Settings:ColoringBagSlots()
	end

	self.colorItemSlotsCheckbox = button
	return button
end

function ColorOptions:GetColorItemSlotsCheckbox()
	return self.colorItemSlotsCheckbox
end


--[[ Dropdowns ]]--

function ColorOptions:CreateBorderStyleDropdown()
	local dropdown = Bagnon.OptionsDropdown:New(L.ItemBorderStyle, self, 160, L.Tip_ItemBorderStyle)

	dropdown.Initialize = function(self)
		self:AddItem(L.BorderStyle_thin, 'thin')
		self:AddItem(L.BorderStyle_glow, 'glow')
	end

	dropdown.SetSavedValue = function(self, value)
		Bagnon.Settings:SetItemBorderStyle(value)
	end

	dropdown.GetSavedValue = function(self)
		return Bagnon.Settings:GetItemBorderStyle()
	end

	self.borderStyleDropdown = dropdown
	return dropdown
end

function ColorOptions:GetBorderStyleDropdown()
	return self.borderStyleDropdown
end


--[[ Sliders ]]--

--border opacity
function ColorOptions:CreateHighlightOpacitySlider()
	local slider = Bagnon.OptionsSlider:New(L.ItemHighlightOpacity, self, 10, 100, 1, L.Tip_ItemHighlightOpacity)

	slider.SetSavedValue = function(self, value)
		Bagnon.Settings:SetHighlightOpacity(value / 100)
	end

	slider.GetSavedValue = function(self)
		return math.floor(Bagnon.Settings:GetHighlightOpacity() * 100 + 0.5)
	end

	slider.GetFormattedText = function(self, value)
		return value .. '%'
	end

	self.highlightOpacitySlider = slider
	return slider
end

function ColorOptions:GetHighlightOpacitySlider()
	return self.highlightOpacitySlider
end


--[[ Color Pickers ]]--

function ColorOptions:CreateItemSlotColorSelector(type, labelWidth)
	local selector = Bagnon.OptionsColorSelector:New(L['ItemSlotColor_' .. type], self, false, nil, labelWidth)
	selector.itemSlotType = type

	selector.OnSetColor = function(self, r, g, b)
		Bagnon.Settings:SetItemSlotColor(self.itemSlotType, r, g, b)
	end

	selector.GetColor = function(self)
		return Bagnon.Settings:GetItemSlotColor(self.itemSlotType)
	end

	local colorSelectors = self.colorSelectors or {}
	colorSelectors[type] = selector
	self.colorSelectors = colorSelectors

	return selector
end

function ColorOptions:GetItemSlotColorSelector(type)
	return self.colorSelectors and self.colorSelectors[type]
end


--[[
	Update Methods
--]]

function ColorOptions:SetFrameID(frameID)
	if self:GetFrameID() ~= frameID then
		self.frameID = frameID
		self:UpdateWidgets()
	end
end

function ColorOptions:GetFrameID()
	return self.frameID
end


--[[ Load the thing ]]--

ColorOptions:Load()
