--[[
	checkButton.lua
		A bagnon options check button
--]]

local Bagnon = LibStub('AceAddon-3.0'):GetAddon('Bagnon')
local OptionsCheckButton = Bagnon.Classy:New('CheckButton')
Bagnon.OptionsCheckButton = OptionsCheckButton

--the label wraps at <labelWidth>; by default it runs to the right edge of the options panel
function OptionsCheckButton:New(name, parent, tooltip, labelWidth)
	local b = self:Bind(CreateFrame('CheckButton', parent:GetName() .. name, parent, 'InterfaceOptionsCheckButtonTemplate'))
	local size = parent.CHECK_SIZE or 26
	labelWidth = labelWidth or ((parent.CONTENT_WIDTH or 380) - size)

	local text = _G[b:GetName() .. 'Text']
	text:SetText(name)
	text:SetWidth(labelWidth)
	text:SetJustifyH('LEFT')
	b.label = text

	--make the label clickable too
	b:SetHitRectInsets(0, -math.min(text:GetStringWidth(), labelWidth), 0, 0)

	--the box the button and its label take up, for the options panel layout check
	b.layoutWidth = size + labelWidth
	b.layoutHeight = size

	b:SetScript('OnClick', b.OnClick)
	b:SetScript('OnShow', b.OnShow)

	if tooltip then
		Bagnon.OptionsTooltip:Attach(b, name, tooltip)
	end

	return b
end

function OptionsCheckButton:SetDisabled(disable, reason)
	if disable then
		self:Disable()
		self.label:SetFontObject('GameFontDisable')
	else
		self:Enable()
		self.label:SetFontObject('GameFontHighlight')
	end
	Bagnon.OptionsTooltip:SetWarning(self, disable and reason or nil)
end

function OptionsCheckButton:OnClick()
	PlaySound(self:GetChecked() and 'igMainMenuOptionCheckBoxOn' or 'igMainMenuOptionCheckBoxOff')
	self:EnableSetting(self:GetChecked())
end

function OptionsCheckButton:OnShow()
	self:UpdateChecked()
end

function OptionsCheckButton:UpdateChecked()
	self:SetChecked(self:IsSettingEnabled())
end

function OptionsCheckButton:EnableSetting(enable)
	self:OnEnableSetting(enable and true or false)
	self:UpdateChecked()
end

function OptionsCheckButton:OnEnableSetting(enable)
	assert(false, 'Hey you forgot to implement OnEnableSetting for ' .. self:GetName())
end

function OptionsCheckButton:IsSettingEnabled()
	assert(false, 'Hey you forgot to implement IsSettingEnabled for ' .. self:GetName())
end
