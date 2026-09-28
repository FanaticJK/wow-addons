--[[
	bag.lua
		A bag button object for Bagnon
--]]

local Bagnon = LibStub('AceAddon-3.0'):GetAddon('Bagnon')
local GuildTab = Bagnon.Classy:New('CheckButton')
Bagnon.GuildTab = GuildTab

local L = LibStub('AceLocale-3.0'):GetLocale('Bagnon')


--[[ Constructor ]]--

function GuildTab:New(tabID, frameID, parent)
	local tab = self:Create(tabID, parent)
	tab:SetFrameID(frameID)

	tab:SetScript('OnEnter', tab.OnEnter)
	tab:SetScript('OnLeave', tab.OnLeave)
	tab:SetScript('OnClick', tab.OnClick)
	tab:SetScript('OnDragStart', tab.OnDrag)
	tab:SetScript('OnReceiveDrag', tab.OnClick)
	tab:SetScript('OnEvent', tab.OnEvent)
	tab:SetScript('OnShow', tab.OnShow)
	tab:SetScript('OnHide', tab.OnHide)

	return tab
end

function GuildTab:Create(tabID, parent)
	local tab = self:Bind(Bagnon.Style:CreateSlotButton(parent, 'BagnonGuildTab' .. self:GetNextID()))
	tab:SetID(tabID)
	tab:RegisterForDrag('LeftButton')

	return tab
end

do
	local id = 0
	function GuildTab:GetNextID()
		id = id + 1
		return id
	end
end


--[[ Events ]]--

function GuildTab:OnEvent(event, ...)
	local action = self[event]
	if action then
		action(self, event, ...)
	end
end

function GuildTab:UpdateEvents()
	self:UnregisterAllEvents()
	self:UnregisterAllMessages()

	if self:IsVisible() then
		self:RegisterMessage('GUILD_BANK_TAB_CHANGE')
		self:RegisterEvent('GUILDBANK_UPDATE_TABS')
		self:RegisterEvent('GUILDBANKBAGSLOTS_CHANGED')
	end
end


--[[ Messages ]]--

function GuildTab:GUILDBANK_UPDATE_TABS()
	self:Update()
end

function GuildTab:GUILD_BANK_TAB_CHANGE(msg, tabID)
	self:UpdateChecked()
end

function GuildTab:GUILDBANKBAGSLOTS_CHANGED()
	self:UpdateCount()
end

--[[ Frame Events ]]--

function GuildTab:OnShow()
	self:UpdateEverything()
end

function GuildTab:OnHide()
	self:UpdateEvents()
end

function GuildTab:OnClick()
	--tabs that are not purchased or not viewable cannot be selected
	local name, icon, isViewable = GetGuildBankTabInfo(self:GetID())
	if not (name and isViewable) then
		self:UpdateChecked()
		return
	end

	SetCurrentGuildBankTab(self:GetID())
	QueryGuildBankTab(self:GetID())
	self:SendMessage('GUILD_BANK_TAB_CHANGE', self:GetID())
end

function GuildTab:OnDrag()
	--on drag
end

function GuildTab:OnEnter()
	Bagnon.Style:AnchorTooltip(self)

	self:UpdateTooltip()
end

function GuildTab:OnLeave()
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
end


--[[ Actions ]]--

function GuildTab:UpdateEverything()
	self:UpdateEvents()
	self:Update()
	self:UpdateChecked()
end

function GuildTab:Update()
	local name, icon, isViewable, canDeposit, numWithdrawals, remainingWithdrawals = GetGuildBankTabInfo(self:GetID())
	SetItemButtonTexture(self, icon or [[Interface\PaperDoll\UI-PaperDoll-Slot-Bag]])
	
	self:UpdateCount(remainingWithdrawals)
	
	--color red if the bag can be purchased
	if not isViewable then
		SetItemButtonTextureVertexColor(self, 1, 0.1, 0.1)
	else
		SetItemButtonTextureVertexColor(self, 1, 1, 1)
	end
end

function GuildTab:SetCount(count)
	local text = _G[self:GetName() .. 'Count']
	local count = count or 0

	if count > 1 then
		if count > 999 then
			text:SetFormattedText('%.1fk', count/1000)
		else
			text:SetText(count)
		end
		text:Show()
	else
		text:Hide()
	end
end

function GuildTab:UpdateChecked()
	self:SetChecked(self:IsCurrentTab())
end

function GuildTab:UpdateCount(count)
	--hack, since the amount of withdrawls seems to only be correct when we're looking at the current tab
	if not self:IsCurrentTab()  then 
		return 
	end
	
	if not count then
		local name, icon, isViewable, canDeposit, numWithdrawals, remainingWithdrawals = GetGuildBankTabInfo(self:GetID())
		count = remainingWithdrawals
	end

	self:SetCount(count)
end

function GuildTab:IsCurrentTab()
	return self:GetID() == GetCurrentGuildBankTab()
end


--[[ Tooltip Methods ]]--

function GuildTab:UpdateTooltip()
	local name, icon, isViewable, canDeposit, numWithdrawals, remainingWithdrawals = GetGuildBankTabInfo(self:GetID())

	if name then
		GameTooltip:SetText(name)

		local access
		if not canDeposit and numWithdrawals == 0 then
			access = RED_FONT_COLOR_CODE .. "(" .. GUILDBANK_TAB_LOCKED .. ")" .. FONT_COLOR_CODE_CLOSE;
		elseif not canDeposit then
			access = RED_FONT_COLOR_CODE .."(" .. GUILDBANK_TAB_WITHDRAW_ONLY .. ")" .. FONT_COLOR_CODE_CLOSE;
		elseif numWithdrawals == 0 then
			access = RED_FONT_COLOR_CODE .."(" .. GUILDBANK_TAB_DEPOSIT_ONLY .. ")" .. FONT_COLOR_CODE_CLOSE;
		else
			access = GREEN_FONT_COLOR_CODE .. "(" .. GUILDBANK_TAB_FULL_ACCESS .. ")" .. FONT_COLOR_CODE_CLOSE;
		end

		GameTooltip:AddLine(access)
	else
		GameTooltip:SetText(L.TipTabUnavailable, 0.62, 0.62, 0.65)
	end

	GameTooltip:Show()
end


--[[ Accessor Functions ]]--


--returns the bagnon frame we're attached to
function GuildTab:SetFrameID(frameID)
	if self:GetFrameID() ~= frameID then
		self.frameID = frameID
		self:UpdateEverything()
	end
end

function GuildTab:GetFrameID()
	return self.frameID
end

--return the settings object associated with this frame
function GuildTab:GetSettings()
	return Bagnon.FrameSettings:Get(self:GetFrameID())
end