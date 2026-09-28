--[[
	SavedFrameSettings.lua
		behold the monkeypatching
--]]

local Bagnon = LibStub('AceAddon-3.0'):GetAddon('Bagnon')
local SavedFrameSettings = Bagnon.SavedFrameSettings

function SavedFrameSettings:GetDefaultGuildBankSettings()
	local defaults = SavedFrameSettings.guildBankDefaults or {
		--tabs are handled by the tab frame, not bag slots
		availableBags = {},
		hiddenBags = {},

		--frame
		frameColor = {0.04, 0.04, 0.05, 0.9},
		frameBorderColor = {0.35, 0.75, 0.35, 1},
		scale = 1,
		opacity = 1,
		point = 'CENTER',
		x = 0,
		y = 0,
		frameLayer = 'HIGH',

		--itemFrame
		itemFrameColumns = 14,
		itemFrameSpacing = 2,
		bagBreak = false,
		reverseSlotOrder = false,

		--optional components
		hasMoneyFrame = true, --guild funds, deposits and withdrawals
		hasBagFrame = true,
		hasDBOFrame = true,
		hasSearchToggle = true,
		hasOptionsToggle = true,
		hasSortButton = false,
		hasSlotCounter = false,

		--dbo display object
		dataBrokerObject = 'BagnonLauncher',
	}

	SavedFrameSettings.guildBankDefaults = defaults
	return defaults
end