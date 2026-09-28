--[[
	sortButton.lua
		A header button that sorts/stacks a frame's items through BankStack (optional dependency)
--]]

local Bagnon = LibStub('AceAddon-3.0'):GetAddon('Bagnon')
local L = LibStub('AceLocale-3.0'):GetLocale('Bagnon')
local SortButton = Bagnon.Classy:New('Button')
Bagnon.SortButton = SortButton


--returns the BankStack API if the addon is loaded and exposes what we need
function SortButton:GetBankStack()
	local core = _G['BankStack']
	if type(core) == 'table' and core.SortBags and core.Compress and core.BankStack then
		return core
	end
end

function SortButton:IsAvailable()
	return self:GetBankStack() ~= nil
end


--[[ Constructor ]]--

function SortButton:New(frameID, parent)
	local b = self:Bind(Bagnon.Style:CreateIconButton(parent, [[Interface\Icons\INV_Misc_Shovel_01]]))

	b:SetScript('OnClick', b.OnClick)
	b:SetScript('OnEnter', b.OnEnter)
	b:SetScript('OnLeave', b.OnLeave)
	b:SetFrameID(frameID)

	return b
end


--[[ Frame Events ]]--

function SortButton:OnClick(button)
	local core = self:GetBankStack()
	if not core then
		Bagnon:Print(L.SortRequiresBankStack)
		return
	end

	--clicking while BankStack is working aborts, mirroring its broker launcher
	if core.running and core.StopStacking then
		core.StopStacking()
		return
	end

	local isBank = self:GetFrameID() == 'bank'
	if isBank and not Bagnon.PlayerInfo:AtBank() then
		Bagnon:Print(L.SortRequiresBank)
		return
	end

	--BankStack prints its own warnings when a bank is required but closed
	if button == 'RightButton' then
		core.Compress(isBank and 'bank' or nil)
	elseif IsShiftKeyDown() then
		core.BankStack(isBank and nil or 'bank bags')
	else
		core.SortBags(isBank and 'bank' or nil)
	end

	self:UpdateTooltip()
end

function SortButton:OnEnter()
	Bagnon.Style:AnchorTooltip(self)
	self:UpdateTooltip()
end

function SortButton:OnLeave()
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
end


--[[ Update Methods ]]--

function SortButton:UpdateTooltip()
	if not GameTooltip:IsOwned(self) then return end

	local core = self:GetBankStack()
	GameTooltip:SetText(L.TipSort, 1, 1, 1)

	if core and core.running then
		GameTooltip:AddLine(L.TipSortRunning, 1, 0.3, 0.25)
	elseif self:GetFrameID() == 'bank' then
		GameTooltip:AddLine(L.TipSortBank)
		GameTooltip:AddLine(L.TipCompressBags)
		GameTooltip:AddLine(L.TipStackToBank)
	else
		GameTooltip:AddLine(L.TipSortBags)
		GameTooltip:AddLine(L.TipCompressBags)
		GameTooltip:AddLine(L.TipStackToBags)
	end

	GameTooltip:Show()
end


--[[ Properties ]]--

function SortButton:SetFrameID(frameID)
	if self:GetFrameID() ~= frameID then
		self.frameID = frameID
	end
end

function SortButton:GetFrameID()
	return self.frameID
end
