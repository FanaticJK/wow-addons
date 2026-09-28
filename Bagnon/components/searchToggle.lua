--[[
	searchToggle.lua
		A search toggle widget
--]]

local Bagnon = LibStub('AceAddon-3.0'):GetAddon('Bagnon')
local L = LibStub('AceLocale-3.0'):GetLocale('Bagnon')
local SearchToggle = Bagnon.Classy:New('CheckButton')
Bagnon.SearchToggle = SearchToggle


--[[ Constructor ]]--

function SearchToggle:New(frameID, parent)
	local b = self:Bind(Bagnon.Style:CreateIconButton(parent, [[Interface\Icons\INV_Misc_Spyglass_03]], true))

	b:SetScript('OnClick', b.OnClick)
	b:SetScript('OnEnter', b.OnEnter)
	b:SetScript('OnLeave', b.OnLeave)
	b:SetScript('OnShow', b.OnShow)
	b:SetScript('OnHide', b.OnHide)

	b:SetFrameID(frameID)

	return b
end


--[[ Messages ]]--

function SearchToggle:TEXT_SEARCH_ENABLE(msg, frameID)
	if frameID == self:GetFrameID() then
		self:Update()
	end
end

function SearchToggle:TEXT_SEARCH_DISABLE(msg, frameID)
	if frameID == self:GetFrameID() then
		self:Update()
	end
end


--[[ Frame Events ]]--

function SearchToggle:OnShow()
	self:UpdateEvents()
	self:Update()
end

function SearchToggle:OnHide()
	self:UpdateEvents()
end

function SearchToggle:OnClick()
	self:ToggleSearch()
end

function SearchToggle:OnEnter()
	Bagnon.Style:AnchorTooltip(self)
	self:UpdateTooltip()
end

function SearchToggle:OnLeave()
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
end


--[[ Update Methods ]]--

function SearchToggle:Update()
	if self:IsVisible() then
		self:SetChecked(self:IsSearchEnabled())
		self:UpdateTooltip()
	end
end

function SearchToggle:UpdateEvents()
	self:UnregisterAllMessages()

	if self:IsVisible() then
		self:RegisterMessage('TEXT_SEARCH_ENABLE')
		self:RegisterMessage('TEXT_SEARCH_DISABLE')
	end
end

function SearchToggle:UpdateTooltip()
	if not GameTooltip:IsOwned(self) then return end

	if self:IsSearchEnabled() then
		Bagnon.Style:SetTooltip(GameTooltip, L.TipHideSearch)
	else
		Bagnon.Style:SetTooltip(GameTooltip, L.TipShowSearch, L.TipSearchHelp)
	end
end


--[[ Properties ]]--

function SearchToggle:SetFrameID(frameID)
	if self:GetFrameID() ~= frameID then
		self.frameID = frameID
		self:UpdateEvents()
		self:Update()
	end
end

function SearchToggle:GetFrameID()
	return self.frameID
end

function SearchToggle:GetSettings()
	return Bagnon.FrameSettings:Get(self:GetFrameID())
end

function SearchToggle:ToggleSearch()
	self:GetSettings():ToggleTextSearch()
end

function SearchToggle:IsSearchEnabled()
	return self:GetSettings():IsTextSearchEnabled()
end
