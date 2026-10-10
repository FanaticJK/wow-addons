--[[
	savedFrameSettings.lua
		Persistent, per character frame settings: BagnonFrameSettings
--]]

local SavedFrameSettings = {}
local Bagnon = LibStub('AceAddon-3.0'):GetAddon('Bagnon')
local Tables = Bagnon.Tables
Bagnon.SavedFrameSettings = SavedFrameSettings

local VALID_POINTS = {
	TOPLEFT = true, TOP = true, TOPRIGHT = true,
	LEFT = true, CENTER = true, RIGHT = true,
	BOTTOMLEFT = true, BOTTOM = true, BOTTOMRIGHT = true,
}

local VALID_LAYERS = {
	LOW = true, MEDIUMLOW = true, MEDIUM = true, MEDIUMHIGH = true, HIGH = true, TOPLEVEL = true,
}


--[[---------------------------------------------------------------------------
	Constructorish
--]]---------------------------------------------------------------------------

SavedFrameSettings.mt = {
	__index = SavedFrameSettings
}

SavedFrameSettings.objects = setmetatable({}, {__index = function(tbl, id)
	local obj = setmetatable({frameID = id}, SavedFrameSettings.mt)
	tbl[id] = obj
	return obj
end})

function SavedFrameSettings:Get(id)
	return self.objects[id]
end


--[[---------------------------------------------------------------------------
	Events
--]]---------------------------------------------------------------------------

--create an event handler
do
	local f = CreateFrame('Frame')
	f:SetScript('OnEvent', function(self, event, ...)
		local action = SavedFrameSettings[event]
		if action then
			action(SavedFrameSettings, event, ...)
		end
	end)

	f:RegisterEvent('PLAYER_LOGOUT')
end

--remove any settings that are set to defaults upon logout
function SavedFrameSettings:PLAYER_LOGOUT()
	if SavedFrameSettings.resetPending or not SavedFrameSettings.db then
		return
	end
	self:ClearDefaults()
end


--[[---------------------------------------------------------------------------
	Accessor Methods
--]]---------------------------------------------------------------------------

--get settings for all frames
--only one instance of this for everything (hence the use of SavedFrameSettings over self)
function SavedFrameSettings:GetGlobalDB()
	if not SavedFrameSettings.db then
		local db = _G['BagnonFrameSettings']

		if type(db) ~= 'table' then
			db = {version = self:GetAddOnVersion()}
			_G['BagnonFrameSettings'] = db
		end
		if type(db.frames) ~= 'table' then
			db.frames = {}
		end

		SavedFrameSettings.db = db
		if self:IsDBOutOfDate() then
			self:UpgradeDB()
		end
	end
	return SavedFrameSettings.db
end

--get frame specific settings
function SavedFrameSettings:GetDB()
	if not self.frameDB then
		local frames = self:GetGlobalDB().frames
		local frameDB = frames[self:GetFrameID()]

		if type(frameDB) ~= 'table' then
			frameDB = {}
			frames[self:GetFrameID()] = frameDB
		end

		Tables.CopyDefaults(frameDB, self:GetDefaultSettings())
		self:ValidateDB(frameDB)
		self.frameDB = frameDB
	end
	return self.frameDB
end

function SavedFrameSettings:GetFrameID()
	return self.frameID
end


--[[---------------------------------------------------------------------------
	Upgrade Methods
--]]---------------------------------------------------------------------------

function SavedFrameSettings:UpgradeDB()
	local db = SavedFrameSettings.db

	--hidden bags upgrade: {[index] = bagID} became {[bagID] = true}
	for frameID, settings in pairs(db.frames) do
		local hiddenBags = type(settings) == 'table' and settings.hiddenBags
		if type(hiddenBags) == 'table' then
			--collect first: adding keys to a table while iterating it with pairs
			--is undefined behavior, and can skip entries or error outright
			local legacy
			for k, v in pairs(hiddenBags) do
				if type(v) == 'number' then
					legacy = legacy or {}
					legacy[k] = v
				end
			end

			if legacy then
				for k, bagID in pairs(legacy) do
					hiddenBags[k] = nil
				end
				for _, bagID in pairs(legacy) do
					hiddenBags[bagID] = true
				end
			end
		end
	end

	db.version = self:GetAddOnVersion()
end

--repairs out of range values that CopyDefaults cannot detect by type alone
function SavedFrameSettings:ValidateDB(db)
	local defaults = self:GetDefaultSettings()

	if not VALID_POINTS[db.point] then
		db.point, db.x, db.y = defaults.point, defaults.x, defaults.y
	end

	if not VALID_LAYERS[db.frameLayer] then
		db.frameLayer = defaults.frameLayer
	end

	if db.scale < 0.25 or db.scale > 3 then
		db.scale = defaults.scale
	end

	if db.opacity <= 0 or db.opacity > 1 then
		db.opacity = defaults.opacity
	end

	db.itemFrameColumns = math.floor(db.itemFrameColumns)
	if db.itemFrameColumns < 1 then
		db.itemFrameColumns = defaults.itemFrameColumns
	end

	for _, key in pairs({'frameColor', 'frameBorderColor'}) do
		for i = 1, 4 do
			if type(db[key][i]) ~= 'number' then
				db[key][i] = defaults[key][i]
			end
		end
	end
end

function SavedFrameSettings:IsDBOutOfDate()
	return self:GetDBVersion() ~= self:GetAddOnVersion()
end

function SavedFrameSettings:GetDBVersion()
	return SavedFrameSettings.db and SavedFrameSettings.db.version
end

function SavedFrameSettings:GetAddOnVersion()
	return GetAddOnMetadata('Bagnon', 'Version')
end

function SavedFrameSettings:ClearDefaults()
	local db = self:GetGlobalDB()

	for frameID, settings in pairs(db.frames) do
		if type(settings) == 'table' then
			Tables.RemoveDefaults(settings, self:GetDefaultSettings(frameID))
		end

		if type(settings) ~= 'table' or next(settings) == nil then
			db.frames[frameID] = nil
		end
	end
end

--restores this frame's settings to defaults, in place, so cached references stay valid
function SavedFrameSettings:Reset()
	local db = self:GetDB()
	Tables.Wipe(db)
	Tables.CopyDefaults(db, self:GetDefaultSettings())
end

function SavedFrameSettings:ResetPosition()
	local db = self:GetDB()
	local defaults = self:GetDefaultSettings()
	db.point, db.x, db.y = defaults.point, defaults.x, defaults.y
end

--wipes all frame settings for this character.  takes effect on the next UI reload
function SavedFrameSettings:ResetAll()
	SavedFrameSettings.resetPending = true
	_G['BagnonFrameSettings'] = nil
end


--[[---------------------------------------------------------------------------
	Update Methods
--]]---------------------------------------------------------------------------

--[[ Frame Color ]]--

--background
function SavedFrameSettings:SetColor(r, g, b, a)
	local color = self:GetDB().frameColor
	color[1] = r
	color[2] = g
	color[3] = b
	color[4] = a
end

function SavedFrameSettings:GetColor()
	local r, g, b, a = unpack(self:GetDB().frameColor)
	return r, g, b, a
end

--border
function SavedFrameSettings:SetBorderColor(r, g, b, a)
	local color = self:GetDB().frameBorderColor
	color[1] = r
	color[2] = g
	color[3] = b
	color[4] = a
end

function SavedFrameSettings:GetBorderColor()
	local r, g, b, a = unpack(self:GetDB().frameBorderColor)
	return r, g, b, a
end


--[[ Frame Position ]]--

function SavedFrameSettings:SetPosition(point, x, y)
	local db = self:GetDB()
	db.point = point
	db.x = x
	db.y = y
end

function SavedFrameSettings:GetPosition()
	local db = self:GetDB()
	return db.point, db.x, db.y
end


--[[ Frame Scale ]]--

function SavedFrameSettings:SetScale(scale)
	self:GetDB().scale = scale
end

function SavedFrameSettings:GetScale()
	return self:GetDB().scale
end


--[[ Frame Opacity ]]--

function SavedFrameSettings:SetOpacity(opacity)
	self:GetDB().opacity = opacity
end

function SavedFrameSettings:GetOpacity()
	return self:GetDB().opacity
end


--[[ Frame Layer]]--

function SavedFrameSettings:SetLayer(layer)
	self:GetDB().frameLayer = layer
end

function SavedFrameSettings:GetLayer()
	return self:GetDB().frameLayer
end


--[[ Frame Components ]]--

function SavedFrameSettings:SetHasBagFrame(enable)
	self:GetDB().hasBagFrame = enable or false
end

function SavedFrameSettings:HasBagFrame()
	return self:GetDB().hasBagFrame
end

function SavedFrameSettings:SetHasMoneyFrame(enable)
	self:GetDB().hasMoneyFrame = enable or false
end

function SavedFrameSettings:HasMoneyFrame()
	return self:GetDB().hasMoneyFrame
end

function SavedFrameSettings:SetHasDBOFrame(enable)
	self:GetDB().hasDBOFrame = enable or false
end

function SavedFrameSettings:HasDBOFrame()
	return self:GetDB().hasDBOFrame
end

function SavedFrameSettings:SetHasSearchToggle(enable)
	self:GetDB().hasSearchToggle = enable or false
end

function SavedFrameSettings:HasSearchToggle()
	return self:GetDB().hasSearchToggle
end

function SavedFrameSettings:SetHasOptionsToggle(enable)
	self:GetDB().hasOptionsToggle = enable or false
end

function SavedFrameSettings:HasOptionsToggle()
	return self:GetDB().hasOptionsToggle
end

function SavedFrameSettings:SetHasSortButton(enable)
	self:GetDB().hasSortButton = enable or false
end

function SavedFrameSettings:HasSortButton()
	return self:GetDB().hasSortButton
end

function SavedFrameSettings:SetHasSlotCounter(enable)
	self:GetDB().hasSlotCounter = enable or false
end

function SavedFrameSettings:HasSlotCounter()
	return self:GetDB().hasSlotCounter
end


--[[ Frame Bags ]]--

--show a bag
function SavedFrameSettings:ShowBag(bag)
	self:GetDB().hiddenBags[bag] = false
end

--hide a bag
function SavedFrameSettings:HideBag(bag)
	self:GetDB().hiddenBags[bag] = true
end

function SavedFrameSettings:IsBagShown(bag)
	return not self:GetDB().hiddenBags[bag]
end

--get all available bags
function SavedFrameSettings:GetBags()
	return self:GetDB().availableBags
end

--get all hidden bags
function SavedFrameSettings:GetHiddenBags()
	return self:GetDB().hiddenBags
end


--[[ Item Frame Layout ]]--

--columns
function SavedFrameSettings:SetItemFrameColumns(columns)
	self:GetDB().itemFrameColumns = columns
end

function SavedFrameSettings:GetItemFrameColumns()
	return self:GetDB().itemFrameColumns
end

--spacing
function SavedFrameSettings:SetItemFrameSpacing(spacing)
	self:GetDB().itemFrameSpacing = spacing
end

function SavedFrameSettings:GetItemFrameSpacing()
	return self:GetDB().itemFrameSpacing
end

--bag break layout
function SavedFrameSettings:SetBagBreak(enable)
	self:GetDB().bagBreak = enable
end

function SavedFrameSettings:IsBagBreakEnabled()
	return self:GetDB().bagBreak
end


--[[ Item Frame Slot Ordering ]]--

function SavedFrameSettings:SetReverseSlotOrder(enable)
	self:GetDB().reverseSlotOrder = enable
end

function SavedFrameSettings:IsSlotOrderReversed()
	return self:GetDB().reverseSlotOrder
end


--[[ Databroker Display Object ]]--

function SavedFrameSettings:SetBrokerDisplayObject(objectName)
	self:GetDB().dataBrokerObject = objectName
end

function SavedFrameSettings:GetBrokerDisplayObject()
	return self:GetDB().dataBrokerObject
end


--[[---------------------------------------------------------------------------
	Frame Defaults
--]]---------------------------------------------------------------------------

--generic
function SavedFrameSettings:GetDefaultSettings(frameID)
	local frameID = frameID or self:GetFrameID()

	if frameID == 'keys' then
		return self:GetDefaultKeyRingSettings()
	elseif frameID == 'bank' then
		return self:GetDefaultBankSettings()
	elseif frameID == 'guildbank' then
		return self:GetDefaultGuildBankSettings()
	end

	return self:GetDefaultInventorySettings()
end

--inventory
function SavedFrameSettings:GetDefaultInventorySettings()
	local defaults = SavedFrameSettings.invDefaults or {
		--bag settings
		availableBags = {BACKPACK_CONTAINER, 1, 2, 3, 4, KEYRING_CONTAINER},

		hiddenBags = {
			[BACKPACK_CONTAINER] = false,
			[1] = false,
			[2] = false,
			[3] = false,
			[4] = false,
			[KEYRING_CONTAINER] = true,
		},

		--frame
		frameColor = {0.04, 0.04, 0.05, 0.9},
		frameBorderColor = {0.55, 0.55, 0.6, 1},
		scale = 1,
		opacity = 1,
		point = 'BOTTOMRIGHT',
		x = 0,
		y = 150,
		frameLayer = 'TOPLEVEL',

		--itemFrame
		itemFrameColumns = 8,
		itemFrameSpacing = 2,
		bagBreak = false,

		--optional components
		hasMoneyFrame = true,
		hasBagFrame = true,
		hasDBOFrame = true,
		hasSearchToggle = true,
		hasOptionsToggle = true,
		hasKeyringToggle = true,
		hasSortButton = true,
		hasSlotCounter = true,

		--dbo display object
		dataBrokerObject = 'BagnonLauncher',

		--slot ordering
		reverseSlotOrder = false,
	}

	SavedFrameSettings.invDefaults = defaults
	return defaults
end

--bank
function SavedFrameSettings:GetDefaultBankSettings()
	local defaults = SavedFrameSettings.bankDefaults or {
		--bag settings
		availableBags = {BANK_CONTAINER, 5, 6, 7, 8, 9, 10, 11},
		hiddenBags = {
			[BANK_CONTAINER] = false,
			[5] = false,
			[6] = false,
			[7] = false,
			[8] = false,
			[9] = false,
			[10] = false,
			[11] = false
		},

		--frame
		frameColor = {0.04, 0.04, 0.05, 0.9},
		frameBorderColor = {0.85, 0.7, 0.25, 1},
		scale = 1,
		opacity = 1,
		point = 'BOTTOMLEFT',
		x = 0,
		y = 150,
		frameLayer = 'TOPLEVEL',

		--itemFrame
		itemFrameColumns = 10,
		itemFrameSpacing = 2,
		bagBreak = false,

		--optional components
		hasMoneyFrame = true,
		hasBagFrame = true,
		hasDBOFrame = true,
		hasSearchToggle = true,
		hasOptionsToggle = true,
		hasKeyringToggle = false,
		hasSortButton = true,
		hasSlotCounter = true,

		--dbo display object
		dataBrokerObject = 'BagnonLauncher',

		--slot ordering
		reverseSlotOrder = false,
	}
	SavedFrameSettings.bankDefaults = defaults
	return defaults
end

--keys
function SavedFrameSettings:GetDefaultKeyRingSettings()
	local defaults = SavedFrameSettings.keyDefaults or {
		--bag settings
		availableBags = {KEYRING_CONTAINER},
		hiddenBags = {
			[KEYRING_CONTAINER] = false
		},

		--frame,
		frameColor = {0.04, 0.04, 0.05, 0.9},
		frameBorderColor = {0.3, 0.75, 0.8, 1},
		scale = 1,
		opacity = 1,
		point = 'BOTTOMRIGHT',
		x = -350,
		y = 150,
		frameLayer = 'TOPLEVEL',

		--itemFrame
		itemFrameColumns = 4,
		itemFrameSpacing = 2,
		bagBreak = false,

		--optional components
		hasMoneyFrame = false,
		hasBagFrame = false,
		hasDBOFrame = false,
		hasSearchToggle = false,
		hasOptionsToggle = true,
		hasKeyringToggle = false,
		hasSortButton = false,
		hasSlotCounter = false,

		--dbo display object
		dataBrokerObject = 'BagnonLauncher',

		--slot ordering
		reverseSlotOrder = false,
	}
	SavedFrameSettings.keyDefaults = defaults
	return defaults
end

--overridden by Bagnon_GuildBank
function SavedFrameSettings:GetDefaultGuildBankSettings()
	return self:GetDefaultInventorySettings()
end
