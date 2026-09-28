--[[
	playerSelector.lua
		A player selector widget (requires Bagnon_Forever)
--]]

local Bagnon = LibStub('AceAddon-3.0'):GetAddon('Bagnon')
local L = LibStub('AceLocale-3.0'):GetLocale('Bagnon')
local PlayerSelector = Bagnon.Classy:New('Button')
Bagnon.PlayerSelector = PlayerSelector


--[[ Constructor ]]--

function PlayerSelector:New(frameID, parent)
	local b = self:Bind(Bagnon.Style:CreateIconButton(parent, self:GetPlayerIcon()))

	b:SetScript('OnClick', b.OnClick)
	b:SetScript('OnEnter', b.OnEnter)
	b:SetScript('OnLeave', b.OnLeave)
	b:SetScript('OnShow', b.OnShow)
	b:SetScript('OnHide', b.OnHide)
	b:SetFrameID(frameID)

	return b
end


--[[ Messages ]]--

function PlayerSelector:PLAYER_UPDATE(msg, frameID, player)
	if frameID == self:GetFrameID() then
		self:UpdateHighlight()
	end
end


--[[ Frame Events ]]--

function PlayerSelector:OnShow()
	self.icon:SetTexture(self:GetPlayerIcon())
	self:RegisterMessage('PLAYER_UPDATE')
	self:UpdateHighlight()
end

function PlayerSelector:OnHide()
	self:UnregisterAllMessages()
end

function PlayerSelector:OnClick()
	self:ShowPlayerSelector()
end

function PlayerSelector:OnEnter()
	Bagnon.Style:AnchorTooltip(self)
	self:UpdateTooltip()
end

function PlayerSelector:OnLeave()
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
end


--[[ Update Methods ]]--

function PlayerSelector:ShowPlayerSelector()
	if BagnonDB then
		BagnonDB:SetDropdownFrame(self)
		BagnonDB:ToggleDropdown(self, -4, -2)
	end
end

--tint the border gold while viewing another character, so cached views are obvious
function PlayerSelector:UpdateHighlight()
	local color = Bagnon.PlayerInfo:IsCached(self:GetPlayer()) and Bagnon.Style.colors.accent or Bagnon.Style.colors.buttonBorder
	self:SetBackdropBorderColor(color[1], color[2], color[3], 1)
end

function PlayerSelector:UpdateTooltip()
	GameTooltip:SetText(L.TipChangePlayer)
	if Bagnon.PlayerInfo:IsCached(self:GetPlayer()) then
		GameTooltip:AddLine(string.format(L.TipViewingCharacter, self:GetPlayer()), 1, 0.82, 0)
	end
	GameTooltip:Show()
end


--[[ Properties ]]--

function PlayerSelector:SetFrameID(frameID)
	if self:GetFrameID() ~= frameID then
		self.frameID = frameID
	end
end

function PlayerSelector:GetFrameID()
	return self.frameID
end

function PlayerSelector:GetSettings()
	return Bagnon.FrameSettings:Get(self:GetFrameID())
end

function PlayerSelector:SetPlayer(player)
	self:GetSettings():SetPlayerFilter(player)
end

function PlayerSelector:GetPlayer()
	return self:GetSettings():GetPlayerFilter()
end

function PlayerSelector:GetPlayerIcon()
	local race, enRace = UnitRace('player')
	if not enRace then
		return [[Interface\Icons\INV_Misc_QuestionMark]]
	end

	--forsaken hack
	if enRace == 'Scourge' then
		enRace = 'Undead'
	end

	local sex = UnitSex('player')
	if sex == 3 then
		return string.format([[Interface\Icons\Achievement_Character_%s_%s]], enRace, 'Female')
	end
	return string.format([[Interface\Icons\Achievement_Character_%s_%s]], enRace, 'Male')
end
