--[[
	savedSettings.lua
		Database access for Bagnon's global (account wide) settings: BagnonGlobalSettings
--]]

local Bagnon = LibStub('AceAddon-3.0'):GetAddon('Bagnon')
local L = LibStub('AceLocale-3.0'):GetLocale('Bagnon')
local Tables = Bagnon.Tables
local SavedSettings = {}
Bagnon.SavedSettings = SavedSettings

local VALID_BORDER_STYLES = {thin = true, glow = true}


--[[---------------------------------------------------------------------------
	Constructorish
--]]---------------------------------------------------------------------------

function SavedSettings:GetDB()
	if not self.db then
		local db = _G['BagnonGlobalSettings']

		if type(db) ~= 'table' then
			if db ~= nil then
				Bagnon:Print(L.SettingsCorrupted)
			else
				Bagnon:Print(L.NewUser)
			end
			db = self:CreateNewDB()
		end

		self.db = db
		if self:IsDBOutOfDate() then
			self:UpgradeDB()
		end

		Tables.CopyDefaults(db, self:GetDefaultSettings())
		self:ValidateDB(db)
	end
	return self.db
end

function SavedSettings:GetDefaultSettings()
	self.defaults = self.defaults or {
		highlightItemsByQuality = true,
		highlightQuestItems = true,
		showEmptyItemSlotTexture = true,
		lockFramePositions = false,
		colorBagSlots = true,
		itemBorderStyle = 'thin',
		debug = false,

		enableBlizzardBagPassThrough = false,

		enabledFrames = {
			inventory = true,
			bank = true,
			keys = true,
		},

		autoDisplayEvents = {
			inventory = {
				ah = false,
				bank = true,
				vendor = true,
				mail = true,
				guildbank = true,
				trade = false,
				craft = false,
				player = false
			},
		},

		slotColors = {
			ammo = {0.7, 0.7, 1},
			trade = {0.5, 1, 0.5},
			shard = {0.9, 0.7, 1},
			keyring = {1, 0.8, 0},
		},

		highlightOpacity = 0.5,
	}

	return self.defaults
end


--[[---------------------------------------------------------------------------
	Upgrade Methods
--]]---------------------------------------------------------------------------

function SavedSettings:CreateNewDB()
	local db = {
		version = self:GetAddOnVersion()
	}

	_G['BagnonGlobalSettings'] = db
	return db
end

--migrations are keyed on the version that wrote the saved variables.
--each step must be safe to run on data that has already been migrated.
function SavedSettings:UpgradeDB()
	local db = self.db
	local oldVersion = db.version

	--pre 2.6.3: autoDisplayEvents was an array; clear the array portion
	if Tables.IsVersionOlder(oldVersion, '2.6.3') and type(db.autoDisplayEvents) == 'table' then
		for i = #db.autoDisplayEvents, 1, -1 do
			db.autoDisplayEvents[i] = nil
		end
	end

	db.version = self:GetAddOnVersion()

	if oldVersion then
		Bagnon:Print(string.format(L.Updated, tostring(db.version)))
	end
end

--repairs out of range values that CopyDefaults cannot detect by type alone
function SavedSettings:ValidateDB(db)
	local defaults = self:GetDefaultSettings()

	if not VALID_BORDER_STYLES[db.itemBorderStyle] then
		db.itemBorderStyle = defaults.itemBorderStyle
	end

	if db.highlightOpacity < 0 or db.highlightOpacity > 1 then
		db.highlightOpacity = defaults.highlightOpacity
	end

	for colorType, color in pairs(db.slotColors) do
		local default = defaults.slotColors[colorType]
		if type(color) ~= 'table' or type(color[1]) ~= 'number' or type(color[2]) ~= 'number' or type(color[3]) ~= 'number' then
			db.slotColors[colorType] = default and {unpack(default)} or nil
		end
	end
end

function SavedSettings:IsDBOutOfDate()
	return self:GetDBVersion() ~= self:GetAddOnVersion()
end

function SavedSettings:GetDBVersion()
	return self.db and self.db.version
end

function SavedSettings:GetAddOnVersion()
	return GetAddOnMetadata('Bagnon', 'Version')
end

--wipes all global settings.  takes effect on the next UI reload
function SavedSettings:ResetAll()
	self.resetPending = true
	self.db = nil
	_G['BagnonGlobalSettings'] = nil
end


--[[---------------------------------------------------------------------------
	Events
--]]---------------------------------------------------------------------------

--create an event handler
do
	local f = CreateFrame('Frame')
	f:SetScript('OnEvent', function(self, event, ...)
		local action = SavedSettings[event]

		if action then
			action(SavedSettings, event, ...)
		end
	end)

	f:RegisterEvent('PLAYER_LOGOUT')
end

--remove any settings that are set to defaults upon logout
function SavedSettings:PLAYER_LOGOUT()
	if self.resetPending or not self.db then
		return
	end

	self:UpdateEnableFrames()
	self:UpdateEnableBlizzardBagPassThrough()
	self:ClearDefaults()
end

--handle enabling/disabling of frames
function SavedSettings:UpdateEnableFrames()
	local framesToEnable = Bagnon.Settings.framesToEnable

	if framesToEnable then
		for frameID, enableStatus in pairs(framesToEnable) do
			self:GetDB().enabledFrames[frameID] = enableStatus
		end
	end
end

function SavedSettings:UpdateEnableBlizzardBagPassThrough()
	self:GetDB().enableBlizzardBagPassThrough = Bagnon.Settings:WillBlizzardBagPassThroughBeEnabled()
end

function SavedSettings:ClearDefaults()
	if self.db then
		Tables.RemoveDefaults(self.db, self:GetDefaultSettings())
	end
end


--[[---------------------------------------------------------------------------
	Complex Settings
--]]---------------------------------------------------------------------------

--frame auto display events
function SavedSettings:SetShowFrameAtEvent(frameID, event, enable)
	local events = self:GetDB().autoDisplayEvents
	events[frameID] = events[frameID] or {}
	events[frameID][event] = enable and true or false
end

function SavedSettings:IsFrameShownAtEvent(frameID, event)
	local events = self:GetDB().autoDisplayEvents[frameID]
	return events and events[event]
end
