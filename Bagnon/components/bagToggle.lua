--[[
	bagToggle.lua
		A bag toggle widget
--]]

local Bagnon = LibStub('AceAddon-3.0'):GetAddon('Bagnon')
local L = LibStub('AceLocale-3.0'):GetLocale('Bagnon')
local BagToggle = Bagnon.Classy:New('CheckButton')
Bagnon.BagToggle = BagToggle


--[[ Constructor ]]--

function BagToggle:New(frameID, parent)
	local b = self:Bind(Bagnon.Style:CreateIconButton(parent, [[Interface\Buttons\Button-Backpack-Up]], true))

	b:SetScript('OnClick', b.OnClick)
	b:SetScript('OnEnter', b.OnEnter)
	b:SetScript('OnLeave', b.OnLeave)
	b:SetScript('OnShow', b.OnShow)
	b:SetScript('OnHide', b.OnHide)

	b:SetFrameID(frameID)

	return b
end


--[[ Messages ]]--

function BagToggle:BAG_FRAME_SHOW(msg, frameID)
	if frameID == self:GetFrameID() then
		self:Update()
	end
end

function BagToggle:BAG_FRAME_HIDE(msg, frameID)
	if frameID == self:GetFrameID() then
		self:Update()
	end
end


--[[ Frame Events ]]--

function BagToggle:OnClick()
	self:GetSettings():ToggleBagFrame()
end

function BagToggle:OnEnter()
	Bagnon.Style:AnchorTooltip(self)
	self:UpdateTooltip()
end

function BagToggle:OnLeave()
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
end

function BagToggle:OnShow()
	self:UpdateEvents()
	self:Update()
end

function BagToggle:OnHide()
	self:UpdateEvents()
	self:Update()
end


--[[ Update Methods ]]--

function BagToggle:Update()
	self:SetChecked(self:IsBagFrameShown())
	self:UpdateTooltip()
end

function BagToggle:UpdateEvents()
	self:UnregisterAllMessages()

	if self:IsVisible() then
		self:RegisterMessage('BAG_FRAME_SHOW')
		self:RegisterMessage('BAG_FRAME_HIDE')
	end
end

function BagToggle:UpdateTooltip()
	if not GameTooltip:IsOwned(self) then return end

	if self:IsBagFrameShown() then
		GameTooltip:SetText(L.TipHideBags)
	else
		GameTooltip:SetText(L.TipShowBags)
	end
	GameTooltip:Show()
end


--[[ Properties ]]--

function BagToggle:SetFrameID(frameID)
	if self:GetFrameID() ~= frameID then
		self.frameID = frameID
		self:Update()
	end
end

function BagToggle:GetFrameID()
	return self.frameID
end


--[[ Frame Settings ]]--

function BagToggle:GetSettings()
	return Bagnon.FrameSettings:Get(self:GetFrameID())
end

function BagToggle:IsBagFrameShown()
	return self:GetSettings():IsBagFrameShown()
end