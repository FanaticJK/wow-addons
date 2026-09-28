--[[
	main.lua
		The bagnon driver thingy
--]]

Bagnon = LibStub('AceAddon-3.0'):NewAddon('Bagnon', 'AceEvent-3.0', 'AceConsole-3.0')
local L = LibStub('AceLocale-3.0'):GetLocale('Bagnon')


--[[
	Binding Setup
--]]

BINDING_HEADER_BAGNON = 'Bagnon'
BINDING_NAME_BAGNON_TOGGLE = L.ToggleBags
BINDING_NAME_BANKNON_TOGGLE = L.ToggleBank
BINDING_NAME_BAGNON_KEYS_TOGGLE = L.ToggleKeys


--[[
	Startup
--]]

function Bagnon:OnInitialize()
	self.frames = {}

	self:HookBagClickEvents()
	self:RegisterAutoDisplayEvents()
	self:AddSlashCommands()
	self:CreateOptionsLoader()
	self:CreateLDBLauncher()
	self:CreateGuildBankLoader()
end

--create a loader for the options menu
function Bagnon:CreateOptionsLoader()
	local f = CreateFrame('Frame', nil, InterfaceOptionsFrame)
	f:SetScript('OnShow', function(self)
		self:SetScript('OnShow', nil)
		LoadAddOn('Bagnon_Config')
	end)
end

--[[
	Replaces Blizzard's guild bank loader with Bagnon_GuildBank.
	UIParent calls GuildBankFrame_LoadUI from its GUILDBANKFRAME_OPENED handler.  The guild bank
	module registers for that event while it is already being dispatched, so it would miss the
	very first visit; notify it directly instead.  The module's show handler is idempotent.
--]]
function Bagnon:CreateGuildBankLoader()
	local name, title, notes, enabled, loadable = GetAddOnInfo('Bagnon_GuildBank')
	if enabled and loadable then
		GuildBankFrame_LoadUI = function()
			if IsAddOnLoaded('Bagnon_GuildBank') then
				return
			end

			local loaded, reason = LoadAddOn('Bagnon_GuildBank')
			if not loaded then
				self:Debug('Bagnon_GuildBank failed to load:', reason)
				return
			end

			local guildBank = self:GetModule('GuildBank', true)
			if guildBank and guildBank.GUILDBANKFRAME_OPENED then
				guildBank:GUILDBANKFRAME_OPENED()
			end
		end
	end
end

function Bagnon:CreateLDBLauncher()
	local LDB = LibStub:GetLibrary('LibDataBroker-1.1', true)
	if not LDB then return end

	LDB:NewDataObject('BagnonLauncher', {
		type = 'launcher',

		icon = [[Interface\Icons\INV_Misc_Bag_07]],

		OnClick = function(_, button)
			if button == 'LeftButton' then
				if IsShiftKeyDown() then
					Bagnon:ToggleFrame('bank')
				elseif IsAltKeyDown() then
					Bagnon:ToggleFrame('keys')
				else
					Bagnon:ToggleFrame('inventory')
				end
			elseif button == 'RightButton' then
				Bagnon:ShowOptions()
			end
		end,

		OnTooltipShow = function(tooltip)
			if not tooltip or not tooltip.AddLine then return end

			tooltip:AddLine('Bagnon')
			tooltip:AddLine(L.TipShowInventory, 1, 1, 1)
			tooltip:AddLine(L.TipShowBank, 1, 1, 1)
			tooltip:AddLine(L.TipShowKeyring, 1, 1, 1)
			tooltip:AddLine(L.TipShowOptions, 1, 1, 1)
		end,
	})
end


--[[
	Frame Display
--]]

function Bagnon:GetFrame(frameID)
	for i, frame in pairs(self.frames) do
		if frame:GetFrameID() == frameID then
			return frame
		end
	end
end

function Bagnon:CreateFrame(frameID)
	table.insert(self.frames, self.Frame:New(frameID))
end

function Bagnon:ShowFrame(frameID)
	if self:IsFrameEnabled(frameID) then
		if not self:GetFrame(frameID) then
			self:CreateFrame(frameID)
		end

		self.FrameSettings:Get(frameID):Show()
		return true
	end
	return false
end

function Bagnon:HideFrame(frameID)
	if self:IsFrameEnabled(frameID) then
		self.FrameSettings:Get(frameID):Hide()
		return true
	end
	return false
end

function Bagnon:ToggleFrame(frameID)
	if self:IsFrameEnabled(frameID) then
		if not self:GetFrame(frameID) then
			self:CreateFrame(frameID)
		end

		self.FrameSettings:Get(frameID):Toggle()
		return true
	end
	return false
end

function Bagnon:IsFrameEnabled(frameID)
	return self.Settings:IsFrameEnabled(frameID)
end

function Bagnon:FrameControlsBag(frameID, bagSlot)
	return self.FrameSettings:Get(frameID):IsBagSlotShown(bagSlot) or (not self:IsBlizzardBagPassThroughEnabled())
end

function Bagnon:IsBlizzardBagPassThroughEnabled()
	return self.Settings:IsBlizzardBagPassThroughEnabled()
end


--[[
	Bag Click Events
--]]

function Bagnon:HookBagClickEvents()
	--backpack
	hooksecurefunc('CloseBackpack', function()
		self:HideFrame('inventory')
	end)

	local oOpenBackpack = OpenBackpack
	OpenBackpack = function()
		local shown = self:FrameControlsBag('inventory', BACKPACK_CONTAINER) and self:ShowFrame('inventory')

		if not shown then
			oOpenBackpack()
		end
	end

	local oToggleBackpack = ToggleBackpack
	ToggleBackpack = function()
		local toggled = self:FrameControlsBag('inventory', BACKPACK_CONTAINER) and self:ToggleFrame('inventory')

		if not toggled then
			oToggleBackpack()
		end
	end

	--single bag
	local oToggleBag = ToggleBag
	ToggleBag = function(bagSlot)
		local frameID = self.BagSlotInfo:IsBankBag(bagSlot) and 'bank' or 'inventory'
		local toggled = self:FrameControlsBag(frameID, bagSlot) and self:ToggleFrame(frameID)

		if not toggled then
			oToggleBag(bagSlot)
		end
	end

	--keyring
	local oToggleKeyRing = ToggleKeyRing
	ToggleKeyRing = function()
		local toggled = self:FrameControlsBag('keys', KEYRING_CONTAINER) and self:ToggleFrame('keys')

		if not toggled then
			toggled = self:FrameControlsBag('inventory', KEYRING_CONTAINER) and self:ToggleFrame('inventory')
		end

		if not toggled then
			oToggleKeyRing()
		end
	end

	--all bags
	--closing the game menu triggers this function, and can be done in combat
	hooksecurefunc('CloseAllBags', function()
		self:HideFrame('inventory')
	end)

	local oOpenAllBags = OpenAllBags
	OpenAllBags = function(force)
		local opened = false
		if force then
			opened = self:FrameControlsBag('inventory', BACKPACK_CONTAINER) and self:ShowFrame('inventory')
		else
			opened = self:FrameControlsBag('inventory', BACKPACK_CONTAINER) and self:ToggleFrame('inventory')
		end

		if not opened then
			oOpenAllBags(force)
		end
	end
end


--[[
	Automatic Display
--]]

function Bagnon:RegisterAutoDisplayEvents()
	self.BagEvents:Listen(self, 'BANK_OPENED')
	self.BagEvents:Listen(self, 'BANK_CLOSED')
	self:RegisterEvent('MAIL_CLOSED')
	self:RegisterEvent('AUCTION_HOUSE_SHOW')
	self:RegisterEvent('AUCTION_HOUSE_CLOSED')
	self:RegisterEvent('MERCHANT_SHOW')
	self:RegisterEvent('MERCHANT_CLOSED')
	self:RegisterEvent('TRADE_SHOW')
	self:RegisterEvent('TRADE_CLOSED')
	self:RegisterEvent('TRADE_SKILL_SHOW')
	self:RegisterEvent('TRADE_SKILL_CLOSE')
	self:RegisterEvent('GUILDBANKFRAME_OPENED')
	self:RegisterEvent('GUILDBANKFRAME_CLOSED')

	--override normal bank display
	BankFrame:UnregisterEvent('BANKFRAME_OPENED')
	BankFrame:UnregisterEvent('BANKFRAME_CLOSED')
	
	local f = CreateFrame('Frame', nil, CharacterFrame)
	f:SetScript('OnShow', function() Bagnon:PLAYER_FRAME_SHOW() end)
	f:SetScript('OnHide', function() Bagnon:PLAYER_FRAME_HIDE() end)
end

function Bagnon:ShowFrameAtEvent(frameID, event)
	if self:AutoDisplayingFrameOnEvent(frameID, event) then
		self:ShowFrame(frameID)
	end
end

function Bagnon:HideFrameAtEvent(frameID, event)
	if self:AutoDisplayingFrameOnEvent(frameID, event) then
		self:HideFrame(frameID)
	end
end

function Bagnon:AutoDisplayingFrameOnEvent(frameID, event)
	return self.Settings:IsFrameShownAtEvent(frameID, event)
end

function Bagnon:ShowBlizzardBankFrame()
	BankFrame_OnEvent(_G['BankFrame'], 'BANKFRAME_OPENED')
end

function Bagnon:HideBlizzardBankFrame()
	BankFrame_OnEvent(_G['BankFrame'], 'BANKFRAME_CLOSED')
end


--[[ Display Events ]]--

--visiting the bank
function Bagnon:BANK_OPENED()
	if not self:ShowFrame('bank') then
		self:ShowBlizzardBankFrame()
	end
	self:ShowFrameAtEvent('inventory', 'bank')
end

function Bagnon:BANK_CLOSED()
	if not self:HideFrame('bank') then
		self:HideBlizzardBankFrame()
	end
	self:HideFrameAtEvent('inventory', 'bank')
end

--visiting the mailbox
--mail frame is a special case, since its automatically handled by the stock interface
function Bagnon:MAIL_CLOSED()
	self:HideFrame('inventory')
end

--visiting the auction house
function Bagnon:AUCTION_HOUSE_SHOW()
	self:ShowFrameAtEvent('inventory', 'ah')
end

function Bagnon:AUCTION_HOUSE_CLOSED()
	self:HideFrameAtEvent('inventory', 'ah')
end

--visitng a vendor
function Bagnon:MERCHANT_SHOW()
	self:ShowFrameAtEvent('inventory', 'vendor')
end

function Bagnon:MERCHANT_CLOSED()
	self:HideFrameAtEvent('inventory', 'vendor')
end

--trading
function Bagnon:TRADE_SHOW()
	self:ShowFrameAtEvent('inventory', 'trade')
end

function Bagnon:TRADE_CLOSED()
	self:HideFrameAtEvent('inventory', 'trade')
end

--visiting the guild bank
function Bagnon:GUILDBANKFRAME_OPENED()
	self:ShowFrameAtEvent('inventory', 'guildbank')
end

function Bagnon:GUILDBANKFRAME_CLOSED()
	self:HideFrameAtEvent('inventory', 'guildbank')
end

--crafting
function Bagnon:TRADE_SKILL_SHOW()
	self:ShowFrameAtEvent('inventory', 'craft')
end

function Bagnon:TRADE_SKILL_CLOSE()
	self:HideFrameAtEvent('inventory', 'craft')
end

--player frame
function Bagnon:PLAYER_FRAME_SHOW()
	self:ShowFrameAtEvent('inventory', 'player')
end

function Bagnon:PLAYER_FRAME_HIDE()
	self:HideFrameAtEvent('inventory', 'player')
end


--[[
	Slash Commands
--]]

function Bagnon:AddSlashCommands()
	self:RegisterChatCommand('bagnon', 'HandleSlashCommand')
	self:RegisterChatCommand('bgn', 'HandleSlashCommand')
end

function Bagnon:HandleSlashCommand(cmd)
	cmd = cmd and cmd:lower():trim() or ''

	if cmd == 'bank' then
		self:ToggleFrame('bank')
	elseif cmd == 'bags' or cmd == 'inventory' then
		self:ToggleFrame('inventory')
	elseif cmd == 'keys' then
		self:ToggleFrame('keys')
	elseif cmd == 'version' then
		self:PrintVersion()
	elseif cmd == 'config' or cmd == 'options' then
		self:ShowOptions()
	elseif cmd == 'reset' then
		self:ResetFramePositions()
	elseif cmd == 'debug' then
		self:ToggleDebugging()
	elseif cmd == '' then
		if not self:ShowOptions() then
			self:PrintHelp()
		end
	else
		self:PrintHelp()
	end
end

function Bagnon:PrintVersion()
	self:Print(GetAddOnMetadata('Bagnon', 'Version'))
end

function Bagnon:PrintHelp()
	local function PrintCmd(cmd, desc)
		print(string.format(' - |cFF33FF99/bagnon %s|r: %s', cmd, desc))
	end

	self:Print(L.Commands)
	PrintCmd('bags', L.CmdShowInventory)
	PrintCmd('bank', L.CmdShowBank)
	PrintCmd('keys', L.CmdShowKeyring)
	PrintCmd('config', L.CmdShowConfig)
	PrintCmd('reset', L.CmdReset)
	PrintCmd('version', L.CmdShowVersion)
	PrintCmd('debug', L.CmdDebug)
end

function Bagnon:ShowOptions()
	local loaded = IsAddOnLoaded('Bagnon_Config') or LoadAddOn('Bagnon_Config')
	if loaded and self.GeneralOptions then
		--the first call to OpenToCategory only opens the frame, and does not select the category
		InterfaceOptionsFrame_OpenToCategory(self.GeneralOptions)
		InterfaceOptionsFrame_OpenToCategory(self.GeneralOptions)
		return true
	end

	self:Print(L.ConfigUnavailable)
	return false
end

--opens the frame specific options panel for <frameID>
function Bagnon:ShowFrameOptions(frameID)
	local loaded = IsAddOnLoaded('Bagnon_Config') or LoadAddOn('Bagnon_Config')
	if loaded and self.FrameOptions then
		self.FrameOptions:ShowFrame(frameID)
		return true
	end

	self:Print(L.ConfigUnavailable)
	return false
end

--moves every frame back to its default position (recovers frames dragged off screen)
function Bagnon:ResetFramePositions()
	for _, frameID in pairs(self.FRAME_IDS) do
		--guild bank defaults only exist once Bagnon_GuildBank is loaded; touching its settings
		--earlier would seed them with inventory defaults
		if frameID ~= 'guildbank' or IsAddOnLoaded('Bagnon_GuildBank') then
			self.FrameSettings:Get(frameID):ResetPosition()
		end
	end
	self:Print(L.FramePositionsReset)
end


--[[
	Debugging
--]]

Bagnon.FRAME_IDS = {'inventory', 'bank', 'keys', 'guildbank'}

function Bagnon:ToggleDebugging()
	local enable = not self.Settings:IsDebugging()
	self.Settings:SetDebugging(enable)
	self:Print(enable and L.DebugEnabled or L.DebugDisabled)
end

function Bagnon:Debug(...)
	if self.Settings and self.Settings:IsDebugging() then
		self:Print('|cff888888[debug]|r', ...)
	end
end