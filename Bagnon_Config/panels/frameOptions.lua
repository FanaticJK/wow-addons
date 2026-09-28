--[[
	frameOptions.lua
		Settings specific to a single Bagnon frame
--]]

local Bagnon = LibStub('AceAddon-3.0'):GetAddon('Bagnon')
local L = LibStub('AceLocale-3.0'):GetLocale('Bagnon-Config')
local FrameOptions = Bagnon.OptionsPanel:New('BagnonOptions_Frame', 'Bagnon', L.FrameSettings, L.FrameSettingsTitle)
FrameOptions:Hide()

Bagnon.FrameOptions = FrameOptions

local FRAME_NAMES = {
	inventory = L.Inventory,
	bank = L.Bank,
	keys = L.KeyRing,
	guildbank = L.GuildBank,
}


--[[
	Startup
--]]

function FrameOptions:Load()
	self:SetFrameID('inventory')
	self:SetScript('OnShow', self.OnShow)
	self:SetScript('OnHide', self.OnHide)
	self:AddWidgets()
end

function FrameOptions:ShowFrame(frameID)
	self:SetFrameID(frameID)

	--the first call to OpenToCategory only opens the frame, and does not select the category
	InterfaceOptionsFrame_OpenToCategory(self)
	InterfaceOptionsFrame_OpenToCategory(self)
end


--[[
	Messages
--]]

--messages whose only effect on this panel is refreshing every widget
local REFRESH_MESSAGES = {
	'FRAME_LAYER_UPDATE', 'FRAME_SCALE_UPDATE', 'FRAME_OPACITY_UPDATE',
	'FRAME_COLOR_UPDATE', 'FRAME_BORDER_COLOR_UPDATE',
	'ITEM_FRAME_SPACING_UPDATE', 'ITEM_FRAME_COLUMNS_UPDATE', 'ITEM_FRAME_BAG_BREAK_UPDATE',
	'BAG_FRAME_ENABLE_UPDATE', 'MONEY_FRAME_ENABLE_UPDATE', 'DATABROKER_FRAME_ENABLE_UPDATE',
	'SEARCH_TOGGLE_ENABLE_UPDATE', 'OPTIONS_TOGGLE_ENABLE_UPDATE', 'SORT_BUTTON_ENABLE_UPDATE',
	'SLOT_COUNTER_ENABLE_UPDATE', 'SLOT_ORDER_UPDATE', 'FRAME_SETTINGS_RESET',
}

function FrameOptions:UpdateMessages()
	self:UnregisterAllMessages()

	if self:IsVisible() then
		for _, msg in ipairs(REFRESH_MESSAGES) do
			self:RegisterMessage(msg, 'OnSettingChanged')
		end
	end
end

--settings changed elsewhere (another panel, slash command, dragging): resync the controls.
--the change handlers are no-ops when a value is unchanged, so this cannot loop.
function FrameOptions:OnSettingChanged(msg, frameID)
	if self:GetFrameID() == frameID then
		self:UpdateWidgets()
	end
end


--[[
	Frame Events
--]]

function FrameOptions:OnShow()
	self:UpdateMessages()
	self:UpdateWidgets()
end

function FrameOptions:OnHide()
	self:UpdateMessages()
end


--[[
	Components
--]]

function FrameOptions:AddWidgets()
	local left, right = self.LEFT, self.COLUMN_2
	local _

	--the two columns have to share the 413px the 3.3.5 options window gives a panel
	local leftLabelWidth = right - left - self.CHECK_SIZE - 8
	local rightWidth = self.RIGHT - right

	--frame selector, with the reset buttons on the same row
	local frameSelector = self:CreateFrameSelector()
	self:Place(frameSelector, left - 16, self.CONTENT_TOP)

	local resetFrame = self:CreateResetFrameButton()
	self:PlaceRight(resetFrame, self.RIGHT, self.CONTENT_TOP + 4)

	local resetPosition = self:CreateResetPositionButton()
	self:PlaceRight(resetPosition, self.RIGHT - resetFrame:GetWidth() - 6, self.CONTENT_TOP + 4)

	local top = self.CONTENT_TOP + 38

	--left column: components & layout
	local y = top
	_, y = self:CreateSection(L.SectionComponents, left, y, right - left - 12)

	local components = {
		self:CreateToggleBagFrameCheckbox(leftLabelWidth),
		self:CreateToggleMoneyFrameCheckbox(leftLabelWidth),
		self:CreateToggleDBOFrameCheckbox(leftLabelWidth),
		self:CreateToggleSearchFrameCheckbox(leftLabelWidth),
		self:CreateToggleOptionsCheckbox(leftLabelWidth),
		self:CreateSortButtonCheckbox(leftLabelWidth),
		self:CreateSlotCounterCheckbox(leftLabelWidth),
	}
	for _, checkbox in ipairs(components) do
		self:Place(checkbox, left, y)
		y = y + self.CHECK_HEIGHT
	end

	y = y + self.SECTION_GAP
	_, y = self:CreateSection(L.SectionLayout, left, y, right - left - 12)
	self:Place(self:CreateReverseSlotOrderCheckbox(leftLabelWidth), left, y)
	y = y + self.CHECK_HEIGHT
	self:Place(self:CreateBagBreakCheckbox(leftLabelWidth), left, y)

	--right column: appearance
	y = top
	_, y = self:CreateSection(L.SectionAppearance, right, y, rightWidth)

	--20px swatch + 6px gap before the label
	local colorLabelWidth = rightWidth - 26

	self:Place(self:CreateColorSelector(colorLabelWidth), right + 4, y + 2)
	y = y + 24
	self:Place(self:CreateBorderColorSelector(colorLabelWidth), right + 4, y + 2)
	y = y + 24 + 16 --room for the first slider's title

	local sliders = {
		self:CreateColumnsSlider(),
		self:CreateSpacingSlider(),
		self:CreateScaleSlider(),
		self:CreateOpacitySlider(),
		self:CreateLayerSlider(),
	}
	for _, slider in ipairs(sliders) do
		slider:SetWidth(rightWidth - 8)
		self:Place(slider, right + 4, y)
		y = y + self.SLIDER_HEIGHT
	end
end

function FrameOptions:UpdateWidgets()
	if not self:IsVisible() then
		return
	end

	local frameID = self:GetFrameID()
	local isKeys, isGuild = frameID == 'keys', frameID == 'guildbank'

	self:GetFrameSelector():UpdateValue()

	self:GetColorSelector():UpdateColor()
	self:GetBorderColorSelector():UpdateColor()

	self:GetColumnsSlider():UpdateValue()
	self:GetSpacingSlider():UpdateValue()
	self:GetScaleSlider():UpdateValue()
	self:GetOpacitySlider():UpdateValue()
	self:GetLayerSlider():UpdateValue()

	self:GetToggleBagFrameCheckbox():UpdateChecked()
	self:GetToggleBagFrameCheckbox():SetDisabled(isKeys or isGuild, L.Warning_NotAvailableForFrame)

	self:GetToggleMoneyFrameCheckbox():UpdateChecked()
	self:GetToggleDBOFrameCheckbox():UpdateChecked()
	self:GetToggleSearchFrameCheckbox():UpdateChecked()
	self:GetToggleOptionsCheckbox():UpdateChecked()

	local sortButton = self:GetSortButtonCheckbox()
	sortButton:UpdateChecked()
	if isKeys or isGuild then
		sortButton:SetDisabled(true, L.Warning_NotAvailableForFrame)
	else
		sortButton:SetDisabled(not Bagnon.SortButton:IsAvailable(), L.Warning_RequiresBankStack)
	end

	self:GetSlotCounterCheckbox():UpdateChecked()
	self:GetSlotCounterCheckbox():SetDisabled(isGuild, L.Warning_NotAvailableForFrame)

	self:GetReverseSlotOrderCheckbox():UpdateChecked()
	self:GetReverseSlotOrderCheckbox():SetDisabled(isGuild, L.Warning_NotAvailableForFrame)

	self:GetBagBreakCheckbox():UpdateChecked()
	self:GetBagBreakCheckbox():SetDisabled(isKeys or isGuild, L.Warning_NotAvailableForFrame)
end


--[[ Dropdowns ]]--

--frame selector
function FrameOptions:CreateFrameSelector()
	local dropdown = Bagnon.OptionsDropdown:New(L.Frame, self, 110)
	dropdown.titleText:Hide()

	dropdown.Initialize = function(self)
		self:AddItem(L.Inventory, 'inventory')
		self:AddItem(L.Bank, 'bank')
		self:AddItem(L.KeyRing, 'keys')

		if IsAddOnLoaded('Bagnon_GuildBank') then
			self:AddItem(L.GuildBank, 'guildbank')
		end
	end

	dropdown.SetSavedValue = function(self, value)
		self:GetParent():SetFrameID(value)
	end

	dropdown.GetSavedValue = function(self)
		return self:GetParent():GetFrameID()
	end

	self.frameSelector = dropdown
	return dropdown
end

function FrameOptions:GetFrameSelector()
	return self.frameSelector
end


--[[ Buttons ]]--

function FrameOptions:CreateResetPositionButton()
	local button = Bagnon.OptionsButton:New(L.ResetPosition, self)
	Bagnon.OptionsTooltip:Attach(button, L.ResetPosition, L.Tip_ResetPosition)

	button.OnAccept = function(self)
		self:GetParent():GetSettings():ResetPosition()
	end
	return button
end

function FrameOptions:CreateResetFrameButton()
	local button = Bagnon.OptionsButton:New(L.ResetFrame, self)
	Bagnon.OptionsTooltip:Attach(button, L.ResetFrame, L.Tip_ResetFrame)

	button.OnClick = function(self)
		local frameID = self:GetParent():GetFrameID()
		self:SetConfirmation(string.format(L.ConfirmResetFrame, FRAME_NAMES[frameID] or frameID))
		Bagnon.OptionsButton.OnClick(self)
	end
	button:SetScript('OnClick', button.OnClick)

	button.OnAccept = function(self)
		self:GetParent():GetSettings():ResetToDefaults()
	end
	return button
end


--[[ Color Pickers ]]--

--frame color
function FrameOptions:CreateColorSelector(labelWidth)
	local selector = Bagnon.OptionsColorSelector:New(L.FrameColor, self, true, L.Tip_FrameColor, labelWidth)

	selector.OnSetColor = function(self, r, g, b, a)
		self:GetParent():GetSettings():SetColor(r, g, b, a)
	end

	selector.GetColor = function(self)
		return self:GetParent():GetSettings():GetColor()
	end

	self.colorSelector = selector
	return selector
end

function FrameOptions:GetColorSelector()
	return self.colorSelector
end

--border color
function FrameOptions:CreateBorderColorSelector(labelWidth)
	local selector = Bagnon.OptionsColorSelector:New(L.FrameBorderColor, self, true, L.Tip_FrameBorderColor, labelWidth)

	selector.OnSetColor = function(self, r, g, b, a)
		self:GetParent():GetSettings():SetBorderColor(r, g, b, a)
	end

	selector.GetColor = function(self)
		return self:GetParent():GetSettings():GetBorderColor()
	end

	self.borderColorSelector = selector
	return selector
end

function FrameOptions:GetBorderColorSelector()
	return self.borderColorSelector
end


--[[ Sliders ]]--

--columns
function FrameOptions:CreateColumnsSlider()
	local slider = Bagnon.OptionsSlider:New(L.Columns, self, 4, 36, 1, L.Tip_Columns)

	slider.SetSavedValue = function(self, value)
		self:GetParent():GetSettings():SetItemFrameColumns(value)
	end

	slider.GetSavedValue = function(self)
		return self:GetParent():GetSettings():GetItemFrameColumns()
	end

	self.columnsSlider = slider
	return slider
end

function FrameOptions:GetColumnsSlider()
	return self.columnsSlider
end

--spacing
function FrameOptions:CreateSpacingSlider()
	local slider = Bagnon.OptionsSlider:New(L.Spacing, self, -16, 36, 2, L.Tip_Spacing)

	slider.SetSavedValue = function(self, value)
		self:GetParent():GetSettings():SetItemFrameSpacing(value)
	end

	slider.GetSavedValue = function(self)
		return self:GetParent():GetSettings():GetItemFrameSpacing()
	end

	self.spacingSlider = slider
	return slider
end

function FrameOptions:GetSpacingSlider()
	return self.spacingSlider
end

--scale
function FrameOptions:CreateScaleSlider()
	local slider = Bagnon.OptionsSlider:New(L.Scale, self, 50, 200, 5, L.Tip_Scale)

	slider.SetSavedValue = function(self, value)
		self:GetParent():GetSettings():SetScale(value / 100)
	end

	slider.GetSavedValue = function(self)
		return math.floor(self:GetParent():GetSettings():GetScale() * 100 + 0.5)
	end

	slider.GetFormattedText = function(self, value)
		return value .. '%'
	end

	self.scaleSlider = slider
	return slider
end

function FrameOptions:GetScaleSlider()
	return self.scaleSlider
end

--opacity
function FrameOptions:CreateOpacitySlider()
	local slider = Bagnon.OptionsSlider:New(L.Opacity, self, 10, 100, 1, L.Tip_Opacity)

	slider.SetSavedValue = function(self, value)
		self:GetParent():GetSettings():SetOpacity(value / 100)
	end

	slider.GetSavedValue = function(self)
		return math.floor(self:GetParent():GetSettings():GetOpacity() * 100 + 0.5)
	end

	slider.GetFormattedText = function(self, value)
		return value .. '%'
	end

	self.opacitySlider = slider
	return slider
end

function FrameOptions:GetOpacitySlider()
	return self.opacitySlider
end

--layer
function FrameOptions:CreateLayerSlider()
	local availableLayers = self:GetSettings():GetAvailableLayers()
	local slider = Bagnon.OptionsSlider:New(L.FrameLayer, self, 1, #availableLayers, 1, L.Tip_FrameLayer)
	slider.layers = availableLayers
	slider.hideRange = true

	slider.SetSavedValue = function(self, value)
		local layer = self.layers[value]
		if layer then
			self:GetParent():GetSettings():SetLayer(layer)
		end
	end

	slider.GetSavedValue = function(self)
		local layer = self:GetParent():GetSettings():GetLayer()
		for k, v in pairs(self.layers) do
			if v == layer then
				return k
			end
		end
		return 1
	end

	slider.GetFormattedText = function(self, value)
		return self.layers[value] or ''
	end

	self.layerSlider = slider
	return slider
end

function FrameOptions:GetLayerSlider()
	return self.layerSlider
end



--[[ Check Boxes ]]--

--creates a checkbox bound to a boolean FrameSettings getter/setter pair
function FrameOptions:CreateSettingCheckbox(label, tooltip, setter, getter, labelWidth)
	local button = Bagnon.OptionsCheckButton:New(label, self, tooltip, labelWidth)

	button.OnEnableSetting = function(self, enable)
		local settings = self:GetParent():GetSettings()
		settings[setter](settings, enable)
	end

	button.IsSettingEnabled = function(self)
		local settings = self:GetParent():GetSettings()
		return settings[getter](settings)
	end

	return button
end

function FrameOptions:CreateToggleBagFrameCheckbox(labelWidth)
	self.toggleBagFrameCheckbox = self:CreateSettingCheckbox(L.EnableBagFrame, L.Tip_EnableBagFrame, 'SetHasBagFrame', 'HasBagFrame', labelWidth)
	return self.toggleBagFrameCheckbox
end

function FrameOptions:GetToggleBagFrameCheckbox()
	return self.toggleBagFrameCheckbox
end

function FrameOptions:CreateToggleMoneyFrameCheckbox(labelWidth)
	self.toggleMoneyFrameCheckbox = self:CreateSettingCheckbox(L.EnableMoneyFrame, L.Tip_EnableMoneyFrame, 'SetHasMoneyFrame', 'HasMoneyFrame', labelWidth)
	return self.toggleMoneyFrameCheckbox
end

function FrameOptions:GetToggleMoneyFrameCheckbox()
	return self.toggleMoneyFrameCheckbox
end

function FrameOptions:CreateToggleDBOFrameCheckbox(labelWidth)
	self.toggleDBOFrameCheckbox = self:CreateSettingCheckbox(L.EnableDBOFrame, L.Tip_EnableDBOFrame, 'SetHasDBOFrame', 'HasDBOFrame', labelWidth)
	return self.toggleDBOFrameCheckbox
end

function FrameOptions:GetToggleDBOFrameCheckbox()
	return self.toggleDBOFrameCheckbox
end

function FrameOptions:CreateToggleSearchFrameCheckbox(labelWidth)
	self.toggleSearchFrameCheckbox = self:CreateSettingCheckbox(L.EnableSearchToggle, L.Tip_EnableSearchToggle, 'SetHasSearchToggle', 'HasSearchToggle', labelWidth)
	return self.toggleSearchFrameCheckbox
end

function FrameOptions:GetToggleSearchFrameCheckbox()
	return self.toggleSearchFrameCheckbox
end

function FrameOptions:CreateToggleOptionsCheckbox(labelWidth)
	self.toggleOptionsCheckbox = self:CreateSettingCheckbox(L.EnableOptionsToggle, L.Tip_EnableOptionsToggle, 'SetHasOptionsToggle', 'HasOptionsToggle', labelWidth)
	return self.toggleOptionsCheckbox
end

function FrameOptions:GetToggleOptionsCheckbox()
	return self.toggleOptionsCheckbox
end

function FrameOptions:CreateSortButtonCheckbox(labelWidth)
	self.sortButtonCheckbox = self:CreateSettingCheckbox(L.EnableSortButton, L.Tip_EnableSortButton, 'SetHasSortButton', 'HasSortButton', labelWidth)
	return self.sortButtonCheckbox
end

function FrameOptions:GetSortButtonCheckbox()
	return self.sortButtonCheckbox
end

function FrameOptions:CreateSlotCounterCheckbox(labelWidth)
	self.slotCounterCheckbox = self:CreateSettingCheckbox(L.EnableSlotCounter, L.Tip_EnableSlotCounter, 'SetHasSlotCounter', 'HasSlotCounter', labelWidth)
	return self.slotCounterCheckbox
end

function FrameOptions:GetSlotCounterCheckbox()
	return self.slotCounterCheckbox
end

function FrameOptions:CreateReverseSlotOrderCheckbox(labelWidth)
	self.reverseSlotOrderCheckbox = self:CreateSettingCheckbox(L.ReverseSlotOrdering, L.Tip_ReverseSlotOrdering, 'SetReverseSlotOrder', 'IsSlotOrderReversed', labelWidth)
	return self.reverseSlotOrderCheckbox
end

function FrameOptions:GetReverseSlotOrderCheckbox()
	return self.reverseSlotOrderCheckbox
end

function FrameOptions:CreateBagBreakCheckbox(labelWidth)
	self.bagBreakCheckbox = self:CreateSettingCheckbox(L.EnableBagBreak, L.Tip_EnableBagBreak, 'SetBagBreak', 'IsBagBreakEnabled', labelWidth)
	return self.bagBreakCheckbox
end

function FrameOptions:GetBagBreakCheckbox()
	return self.bagBreakCheckbox
end


--[[
	Update Methods
--]]

function FrameOptions:SetFrameID(frameID)
	if self:GetFrameID() ~= frameID then
		self.frameID = frameID
		self:UpdateWidgets()
	end
end

function FrameOptions:GetFrameID()
	return self.frameID
end

function FrameOptions:GetSettings()
	return Bagnon.FrameSettings:Get(self:GetFrameID())
end


--[[ Load the thing ]]--

FrameOptions:Load()
