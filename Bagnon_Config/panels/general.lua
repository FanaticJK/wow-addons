--[[
	General.lua
		General Bagnon settings
--]]

local Bagnon = LibStub('AceAddon-3.0'):GetAddon('Bagnon')
local L = LibStub('AceLocale-3.0'):GetLocale('Bagnon-Config')

--a hack panel, this is designed to force open to the general options panel when clicked.
--the frame must NOT be named 'Bagnon': CreateFrame would then overwrite the global Bagnon
--addon table with this frame, breaking Bindings.xml and anything else using the global.
local BagnonOptions = Bagnon.OptionsPanel:New('BagnonOptionsCategory', nil, 'Bagnon')
BagnonOptions:SetScript('OnShow', function(self)
	InterfaceOptionsFrame_OpenToCategory(Bagnon.GeneralOptions)
	self:Hide()
end)

local GeneralOptions = Bagnon.OptionsPanel:New('BagnonOptions_General', 'Bagnon', L.GeneralSettings, L.GeneralSettingsTitle)
Bagnon.GeneralOptions = GeneralOptions


--[[
	Startup
--]]

function GeneralOptions:Load()
	self:SetScript('OnShow', self.OnShow)
	self:SetScript('OnHide', self.OnHide)
	self:AddWidgets()
	self:UpdateMessages()
end


--[[
	Frame Events
--]]

function GeneralOptions:OnShow()
	self:UpdateMessages()
end

function GeneralOptions:OnHide()
	self:UpdateMessages()
end


--[[
	Messages
--]]

function GeneralOptions:UpdateMessages()
	self:UnregisterAllMessages()

	if self:IsVisible() then
		self:RegisterMessage('SHOW_EMPTY_ITEM_SLOT_TEXTURE_UPDATE')
		self:RegisterMessage('LOCK_FRAME_POSITIONS_UPDATE')
		self:RegisterMessage('ENABLE_FRAME_UPDATE')
		self:RegisterMessage('BLIZZARD_BAG_PASSTHROUGH_UPDATE')
	end
end

function GeneralOptions:SHOW_EMPTY_ITEM_SLOT_TEXTURE_UPDATE(msg, enable)
	self:GetEmptyItemSlotTextureCheckbox():UpdateChecked()
end

function GeneralOptions:LOCK_FRAME_POSITIONS_UPDATE(msg, enable)
	self:GetLockFramePositionsCheckbox():UpdateChecked()
end

function GeneralOptions:ENABLE_FRAME_UPDATE(msg, frameID, enable)
	local checkbox = self:GetEnableFrameCheckbox(frameID)
	if checkbox then
		checkbox:UpdateChecked()
	end
end

function GeneralOptions:BLIZZARD_BAG_PASSTHROUGH_UPDATE(msg, enable)
	self:GetBlizzardBagPassThroughCheckbox():UpdateChecked()
end


--[[
	Widgets
--]]

function GeneralOptions:AddWidgets()
	local x, y = self.LEFT, self.CONTENT_TOP
	local _

	--windows
	_, y = self:CreateSection(L.SectionWindows, x, y)
	for _, frameID in ipairs({'inventory', 'bank', 'keys'}) do
		self:Place(self:CreateEnableFrameCheckbox(frameID), x, y)
		y = y + self.CHECK_HEIGHT
	end
	self:Place(self:CreateBlizzardBagPassThroughCheckbox(), x, y)
	y = y + self.CHECK_HEIGHT + self.SECTION_GAP

	--behavior
	_, y = self:CreateSection(L.SectionBehavior, x, y)
	self:Place(self:CreateLockFramePositionsCheckbox(), x, y)
	y = y + self.CHECK_HEIGHT + self.SECTION_GAP

	--item slots
	_, y = self:CreateSection(L.SectionItemSlots, x, y)
	self:Place(self:CreateEmptyItemSlotTextureCheckbox(), x, y)
	y = y + self.CHECK_HEIGHT + self.SECTION_GAP

	--maintenance
	_, y = self:CreateSection(L.SectionMaintenance, x, y)
	local resetPositions = self:CreateResetPositionsButton()
	self:Place(resetPositions, x + 4, y + 2)

	local resetAll = self:CreateResetAllButton()
	self:Place(resetAll, x + 4 + resetPositions:GetWidth() + 8, y + 2)
	y = y + 34

	self:CreateNote(string.format(L.SlashHint, GetAddOnMetadata('Bagnon', 'Version') or '?'), x, y)
end


--[[ Checkboxes ]]--

function GeneralOptions:CreateEnableFrameCheckbox(frameID)
	local button = Bagnon.OptionsCheckButton:New(L['EnableFrame_' .. frameID], self, L['Tip_EnableFrame_' .. frameID])
	button.frameID = frameID

	button.OnEnableSetting = function(self, enable)
		Bagnon.Settings:SetEnableFrame(self.frameID, enable)
		GeneralOptions:DisplayRequiresRestartPopup()
	end

	button.IsSettingEnabled = function(self)
		return Bagnon.Settings:WillFrameBeEnabled(self.frameID)
	end

	self['enableFrame_' .. frameID .. '_Checkbox'] = button
	return button
end

function GeneralOptions:GetEnableFrameCheckbox(frameID)
	return self['enableFrame_' .. frameID .. '_Checkbox']
end

--enabling/disabling frames is applied at logout, so offer an immediate reload
function GeneralOptions:DisplayRequiresRestartPopup()
	if not StaticPopupDialogs['BAGNON_CONFIRM_REQUIRES_RESTART'] then
		StaticPopupDialogs['BAGNON_CONFIRM_REQUIRES_RESTART'] = {
			text = L.SettingRequiresRestart,
			button1 = L.ReloadUI,
			button2 = L.Later,
			OnAccept = function() ReloadUI() end,
			timeout = 0, exclusive = 1, hideOnEscape = 1, whileDead = 1,
		}
	end
	StaticPopup_Show('BAGNON_CONFIRM_REQUIRES_RESTART')
end

--show empty item slot textures
function GeneralOptions:CreateEmptyItemSlotTextureCheckbox()
	local button = Bagnon.OptionsCheckButton:New(L.ShowEmptyItemSlotBackground, self, L.Tip_ShowEmptyItemSlotBackground)

	button.OnEnableSetting = function(self, enable)
		Bagnon.Settings:SetShowEmptyItemSlotTexture(enable)
	end

	button.IsSettingEnabled = function(self)
		return Bagnon.Settings:ShowingEmptyItemSlotTextures()
	end

	self.showEmptyItemsTextureCheckbox = button
	return button
end

function GeneralOptions:GetEmptyItemSlotTextureCheckbox()
	return self.showEmptyItemsTextureCheckbox
end


--lock frame positions
function GeneralOptions:CreateLockFramePositionsCheckbox()
	local button = Bagnon.OptionsCheckButton:New(L.LockFramePositions, self, L.Tip_LockFramePositions)

	button.OnEnableSetting = function(self, enable)
		Bagnon.Settings:SetLockFramePositions(enable)
	end

	button.IsSettingEnabled = function(self)
		return Bagnon.Settings:AreFramePositionsLocked()
	end

	self.lockFramePositionsCheckbox = button
	return button
end

function GeneralOptions:GetLockFramePositionsCheckbox()
	return self.lockFramePositionsCheckbox
end


--blizzard bag passthrough
function GeneralOptions:CreateBlizzardBagPassThroughCheckbox()
	local button = Bagnon.OptionsCheckButton:New(L.EnableBlizzardBagPassThrough, self, L.Tip_EnableBlizzardBagPassThrough)

	button.OnEnableSetting = function(self, enable)
		Bagnon.Settings:SetEnableBlizzardBagPassThrough(enable)
		GeneralOptions:DisplayRequiresRestartPopup()
	end

	button.IsSettingEnabled = function(self)
		return Bagnon.Settings:WillBlizzardBagPassThroughBeEnabled()
	end

	self.blizzardBagPassThroughCheckbox = button
	return button
end

function GeneralOptions:GetBlizzardBagPassThroughCheckbox()
	return self.blizzardBagPassThroughCheckbox
end


--[[ Buttons ]]--

function GeneralOptions:CreateResetPositionsButton()
	local button = Bagnon.OptionsButton:New(L.ResetFramePositions, self)
	Bagnon.OptionsTooltip:Attach(button, L.ResetFramePositions, L.Tip_ResetFramePositions)

	button.OnAccept = function()
		Bagnon:ResetFramePositions()
	end
	return button
end

function GeneralOptions:CreateResetAllButton()
	local button = Bagnon.OptionsButton:New(L.ResetAllSettings, self)
	Bagnon.OptionsTooltip:Attach(button, L.ResetAllSettings, L.Tip_ResetAllSettings)
	button:SetConfirmation(L.ConfirmResetAll)

	button.OnAccept = function()
		Bagnon.SavedSettings:ResetAll()
		Bagnon.SavedFrameSettings:ResetAll()
		ReloadUI()
	end
	return button
end


--[[ Load the thing ]]--

GeneralOptions:Load()
