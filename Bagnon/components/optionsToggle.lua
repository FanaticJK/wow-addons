--[[
	optionsToggle.lua
		A options frame toggle widget
--]]

local Bagnon = LibStub('AceAddon-3.0'):GetAddon('Bagnon')
local L = LibStub('AceLocale-3.0'):GetLocale('Bagnon')
local OptionsToggle = Bagnon.Classy:New('Button')
Bagnon.OptionsToggle = OptionsToggle


--[[ Constructor ]]--

function OptionsToggle:New(frameID, parent)
	local b = self:Bind(Bagnon.Style:CreateIconButton(parent, [[Interface\Icons\Trade_Engineering]]))

	b:SetScript('OnClick', b.OnClick)
	b:SetScript('OnEnter', b.OnEnter)
	b:SetScript('OnLeave', b.OnLeave)
	b:SetFrameID(frameID)

	return b
end


--[[ Frame Events ]]--

function OptionsToggle:OnClick()
	Bagnon:ShowFrameOptions(self:GetFrameID())
end

function OptionsToggle:OnEnter()
	Bagnon.Style:AnchorTooltip(self)
	self:UpdateTooltip()
end

function OptionsToggle:OnLeave()
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
end


--[[ Update Methods ]]--

function OptionsToggle:UpdateTooltip()
	if GameTooltip:IsOwned(self) then
		GameTooltip:SetText(L.TipShowFrameConfig)
		GameTooltip:Show()
	end
end


--[[ Properties ]]--

function OptionsToggle:SetFrameID(frameID)
	if self:GetFrameID() ~= frameID then
		self.frameID = frameID
	end
end

function OptionsToggle:GetFrameID()
	return self.frameID
end
