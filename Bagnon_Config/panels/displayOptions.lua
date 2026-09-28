--[[
	displayOptions.lua
		Automatic frame display settings
--]]

local Bagnon = LibStub('AceAddon-3.0'):GetAddon('Bagnon')
local L = LibStub('AceLocale-3.0'):GetLocale('Bagnon-Config')
local DisplayOptions = Bagnon.OptionsPanel:New('BagnonOptions_Display', 'Bagnon', L.DisplaySettings, L.DisplaySettingsTitle)
DisplayOptions:Hide()

Bagnon.DisplayOptions = DisplayOptions

--the mail case is handled by the stock interface, so it has no checkbox
local DISPLAY_EVENTS = {'bank', 'ah', 'vendor', 'trade', 'guildbank', 'craft', 'player'}


--[[
	Startup
--]]

function DisplayOptions:Load()
	self:SetScript('OnShow', self.OnShow)
	self:SetScript('OnHide', self.OnHide)
	self:AddWidgets()
	self:SetFrameID('inventory')
end

function DisplayOptions:ShowFrame(frameID)
	self:SetFrameID(frameID)
	InterfaceOptionsFrame_OpenToCategory(self)
	InterfaceOptionsFrame_OpenToCategory(self)
end


--[[
	Messages
--]]

function DisplayOptions:UpdateMessages()
	if self:IsVisible() then
		self:RegisterMessage('FRAME_DISPLAY_EVENT_UPDATE')
	else
		self:UnregisterMessage('FRAME_DISPLAY_EVENT_UPDATE')
	end
end

function DisplayOptions:FRAME_DISPLAY_EVENT_UPDATE(msg, frameID, event, enable)
	if self:GetFrameID() == frameID then
		local checkbox = self:GetDisplayEventCheckbox(event)
		if checkbox then
			checkbox:UpdateChecked()
		end
	end
end


--[[
	Frame Events
--]]

function DisplayOptions:OnShow()
	self:UpdateMessages()
	self:UpdateWidgets()
end

function DisplayOptions:OnHide()
	self:UpdateMessages()
end


--[[
	Components
--]]

function DisplayOptions:AddWidgets()
	local x = self.LEFT
	local _, y = self:CreateSection(L.SectionAutoDisplay, x, self.CONTENT_TOP)

	for i, event in ipairs(DISPLAY_EVENTS) do
		local checkbox = self:AddDisplayEventCheckbox(event)
		self:Place(checkbox, x, y)
		y = y + self.CHECK_HEIGHT
	end
end

function DisplayOptions:UpdateWidgets()
	if not self:IsVisible() then
		return
	end

	for i, button in self:GetDisplayEventCheckboxes() do
		button:UpdateChecked()
	end
end


--[[ Check Boxes ]]--

function DisplayOptions:AddDisplayEventCheckbox(event)
	local button = Bagnon.OptionsCheckButton:New(L['EnableAutoDisplay_' .. event], self, L.Tip_AutoDisplay)
	button.event = event

	button.OnEnableSetting = function(self, enable)
		Bagnon.Settings:SetShowFrameAtEvent(self:GetParent():GetFrameID(), self.event, enable)
	end

	button.IsSettingEnabled = function(self)
		return Bagnon.Settings:IsFrameShownAtEvent(self:GetParent():GetFrameID(), self.event)
	end

	self.displayEventCheckboxes = self.displayEventCheckboxes or {}
	table.insert(self.displayEventCheckboxes, button)
	return button
end

function DisplayOptions:GetDisplayEventCheckbox(event)
	for i, button in self:GetDisplayEventCheckboxes() do
		if button.event == event then
			return button
		end
	end
	return false
end

function DisplayOptions:GetDisplayEventCheckboxes()
	return ipairs(self.displayEventCheckboxes or {})
end


--[[
	Update Methods
--]]

function DisplayOptions:SetFrameID(frameID)
	if self:GetFrameID() ~= frameID then
		self.frameID = frameID
		self:UpdateWidgets()
	end
end

function DisplayOptions:GetFrameID()
	return self.frameID
end


--[[ Load the thing ]]--

DisplayOptions:Load()
