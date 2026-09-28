--[[
	main.lua
		Guild bank module driver.  Loaded on demand by Bagnon's GuildBankFrame_LoadUI replacement.
--]]

local Bagnon = LibStub('AceAddon-3.0'):GetAddon('Bagnon')
local GuildBank = Bagnon:NewModule('GuildBank', 'AceEvent-3.0')

--Blizzard defines these in Blizzard_GuildBankUI, which Bagnon prevents from loading
GuildBank.MAX_TABS = 6
GuildBank.SLOTS_PER_TAB = 98

function GuildBank:OnEnable()
	self:GetFrame()

	self:RegisterEvent('GUILDBANKFRAME_OPENED')
	self:RegisterEvent('GUILDBANKFRAME_CLOSED')
end

function GuildBank:GetFrame()
	if not self.frame then
		self.frame = Bagnon.GuildFrame:New('guildbank')
	end
	return self.frame
end

--may be called twice for the same visit (by the loader and the event); only show once
function GuildBank:GUILDBANKFRAME_OPENED()
	self:GetFrame()

	local settings = Bagnon.FrameSettings:Get('guildbank')
	if not settings:IsShown() then
		settings:Show()
	end

	local tab = GetCurrentGuildBankTab()
	if tab and tab > 0 then
		QueryGuildBankTab(tab)
	end
end

function GuildBank:GUILDBANKFRAME_CLOSED()
	Bagnon.FrameSettings:Get('guildbank'):Hide(true)
end
