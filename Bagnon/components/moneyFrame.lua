--[[
	moneyFrame.lua
		A money frame object
--]]

local Bagnon = LibStub('AceAddon-3.0'):GetAddon('Bagnon')
local MoneyFrame = Bagnon.Classy:New('Frame')
MoneyFrame:Hide()
Bagnon.MoneyFrame = MoneyFrame

local L = LibStub('AceLocale-3.0'):GetLocale('Bagnon')


--[[ Constructor ]]--

function MoneyFrame:New(frameID, parent)
	local f = self:Bind(CreateFrame('Frame', 'BagnonMoneyFrame' .. self:GetNextID(), parent, 'SmallMoneyFrameTemplate'))
	f:SetFrameID(frameID)
	f:AddClickFrame()

	f:SetScript('OnShow', f.OnShow)
	f:SetScript('OnHide', f.OnHide)

	--the template updates itself with GetMoney() on PLAYER_MONEY, which is wrong while viewing
	--another character's cached data.  handle the event ourselves.
	f:SetScript('OnEvent', f.OnEvent)

	return f
end

--creates a clickable frame for tooltips/etc
local function ClickFrame_OnClick(self, button)
	self:GetParent():OnClick(button)
end

local function ClickFrame_OnEnter(self)
	self:GetParent():OnEnter()
end

local function ClickFrame_OnLeave(self)
	self:GetParent():OnLeave()
end

function MoneyFrame:AddClickFrame()
	local f = CreateFrame('Button', self:GetName() .. 'Click', self)
	f:SetFrameLevel(self:GetFrameLevel() + 3)
	f:SetAllPoints(self)
	f:RegisterForClicks('anyUp')

	f:SetScript('OnClick', ClickFrame_OnClick)
	f:SetScript('OnEnter', ClickFrame_OnEnter)
	f:SetScript('OnLeave', ClickFrame_OnLeave)

	return f
end

do
	local id = 0
	function MoneyFrame:GetNextID()
		local nextID = id + 1
		id = nextID
		return nextID
	end
end


--[[ Events ]]--

function MoneyFrame:OnEvent(event)
	if event == 'PLAYER_MONEY' then
		self:UpdateValue()
	end
end

function MoneyFrame:PLAYER_UPDATE(msg, frameID, player)
	if self:GetFrameID() == frameID then
		self:UpdateValue()
	end
end


--[[ Frame Events ]]--

function MoneyFrame:OnShow()
	self:UpdateEverything()
end

function MoneyFrame:OnHide()
	self:UpdateEvents()
end

--picking up coins is only meaningful for the current character
function MoneyFrame:OnClick()
	if Bagnon.PlayerInfo:IsCached(self:GetPlayer()) then
		return
	end

	local name = self:GetName()
	local info = MoneyTypeInfo and MoneyTypeInfo[self.moneyType or 'PLAYER']
	if not (info and info.UpdateFunc) then
		return
	end

	if MouseIsOver(_G[name .. 'GoldButton']) then
		OpenCoinPickupFrame(COPPER_PER_GOLD, info.UpdateFunc(self), self)
		self.hasPickup = 1
	elseif MouseIsOver(_G[name .. 'SilverButton']) then
		OpenCoinPickupFrame(COPPER_PER_SILVER, info.UpdateFunc(self), self)
		self.hasPickup = 1
	elseif MouseIsOver(_G[name .. 'CopperButton']) then
		OpenCoinPickupFrame(1, info.UpdateFunc(self), self)
		self.hasPickup = 1
	end

	self:OnLeave()
end

function MoneyFrame:OnEnter()
	if not BagnonDB then return end

	local Style = Bagnon.Style
	GameTooltip:SetOwner(self, 'ANCHOR_TOPRIGHT')
	GameTooltip:SetText(string.format(L.TipGoldOnRealm, GetRealmName()), 1, 0.82, 0)

	local totalMoney = 0
	for i, player in pairs(BagnonDB:GetPlayerList()) do
		local money = Bagnon.PlayerInfo:GetMoney(player)
		if money > 0 then
			totalMoney = totalMoney + money

			local class = BagnonDB.GetPlayerClass and BagnonDB:GetPlayerClass(player)
			GameTooltip:AddDoubleLine(Style:ClassColorName(player, class), Style:FormatMoney(money), 1, 1, 1, 1, 1, 1)
		end
	end

	GameTooltip:AddLine(' ')
	GameTooltip:AddDoubleLine(L.Total, Style:FormatMoney(totalMoney), 1, 0.82, 0, 1, 1, 1)
	GameTooltip:Show()
end

function MoneyFrame:OnLeave()
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
end


--[[ Update Methods ]]--

function MoneyFrame:UpdateEverything()
	self:UpdateEvents()
	self:UpdateValue()
end

function MoneyFrame:UpdateValue()
	if self:IsVisible() then
		MoneyFrame_Update(self:GetName(), self:GetMoney())
	end
end

function MoneyFrame:UpdateEvents()
	self:UnregisterAllMessages()

	if self:IsVisible() then
		self:RegisterMessage('PLAYER_UPDATE')
	end
end


--[[ Frame Properties ]]--

function MoneyFrame:GetSettings()
	return Bagnon.FrameSettings:Get(self:GetFrameID())
end

function MoneyFrame:GetPlayer()
	return self:GetSettings():GetPlayerFilter()
end

function MoneyFrame:SetFrameID(frameID)
	if self:GetFrameID() ~= frameID then
		self.frameID = frameID
		self:UpdateEverything()
	end
end

function MoneyFrame:GetFrameID()
	return self.frameID
end

function MoneyFrame:GetMoney()
	return Bagnon.PlayerInfo:GetMoney(self:GetPlayer())
end
