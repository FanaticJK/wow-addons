--[[
	Bagnon Localization Information: English Language
		This file must be present to have partial translations
--]]

local L = LibStub('AceLocale-3.0'):NewLocale('Bagnon', 'enUS', true)

--keybinding text
L.ToggleBags = 'Toggle Inventory'
L.ToggleBank = 'Toggle Bank'
L.ToggleKeys = 'Toggle Keyring'


--system messages
L.NewUser = 'New user detected, default settings loaded'
L.Updated = 'Updated to v%s'
L.UpdatedIncompatible = 'Updating from an incompatible version, defaults loaded'
L.SettingsCorrupted = 'Saved settings were unreadable and have been reset to defaults'
L.ConfigUnavailable = 'The options menu requires the Bagnon_Config addon. Enable it in the AddOns list at the character select screen.'
L.FramePositionsReset = 'All Bagnon frames have been moved back to their default positions.'
L.DebugEnabled = 'Debug output enabled.'
L.DebugDisabled = 'Debug output disabled.'
L.SortRequiresBankStack = 'Sorting requires the BankStack addon.'
L.SortRequiresBank = 'You must be at the bank to sort it.'


--slash commands
L.Commands = 'Commands:'
L.CmdShowInventory = 'Toggles the inventory frame'
L.CmdShowBank = 'Toggles the bank frame'
L.CmdShowKeyring = 'Toggles the keyring'
L.CmdShowVersion = 'Prints the current version'
L.CmdShowConfig = 'Opens the options menu'
L.CmdReset = 'Moves all frames back to their default positions'
L.CmdDebug = 'Toggles debug output'


--frame text
L.TitleBags = '%s\'s Inventory'
L.TitleBank = '%s\'s Bank'
L.TitleKeys = '%s\'s Keys'
L.TitleGuildBank = '%s\'s Guild Bank'
L.SearchPlaceholder = 'Search items'
L.SelectBrokerPlugin = 'Scroll or click the arrows to pick a DataBroker plugin'


--tooltips
L.TipBank = 'Bank'
L.TipChangePlayer = 'Click to view another character\'s items.'
L.TipGoldOnRealm = '%s Totals'
L.TipHideBag = 'Click to hide this bag.'
L.TipHideBags = 'Click to hide the bag frame.'
L.TipHideSearch = 'Click to hide the search frame.'
L.TipPurchaseBag = 'Click to purchase this bank slot.'
L.TipShowBag = 'Click to show this bag.'
L.TipShowBags = 'Click to show the bag frame.'
L.TipShowMenu = 'Right-Click to configure this frame.'
L.TipShowSearch = 'Click to search.'
L.TipShowFrameConfig = 'Click to configure this frame.'
L.TipDoubleClickSearch = 'Drag to move (Alt-Drag when frames are locked).\nRight-Click to configure.\nDouble-Click to search.'
L.TipSearchHelp = 'Search by name, or use filters:\n  q:epic   t:armor   ilvl>200\n  boe   bop   quest   s:<equipment set>\nCombine with & (and) or | (or), negate with !'
L.TipViewingCharacter = 'Viewing %s'
L.Total = 'Total'

--sort button
L.TipSort = 'Sort'
L.TipSortBags = '<Left Click> to sort your bags.'
L.TipSortBank = '<Left Click> to sort your bank.'
L.TipCompressBags = '<Right Click> to merge partial stacks.'
L.TipStackToBank = '<Shift Left Click> to fill bank stacks from your bags.'
L.TipStackToBags = '<Shift Left Click> to fill bag stacks from your bank.'
L.TipSortRunning = 'Sorting... click to abort.'

--free slot counter
L.TipFreeSlots = 'Free Slots'
L.TipFreeSlotsDetail = '%d of %d slots free'
L.TipSpecialtySlots = 'Specialty bags: %d of %d free'

--guild bank
L.TipGuildFunds = 'Guild Funds'
L.TipGuildDeposit = '<Left Click> to deposit.'
L.TipGuildWithdraw = '<Right Click> to withdraw.'
L.TipGuildWithdrawRemaining = '<Right Click> to withdraw (%s remaining).'
L.TipTabUnavailable = 'Unavailable'

--databroker plugin tooltips
L.TipShowBank = '<Shift Left Click> to toggle your bank.'
L.TipShowInventory = '<Left Click> to toggle your inventory.'
L.TipShowKeyring = '<Alt Left Click> to toggle your keyring.'
L.TipShowOptions = '<Right Click> to open the options menu.'
