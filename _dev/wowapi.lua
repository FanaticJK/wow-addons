--[[
    The game-state half of the 3.3.5 mock: player, bags, items, bank, guild bank,
    tooltips, dropdowns, popups and the global constants the addons read.

    Loaded after wowmock.lua. Still no catch-all: anything missing errors.
--]]

local newObject = MOCK.newObject

--[[ constants ]]--

NUM_BAG_SLOTS = 4
NUM_BANKBAGSLOTS = 7
NUM_BANKGENERIC_SLOTS = 28
BACKPACK_CONTAINER = 0
BANK_CONTAINER = -1
KEYRING_CONTAINER = -2
ITEM_INVENTORY_BANK_BAG_OFFSET = 67
CONTAINER_BAG_OFFSET = 19
MAX_CONTAINER_ITEMS = 20
MAX_GUILDBANK_SLOTS_PER_TAB = 98
NUM_GUILDBANK_COLUMNS = 7
COPPER_PER_SILVER = 100
SILVER_PER_GOLD = 100
COPPER_PER_GOLD = 10000

NORMAL_FONT_COLOR = {r = 1, g = 0.82, b = 0}
HIGHLIGHT_FONT_COLOR = {r = 1, g = 1, b = 1}
RED_FONT_COLOR_CODE = '|cffff2020'
GREEN_FONT_COLOR_CODE = '|cff20ff20'
GRAY_FONT_COLOR_CODE = '|cff808080'
YELLOW_FONT_COLOR_CODE = '|cffffff00'
NORMAL_FONT_COLOR_CODE = '|cffffd200'
HIGHLIGHT_FONT_COLOR_CODE = '|cffffffff'
FONT_COLOR_CODE_CLOSE = '|r'

ITEM_QUALITY_COLORS = {
    [0] = {r = 0.62, g = 0.62, b = 0.62, hex = '|cff9d9d9d'},
    [1] = {r = 1.00, g = 1.00, b = 1.00, hex = '|cffffffff'},
    [2] = {r = 0.12, g = 1.00, b = 0.00, hex = '|cff1eff00'},
    [3] = {r = 0.00, g = 0.44, b = 0.87, hex = '|cff0070dd'},
    [4] = {r = 0.64, g = 0.21, b = 0.93, hex = '|cffa335ee'},
    [5] = {r = 1.00, g = 0.50, b = 0.00, hex = '|cffff8000'},
    [6] = {r = 0.90, g = 0.80, b = 0.50, hex = '|cffe6cc80'},
    [7] = {r = 0.00, g = 0.80, b = 1.00, hex = '|cff00ccff'},
}
for i = 0, 7 do _G['ITEM_QUALITY' .. i .. '_DESC'] = 'Quality' .. i end

RAID_CLASS_COLORS = {
    WARRIOR = {r = 0.78, g = 0.61, b = 0.43, colorStr = 'ffc79c6e'},
    MAGE    = {r = 0.41, g = 0.80, b = 0.94, colorStr = 'ff69ccf0'},
    ROGUE   = {r = 1.00, g = 0.96, b = 0.41, colorStr = 'fffff569'},
    PRIEST  = {r = 1.00, g = 1.00, b = 1.00, colorStr = 'ffffffff'},
    DRUID   = {r = 1.00, g = 0.49, b = 0.04, colorStr = 'ffff7d0a'},
}
CLASS_ICON_TCOORDS = {
    WARRIOR = {0, 0.25, 0, 0.25}, MAGE = {0.25, 0.49, 0, 0.25},
    ROGUE = {0.49, 0.74, 0, 0.25}, PRIEST = {0.49, 0.74, 0.25, 0.5},
    DRUID = {0.74, 0.98, 0.25, 0.5},
}
LOCALIZED_CLASS_NAMES_MALE = {WARRIOR = 'Warrior', MAGE = 'Mage', ROGUE = 'Rogue', PRIEST = 'Priest', DRUID = 'Druid'}
LOCALIZED_CLASS_NAMES_FEMALE = LOCALIZED_CLASS_NAMES_MALE
FACTION_BAR_COLORS = {[4] = {r = 1, g = 1, b = 0}}

-- strings the addons format against
ACCEPT, CANCEL, CLOSE, OKAY, DEFAULT, NONE, ALL = 'Accept', 'Cancel', 'Close', 'Okay', 'Default', 'None', 'All'
RESET, ENABLE, DISABLE, SEARCH, CONTINUE, YES, NO = 'Reset', 'Enable', 'Disable', 'Search', 'Continue', 'Yes', 'No'
BANK, BAGSLOT, KEYRING, GUILD_BANK = 'Bank', 'Bag Slot', 'Keyring', 'Guild Bank'
COLOR, OPACITY, SCALE, GENERAL, DISPLAY, OPTIONS, SETTINGS = 'Color', 'Opacity', 'Scale', 'General', 'Display', 'Options', 'Settings'
LOCK_FRAME, UNLOCK_FRAME, REVERSE, COLUMNS, SPACING = 'Lock Frame', 'Unlock Frame', 'Reverse', 'Columns', 'Spacing'
LEVEL, LOW, HIGH, BACKGROUND, BORDER, EMPTY, ITEMS, KEY, MONEY = 'Level', 'Low', 'High', 'Background', 'Border', 'Empty', 'Items', 'Key', 'Money'
SORT, REPAIR, DEPOSIT, WITHDRAW, TAB, TAB1, TOTAL, REMOVE = 'Sort', 'Repair', 'Deposit', 'Withdraw', 'Tab', 'Tab 1', 'Total', 'Remove'
TUTORIAL, LOOT, TRADE, MAIL, AUCTION, CRAFTING, NOT_BOUND = 'Tutorial', 'Loot', 'Trade', 'Mail', 'Auction', 'Crafting', 'Not bound'
BACKPACK_TOOLTIP, BANK_BAG, BANK_BAG_PURCHASE, EQUIP_CONTAINER = 'Backpack', 'Bank Bag', 'Purchase Bank Bag', 'Equip Container'
CONFIRM_BUY_BANK_SLOT = 'Buy bank slot for %s?'
ITEM_SOULBOUND, ITEM_CONJURED = 'Soulbound', 'Conjured Item'
ITEM_BIND_ON_EQUIP, ITEM_BIND_ON_PICKUP = 'Binds when equipped', 'Binds when picked up'
ITEM_BIND_ON_USE, ITEM_BIND_QUEST, ITEM_BIND_TO_ACCOUNT = 'Binds when used', 'Quest Item', 'Binds to account'
INVENTORY_TOOLTIP = 'Inventory'
GUILDBANK_TAB_LOCKED, GUILDBANK_TAB_WITHDRAW_ONLY = 'Locked', 'Withdraw only'
GUILDBANK_TAB_DEPOSIT_ONLY, GUILDBANK_TAB_FULL_ACCESS = 'Deposit only', 'Full access'
TEXTURE_ITEM_QUEST_BANG = 'Interface/ContainerFrame/UI-Icon-QuestBang'
GAME_LOCALE = nil
SELECTED_CHAT_FRAME = nil
GameFontHighlightLarge = {}

--[[ root frames ]]--

UIParent = newObject('Frame', 'UIParent', nil)
UIParent:SetWidth(1024) UIParent:SetHeight(768)
WorldFrame = newObject('Frame', 'WorldFrame', nil)
Minimap = newObject('Frame', 'Minimap', UIParent)
Minimap:SetWidth(140) Minimap:SetHeight(140)
MinimapCluster = newObject('Frame', 'MinimapCluster', UIParent)
UIErrorsFrame = newObject('Frame', 'UIErrorsFrame', UIParent)
function UIErrorsFrame:AddMessage(msg) MOCK.printed[#MOCK.printed + 1] = 'ERRORFRAME: ' .. tostring(msg) end

UISpecialFrames = {}
UIPanelWindows = {}
INTERFACEOPTIONS_ADDONCATEGORIES = {}

for _, name in ipairs({'GameFontNormal', 'GameFontNormalSmall', 'GameFontNormalLarge',
                       'GameFontHighlight', 'GameFontHighlightSmall', 'GameFontDisable',
                       'GameFontDisableSmall', 'NumberFontNormal', 'NumberFontNormalSmall',
                       'NumberFontNormalYellow', 'ChatFontNormal'}) do
    local o = newObject('Font', name, nil)
    o.GetFont = function() return 'Fonts/FRIZQT__.TTF', 12, '' end
end

DEFAULT_CHAT_FRAME = newObject('Frame', 'DEFAULT_CHAT_FRAME', UIParent)
function DEFAULT_CHAT_FRAME:AddMessage(msg) MOCK.printed[#MOCK.printed + 1] = tostring(msg) end
ChatFrame1 = DEFAULT_CHAT_FRAME
SELECTED_DOCK_FRAME = DEFAULT_CHAT_FRAME
ChatFrame1EditBox = newObject('EditBox', 'ChatFrame1EditBox', UIParent)
function ChatEdit_GetActiveWindow() return nil end
function ChatEdit_ActivateChat() end
function ChatEdit_InsertLink(link) MOCK.lastLink = link return true end
function ChatFrame_OpenChat(text) MOCK.lastChat = text end
function GetCurrentKeyBoardFocus() return nil end
function MouseIsOver() return false end
function GetMouseFocus() return MOCK.mouseFocus end

--[[ player / realm ]]--

MOCK.player = {name = 'Tester', realm = 'MockRealm', class = 'WARRIOR', race = 'Human', sex = 2, level = 80, money = 12345678}

function UnitName(unit) if unit == 'player' then return MOCK.player.name end return unit end
function UnitClass(unit) return LOCALIZED_CLASS_NAMES_MALE[MOCK.player.class], MOCK.player.class end
function UnitRace() return MOCK.player.race, MOCK.player.race end
function UnitSex() return MOCK.player.sex end
function UnitLevel() return MOCK.player.level end
function UnitFactionGroup() return 'Alliance', 'Alliance' end
function UnitExists(unit) return unit == 'player' end
function UnitIsPlayer(unit) return unit == 'player' end
function UnitAffectingCombat() return MOCK.inCombat or false end
function UnitGUID() return '0xMOCK' end
function GetRealmName() return MOCK.player.realm end
function GetMoney() return MOCK.player.money end
function InCombatLockdown() return MOCK.inCombat or false end
function IsLoggedIn() return MOCK.loggedIn or false end
function GetLocale() return 'enUS' end
function GetBuildInfo() return '3.3.5', '12340', 'Dec 2 2009', 30300 end
function GetTime() MOCK.clock = (MOCK.clock or 1000) + 0.01 return MOCK.clock end
function GetFramerate() return 60 end
function IsShiftKeyDown() return MOCK.shift or false end
function IsControlKeyDown() return MOCK.ctrl or false end
function IsAltKeyDown() return MOCK.alt or false end
function IsModifiedClick() return false end
function GetCursorPosition() return 500, 400 end
function GetScreenWidth() return 1024 end
function GetScreenHeight() return 768 end
MOCK.cvars = {realmList = 'us.logon.worldofwarcraft.com'}
function GetCVar(k) return MOCK.cvars[k] end
function GetCVarBool(k) return false end
function SetCVar(k, v) MOCK.cvars[k] = v end
function PlaySound(s) MOCK.sounds[#MOCK.sounds + 1] = s end
function PlaySoundFile(s) MOCK.sounds[#MOCK.sounds + 1] = s end
function ReloadUI() MOCK.reloaded = true end
function Screenshot() end
function GetNumTalentTabs() return 3 end
function GetTalentTabInfo(i) return 'Tab' .. i, nil, 0 end
function IsInGuild() return true end
function GetGuildInfo() return 'Mock Guild', 'Member', 1 end
function GetCoinText(amount, sep)
    local g = floor(amount / COPPER_PER_GOLD)
    local s = floor((amount - g * COPPER_PER_GOLD) / COPPER_PER_SILVER)
    local c = amount % COPPER_PER_SILVER
    return format('%dg%ds%dc', g, s, c)
end
function GetCoinTextureString(amount) return GetCoinText(amount) end
function SetTooltipMoney(tooltip, money) tooltip:AddLine(GetCoinText(money or 0)) end
function MoneyFrame_Update() end
function SetMoneyFrameColor() end
MoneyTypeInfo = {PLAYER = {UpdateFunc = function() return GetMoney() end, collapse = 1}}
function OpenCoinPickupFrame() end
function GetCursorMoney() return 0 end
function DropCursorMoney() end

--[[ items ]]--

-- id -> {name, link, quality, level, minLevel, class, subclass, maxStack, equipSlot, texture, price}
MOCK.items = {
    [2589]  = {'Linen Cloth', 1, 1, 1, 'Trade Goods', 'Cloth', 20, '', 'Interface/Icons/INV_Fabric_Linen_01', 100},
    [2592]  = {'Wool Cloth', 1, 5, 5, 'Trade Goods', 'Cloth', 20, '', 'Interface/Icons/INV_Fabric_Wool_01', 200},
    [4306]  = {'Silk Cloth', 1, 20, 20, 'Trade Goods', 'Cloth', 20, '', 'Interface/Icons/INV_Fabric_Silk_01', 400},
    [6948]  = {'Hearthstone', 1, 1, 1, 'Miscellaneous', 'Junk', 1, '', 'Interface/Icons/INV_Misc_Rune_01', 0},
    [4544]  = {'Mulgore Spice Bread', 1, 25, 15, 'Consumable', 'Food', 20, '', 'Interface/Icons/INV_Misc_Food_11', 50},
    [7005]  = {'Skinning Knife', 1, 5, 1, 'Weapon', 'Knives', 1, 'INVTYPE_WEAPONMAINHAND', 'Interface/Icons/INV_Misc_Knife_1A', 30},
    [14047] = {'Runecloth', 1, 40, 40, 'Trade Goods', 'Cloth', 20, '', 'Interface/Icons/INV_Fabric_Purplefire_01', 600},
    [12643] = {'Heavy Leather', 1, 30, 25, 'Trade Goods', 'Leather', 20, '', 'Interface/Icons/INV_Misc_LeatherScrap_08', 300},
    [10940] = {'Strange Dust', 1, 5, 5, 'Trade Goods', 'Enchanting', 20, '', 'Interface/Icons/INV_Enchant_DustStrange', 150},
    [18422] = {'Head of Onyxia', 3, 60, 60, 'Quest', 'Quest', 1, '', 'Interface/Icons/INV_Misc_Head_Dragon_01', 0},
    [19019] = {'Thunderfury', 5, 80, 60, 'Weapon', 'One-Handed Swords', 1, 'INVTYPE_WEAPONMAINHAND', 'Interface/Icons/INV_Sword_39', 999999},
    [22589] = {'Atiesh', 4, 80, 60, 'Weapon', 'Staves', 1, 'INVTYPE_2HWEAPON', 'Interface/Icons/INV_Staff_75', 500000},
    [4238]  = {'Linen Bag', 1, 10, 5, 'Container', 'Bag', 1, '', 'Interface/Icons/INV_Misc_Bag_09', 250},
    [14156] = {'Bottomless Bag', 3, 60, 50, 'Container', 'Bag', 1, '', 'Interface/Icons/INV_Misc_Bag_28', 90000},
    [5976]  = {'Guild Tabard', 1, 1, 1, 'Armor', 'Miscellaneous', 1, 'INVTYPE_TABARD', 'Interface/Icons/INV_Shirt_GuildTabard_01', 100},
    [13262] = {'Ashbringer', 6, 80, 60, 'Weapon', 'Two-Handed Swords', 1, 'INVTYPE_2HWEAPON', 'Interface/Icons/INV_Sword_48', 0},
    [5956]  = {'Blacksmith Hammer', 1, 5, 1, 'Weapon', 'Miscellaneous', 1, '', 'Interface/Icons/INV_Hammer_20', 30},
    [1180]  = {'Scroll of Stamina', 1, 5, 1, 'Consumable', 'Scroll', 20, '', 'Interface/Icons/INV_Scroll_02', 40},
    [5514]  = {'Ironforge Key', 1, 1, 1, 'Key', 'Key', 1, '', 'Interface/Icons/INV_Misc_Key_03', 0},
    [5518]  = {'Gnomeregan Key', 1, 1, 1, 'Key', 'Key', 1, '', 'Interface/Icons/INV_Misc_Key_06', 0},
}

local function itemLink(id)
    local it = MOCK.items[id]
    if not it then return nil end
    local q = ITEM_QUALITY_COLORS[it[2]] or ITEM_QUALITY_COLORS[1]
    return q.hex .. '|Hitem:' .. id .. ':0:0:0:0:0:0:0:80|h[' .. it[1] .. ']|h|r'
end
MOCK.itemLink = itemLink

local function idFromLink(link)
    if type(link) == 'number' then return link end
    if type(link) ~= 'string' then return nil end
    return tonumber(link:match('item:(%d+)'))
end

function GetItemInfo(query)
    local id = idFromLink(query)
    if not id then
        -- allow lookup by name, like the client does for cached items
        for k, v in pairs(MOCK.items) do if v[1] == query then id = k break end end
    end
    local it = id and MOCK.items[id]
    if not it then return nil end
    return it[1], itemLink(id), it[2], it[3], it[4], it[5], it[6], it[7], it[8], it[9], it[10]
end

function GetItemQualityColor(q)
    local c = ITEM_QUALITY_COLORS[q] or ITEM_QUALITY_COLORS[1]
    return c.r, c.g, c.b, c.hex
end
function GetItemIcon(id) local it = MOCK.items[idFromLink(id)] return it and it[9] end
function GetItemFamily(id) return 0 end
function GetItemCooldown() return 0, 0, 0 end
function GetItemSpell() return nil end
function IsEquippableItem(q) local it = MOCK.items[idFromLink(q)] return it and it[8] ~= '' or false end
function IsConsumableItem(q) local it = MOCK.items[idFromLink(q)] return it and it[5] == 'Consumable' or false end
function IsUsableItem() return true end
function GetItemCount(query, includeBank)
    local want, n = idFromLink(query), 0
    for _, bagID in ipairs(MOCK.bagOrder(includeBank)) do
        for slot = 1, (MOCK.bags[bagID] and #MOCK.bags[bagID].slots or 0) do
            local s = MOCK.bags[bagID].slots[slot]
            if s and s.id == want then n = n + (s.count or 1) end
        end
    end
    return n
end

--[[ bags ]]--

-- bagID -> {size, slots = {[i] = {id, count, locked}}, bagItem = itemID}
MOCK.bags = {}

local function makeBag(id, size)
    MOCK.bags[id] = {size = size, slots = {}}
    return MOCK.bags[id]
end

local function put(bagID, slot, itemID, count)
    MOCK.bags[bagID].slots[slot] = {id = itemID, count = count or 1}
end
MOCK.put = put

function MOCK.bagOrder(includeBank)
    local t = {BACKPACK_CONTAINER, 1, 2, 3, 4}
    if includeBank then
        t[#t + 1] = BANK_CONTAINER
        for i = 5, 11 do t[#t + 1] = i end
    end
    return t
end

-- default world state: 72 inventory slots, 40 bank slots, 32 keyring slots
function MOCK.resetWorld()
    MOCK.bags = {}
    makeBag(BACKPACK_CONTAINER, 16)
    makeBag(1, 16) makeBag(2, 16) makeBag(3, 12) makeBag(4, 12)
    makeBag(BANK_CONTAINER, 28)
    makeBag(5, 12)
    for i = 6, 11 do makeBag(i, 0) end
    makeBag(KEYRING_CONTAINER, 32)

    MOCK.bags[1].bagItem = 4238
    MOCK.bags[2].bagItem = 4238
    MOCK.bags[3].bagItem = 14156
    MOCK.bags[4].bagItem = 14156
    MOCK.bags[5].bagItem = 4238

    put(BACKPACK_CONTAINER, 1, 6948)
    put(BACKPACK_CONTAINER, 2, 2589, 20)
    put(BACKPACK_CONTAINER, 3, 2589, 7)
    put(BACKPACK_CONTAINER, 4, 2592, 15)
    put(BACKPACK_CONTAINER, 6, 4544, 5)
    put(BACKPACK_CONTAINER, 9, 19019)
    put(1, 1, 4306, 20) put(1, 2, 4306, 3) put(1, 5, 10940, 11)
    put(1, 8, 18422) put(1, 12, 7005)
    put(2, 1, 14047, 20) put(2, 2, 12643, 9) put(2, 7, 22589)
    put(3, 3, 1180, 4) put(3, 4, 5956)
    put(4, 1, 5976) put(4, 2, 13262)
    put(BANK_CONTAINER, 1, 2589, 20) put(BANK_CONTAINER, 2, 2592, 20)
    put(BANK_CONTAINER, 15, 14047, 12)
    put(5, 1, 12643, 20)
    put(KEYRING_CONTAINER, 1, 5514)
    put(KEYRING_CONTAINER, 2, 5518)

    MOCK.numBankSlots = 5
    MOCK.bankOpen = false
    MOCK.guildBankOpen = false
    MOCK.cursor = nil
end
MOCK.resetWorld()

function GetContainerNumSlots(bagID)
    local b = MOCK.bags[bagID]
    return b and b.size or 0
end

function GetContainerNumFreeSlots(bagID)
    local b = MOCK.bags[bagID]
    if not b then return 0, 0 end
    local used = 0
    for i = 1, b.size do if b.slots[i] then used = used + 1 end end
    return b.size - used, 0
end

function GetContainerItemInfo(bagID, slot)
    local b = MOCK.bags[bagID]
    local s = b and b.slots[slot]
    if not s then return nil end
    local it = MOCK.items[s.id]
    -- texture, count, locked, quality, readable, lootable, link, filtered, noValue
    return it[9], s.count or 1, s.locked or false, it[2], false, false, itemLink(s.id), false, (it[10] == 0)
end

function GetContainerItemLink(bagID, slot)
    local b = MOCK.bags[bagID]
    local s = b and b.slots[slot]
    return s and itemLink(s.id) or nil
end

function GetContainerItemID(bagID, slot)
    local b = MOCK.bags[bagID]
    local s = b and b.slots[slot]
    return s and s.id or nil
end

function GetContainerItemCooldown() return 0, 0, 0 end
function GetContainerItemQuestInfo(bagID, slot)
    local id = GetContainerItemID(bagID, slot)
    local it = id and MOCK.items[id]
    if it and it[5] == 'Quest' then return false, 42, true end
    return nil, nil, false
end
function GetContainerItemDurability() return nil end
function GetContainerItemPurchaseInfo() return nil end
function GetContainerNumFreeSlotsTotal() return 0 end

-- The real client does NOT empty a slot on pickup: the item stays there, the
-- slot is flagged locked, and the move completes when the item is dropped.
-- BankStack's move engine depends on exactly that, so model it properly.
local function maxStack(itemID)
    local it = MOCK.items[itemID]
    return it and it[7] or 1
end

function PickupContainerItem(bagID, slot)
    local b = MOCK.bags[bagID]
    if not b then return end
    local here = b.slots[slot]

    if not MOCK.cursor then
        if not here then return end
        MOCK.cursor = {bag = bagID, slot = slot, id = here.id, count = here.count or 1}
        here.locked = true
        MOCK.fire('ITEM_LOCK_CHANGED', bagID, slot)
        return
    end

    local c = MOCK.cursor
    local fromBag = MOCK.bags[c.bag]
    local from = fromBag and fromBag.slots[c.slot]
    MOCK.cursor = nil

    if not from then                       -- source vanished; just drop the cursor
        MOCK.fire('ITEM_LOCK_CHANGED', bagID, slot)
        return
    end

    if here and here.id == from.id then    -- merge two stacks of the same item
        local cap = maxStack(here.id)
        local room = cap - (here.count or 1)
        local moved = min(room, c.count)
        here.count = (here.count or 1) + moved
        from.count = (from.count or 1) - moved
        if from.count <= 0 then fromBag.slots[c.slot] = nil else from.locked = false end
        here.locked = false
    else                                    -- plain swap
        fromBag.slots[c.slot] = here and {id = here.id, count = here.count} or nil
        b.slots[slot] = {id = from.id, count = from.count}
        if fromBag.slots[c.slot] then fromBag.slots[c.slot].locked = false end
        b.slots[slot].locked = false
    end

    MOCK.fire('ITEM_LOCK_CHANGED', c.bag, c.slot)
    MOCK.fire('ITEM_LOCK_CHANGED', bagID, slot)
    MOCK.fire('BAG_UPDATE', c.bag)
    if bagID ~= c.bag then MOCK.fire('BAG_UPDATE', bagID) end
end
function UseContainerItem(bagID, slot) MOCK.used = {bagID, slot} end
function SplitContainerItem(bagID, slot, count)
    local b = MOCK.bags[bagID]
    local here = b and b.slots[slot]
    if not here or MOCK.cursor then return end
    MOCK.cursor = {bag = bagID, slot = slot, id = here.id, count = min(count, here.count or 1), split = true}
    here.locked = true
    MOCK.fire('ITEM_LOCK_CHANGED', bagID, slot)
end
function ContainerIDToInventoryID(bagID) return bagID + CONTAINER_BAG_OFFSET end
function GetBagName(bagID)
    local b = MOCK.bags[bagID]
    if bagID == BACKPACK_CONTAINER then return BACKPACK_TOOLTIP end
    if bagID == KEYRING_CONTAINER then return KEYRING end
    if bagID == BANK_CONTAINER then return BANK end
    local it = b and b.bagItem and MOCK.items[b.bagItem]
    return it and it[1] or nil
end
function GetBackpackCurrencyInfo() return nil end

function CursorHasItem() return MOCK.cursor ~= nil end
function CursorHasItemSlot() return false end
function GetCursorInfo()
    if MOCK.cursor then return 'item', MOCK.cursor.id, itemLink(MOCK.cursor.id) end
end
function ClearCursor()
    local c = MOCK.cursor
    if c then
        local s = MOCK.bags[c.bag] and MOCK.bags[c.bag].slots[c.slot]
        if s then s.locked = false end
        MOCK.fire('ITEM_LOCK_CHANGED', c.bag, c.slot)
    end
    MOCK.cursor = nil
end
function ResetCursor() end
function SetCursor() end
function CursorUpdate() end
function CursorCanGoInSlot() return true end
function PutItemInBackpack() end
function PutItemInBag() end
function PutKeyInKeyRing() end
function PickupBagFromSlot() end
function PickupInventoryItem() end
function UseInventoryItem() end
function HandleModifiedItemClick(link) MOCK.lastLink = link return false end
function SetItemRef() end

function GetInventoryItemLink(unit, invSlot)
    local bagID = invSlot - CONTAINER_BAG_OFFSET
    local b = MOCK.bags[bagID]
    return b and b.bagItem and itemLink(b.bagItem) or nil
end
function GetInventoryItemTexture(unit, invSlot)
    local bagID = invSlot - CONTAINER_BAG_OFFSET
    local b = MOCK.bags[bagID]
    local it = b and b.bagItem and MOCK.items[b.bagItem]
    return it and it[9] or nil
end
function GetInventoryItemCount() return 1 end
function GetInventoryItemCooldown() return 0, 0, 0 end
function GetInventoryItemQuality(unit, invSlot)
    local bagID = invSlot - CONTAINER_BAG_OFFSET
    local b = MOCK.bags[bagID]
    local it = b and b.bagItem and MOCK.items[b.bagItem]
    return it and it[2] or nil
end
function GetInventorySlotInfo(name) return 20, 'Interface/Icons/Temp', true end
function IsInventoryItemLocked() return false end
function KeyRingButtonIDToInvSlotID(id) return 85 + id end
function HasKey() return true end
function GetKeyRingSize() return MOCK.bags[KEYRING_CONTAINER].size end
function IsBagOpen() return false end

function SetItemButtonTexture(button, texture)
    if button.__icon then button.__icon:SetTexture(texture) end
end
function SetItemButtonCount(button, count)
    if button.__count then button.__count:SetText(count and count > 1 and tostring(count) or '') end
end
function SetItemButtonDesaturated(button, desat)
    if button.__icon then button.__icon:SetDesaturated(desat) end
end
function SetItemButtonTextureVertexColor(button, r, g, b)
    if button.__icon then button.__icon:SetVertexColor(r, g, b) end
end
function SetItemButtonNormalTextureVertexColor(button, r, g, b)
    button:GetNormalTexture():SetVertexColor(r, g, b)
end
function SetItemButtonStock() end
function SetDesaturation(tex, desat) tex:SetDesaturated(desat) end

function ToggleBackpack() MOCK.toggled = 'backpack' end
function ToggleBag(id) MOCK.toggled = 'bag' .. id end
function ToggleAllBags() MOCK.toggled = 'all' end
function OpenBackpack() MOCK.toggled = 'openBackpack' end
function CloseBackpack() end
function OpenBag(id) MOCK.toggled = 'openBag' .. id end
function CloseBag() end
function OpenAllBags() MOCK.toggled = 'openAll' end
function CloseAllBags() end
function ContainerFrame_Update() end
function ContainerFrame_GetOpenFrame() return nil end
function ContainerFrameItemButton_OnEnter() end
function ContainerFrame_UpdateCooldown() end
function CooldownFrame_SetTimer() end

--[[ bank ]]--

BankFrame = MOCK.newObject('Frame', 'BankFrame', UIParent)
BankFrame:Hide()
BankFrame.__id = 1
function BankFrame_OnEvent() end
function BankFrameItemButton_Update() end
function BankButtonIDToInvSlotID(id, isBag) return isBag and (67 + id) or (38 + id) end
function GetNumBankSlots() return MOCK.numBankSlots, true end
function GetBankSlotCost() return 1000000 end
function PurchaseSlot() MOCK.numBankSlots = MOCK.numBankSlots + 1 end
function CloseBankFrame() MOCK.bankOpen = false MOCK.fire('BANKFRAME_CLOSED') end

function MOCK.openBank()
    MOCK.bankOpen = true
    MOCK.fire('BANKFRAME_OPENED')
    MOCK.fire('PLAYERBANKSLOTS_CHANGED', 1)
end
function MOCK.closeBank() CloseBankFrame() end

--[[ guild bank ]]--

MOCK.guildBank = {
    tabs = {
        {name = 'Consumables', icon = 'Interface/Icons/INV_Misc_Bag_09', canView = true, canDeposit = true, withdrawals = 100},
        {name = 'Trade Goods', icon = 'Interface/Icons/INV_Fabric_Linen_01', canView = true, canDeposit = true, withdrawals = 50},
    },
    items = {[1] = {[1] = {id = 2589, count = 20}, [5] = {id = 4544, count = 3}}, [2] = {[1] = {id = 14047, count = 20}}},
    money = 50000000,
    tab = 1,
}
GuildBankFrame = MOCK.newObject('Frame', 'GuildBankFrame', UIParent)
GuildBankFrame:Hide()
function GetCurrentGuildBankTab() return MOCK.guildBank.tab end
function SetCurrentGuildBankTab(t) MOCK.guildBank.tab = t MOCK.fire('GUILDBANKBAGSLOTS_CHANGED') end
function GetNumGuildBankTabs() return #MOCK.guildBank.tabs end
function GetGuildBankTabInfo(t)
    local tab = MOCK.guildBank.tabs[t]
    if not tab then return nil end
    return tab.name, tab.icon, tab.canView, tab.canDeposit, tab.withdrawals, 0
end
function GetGuildBankItemInfo(tab, slot)
    local s = MOCK.guildBank.items[tab] and MOCK.guildBank.items[tab][slot]
    if not s then return nil end
    local it = MOCK.items[s.id]
    return it[9], s.count, false, false
end
function GetGuildBankItemLink(tab, slot)
    local s = MOCK.guildBank.items[tab] and MOCK.guildBank.items[tab][slot]
    return s and itemLink(s.id) or nil
end
function GetGuildBankMoney() return MOCK.guildBank.money end
function GetGuildBankWithdrawMoney() return 100000 end
function GetGuildBankTabPermissions(t)
    local tab = MOCK.guildBank.tabs[t]
    if not tab then return false, false, 0, 0 end
    return tab.canView, tab.canDeposit, tab.withdrawals, 0
end
function QueryGuildBankTab(t) MOCK.fire('GUILDBANKBAGSLOTS_CHANGED') end
function QueryGuildBankLog() end
function AutoStoreGuildBankItem() end
function SplitGuildBankItem() end
function PickupGuildBankItem() end
function CanGuildBankRepair() return true end
function CanWithdrawGuildBankMoney() return true end
function DepositGuildBankMoney() end
function CloseGuildBankFrame() MOCK.guildBankOpen = false MOCK.fire('GUILDBANKFRAME_CLOSED') end

-- Blizzard's own guild bank UI is load-on-demand; UIParent calls this on
-- GUILDBANKFRAME_OPENED, and Bagnon_GuildBank hooks it to load itself instead.
function GuildBankFrame_LoadUI() MOCK.blizzardGuildBankLoaded = true end

function MOCK.openGuildBank()
    MOCK.guildBankOpen = true
    GuildBankFrame_LoadUI()          -- exactly what UIParent_OnEvent does first
    MOCK.fire('GUILDBANKFRAME_OPENED')
    MOCK.fire('GUILDBANKBAGSLOTS_CHANGED')
end

--[[ tooltips ]]--

function MOCK.makeTooltip(f)
    f.__lines = {}
    f.__owner = nil

    -- GameTooltipTemplate creates named TextLeftN font strings, and tooltip
    -- scanners (LibItemSearch, BankStack) read them by global name.
    local function syncLines(self)
        local name = self:GetName()
        if not name then return end
        for i = 1, max(#self.__lines, self.__namedLines or 0) do
            local fs = _G[name .. 'TextLeft' .. i]
            if not fs then
                fs = MOCK.newObject('FontString', name .. 'TextLeft' .. i, self)
            end
            fs:SetText(self.__lines[i] and self.__lines[i].text or nil)
            if not _G[name .. 'TextRight' .. i] then
                MOCK.newObject('FontString', name .. 'TextRight' .. i, self)
            end
        end
        self.__namedLines = #self.__lines
    end
    f.__syncLines = syncLines
    function f:SetOwner(owner, anchor) self.__owner = owner self.__anchor = anchor self.__lines = {} end
    function f:GetOwner() return self.__owner end
    function f:IsOwned(owner) return self.__owner == owner end
    function f:GetAnchorType() return self.__anchor or 'ANCHOR_RIGHT' end
    function f:ClearLines() self.__lines = {} syncLines(self) end
    function f:AddLine(text, r, g, b)
        self.__lines[#self.__lines + 1] = {text = text, r = r, g = g, b = b}
        syncLines(self)
    end
    function f:AddDoubleLine(l, r)
        self.__lines[#self.__lines + 1] = {text = tostring(l) .. ' :: ' .. tostring(r)}
        syncLines(self)
    end
    function f:NumLines() return #self.__lines end
    function f:GetLine(i) return self.__lines[i] and self.__lines[i].text end
    function f:SetText(t) self.__lines = {{text = t}} syncLines(self) end
    function f:AppendText(t)
        if self.__lines[1] then self.__lines[1].text = (self.__lines[1].text or '') .. t end
        syncLines(self)
    end
    function f:SetHyperlink(link)
        local id = tonumber(tostring(link):match('item:(%d+)'))
        local it = id and MOCK.items[id]
        self.__lines = {}
        if it then
            self:AddLine(it[1])
            if it[5] == 'Quest' then self:AddLine(ITEM_BIND_QUEST) end
            if it[2] >= 4 then self:AddLine(ITEM_SOULBOUND) end
            self:AddLine('Item Level ' .. it[3])
            if it[7] > 1 then self:AddLine('Max Stack: ' .. it[7]) end
        end
        syncLines(self)
        self:Show()
        MOCK.fire('TOOLTIP_SHOWN')
    end
    function f:SetBagItem(bag, slot)
        local link = GetContainerItemLink(bag, slot)
        if link then self:SetHyperlink(link) else self.__lines = {} end
        return false
    end
    function f:SetInventoryItem(unit, invSlot)
        local link = GetInventoryItemLink(unit, invSlot)
        if link then self:SetHyperlink(link) end
        return false
    end
    function f:SetGuildBankItem(tab, slot)
        local link = GetGuildBankItemLink(tab, slot)
        if link then self:SetHyperlink(link) end
    end
    function f:SetHeight_() end
    -- the tooltip fires its OnShow/OnHide scripts like any frame
    return f
end

GameTooltip = CreateFrame('GameTooltip', 'GameTooltip', UIParent)
GameTooltip:Hide()
GameTooltipTextLeft1 = MOCK.newObject('FontString', 'GameTooltipTextLeft1', GameTooltip)
ItemRefTooltip = CreateFrame('GameTooltip', 'ItemRefTooltip', UIParent)
ItemRefTooltip:Hide()

--[[ dropdowns ]]--

UIDROPDOWNMENU_MENU_VALUE = nil
UIDROPDOWNMENU_MENU_LEVEL = 1
UIDROPDOWNMENU_OPEN_MENU = nil
UIDROPDOWNMENU_INIT_MENU = nil
DropDownList1 = MOCK.newObject('Frame', 'DropDownList1', UIParent)
DropDownList1:Hide()

function UIDropDownMenu_CreateInfo() return {} end
function UIDropDownMenu_Initialize(frame, init, displayMode, level)
    frame.__ddInit = init
    frame.__ddButtons = {}
end
function UIDropDownMenu_AddButton(info, level)
    local frame = UIDROPDOWNMENU_INIT_MENU
    if frame then
        frame.__ddButtons = frame.__ddButtons or {}
        frame.__ddButtons[#frame.__ddButtons + 1] = info
    end
end
function UIDropDownMenu_SetWidth(frame, w) frame.__ddWidth = w end
function UIDropDownMenu_SetText(frame, t) frame.__ddText = t end
function UIDropDownMenu_SetSelectedValue(frame, v) frame.__ddValue = v end
function UIDropDownMenu_GetSelectedValue(frame) return frame.__ddValue end
function UIDropDownMenu_JustifyText() end
function UIDropDownMenu_DisableDropDown() end
function UIDropDownMenu_EnableDropDown() end
function ToggleDropDownMenu(level, value, frame) MOCK.openDropDown = frame end
function CloseDropDownMenus() MOCK.openDropDown = nil end

-- run a dropdown's initializer and return the buttons it produced
function MOCK.buildDropDown(frame, level, value)
    UIDROPDOWNMENU_INIT_MENU = frame
    UIDROPDOWNMENU_MENU_LEVEL = level or 1
    UIDROPDOWNMENU_MENU_VALUE = value
    frame.__ddButtons = {}
    local init = frame.__ddInit or frame.initialize
    if not init then return {} end
    local ok, err = pcall(init, frame, level or 1)
    if not ok then MOCK.errors[#MOCK.errors + 1] = 'dropdown: ' .. tostring(err) end
    UIDROPDOWNMENU_INIT_MENU = nil
    return frame.__ddButtons or {}
end

--[[ color picker ]]--

ColorPickerFrame = MOCK.newObject('Frame', 'ColorPickerFrame', UIParent)
ColorPickerFrame:Hide()
function ColorPickerFrame:SetColorRGB(r, g, b) self.__rgb = {r, g, b} end
function ColorPickerFrame:GetColorRGB() return table.unpack(self.__rgb or {1, 1, 1}) end
OpacitySliderFrame = MOCK.newObject('Slider', 'OpacitySliderFrame', ColorPickerFrame)
function ColorPicker_GetPreviousValues() return table.unpack(ColorPickerFrame.__rgb or {1, 1, 1}) end
function OpenColorPicker(info)
    ColorPickerFrame.__info = info
    ColorPickerFrame:Show()
    MOCK.colorPicker = info
end

--[[ static popups ]]--

StaticPopupDialogs = {}
function StaticPopup_Show(which, a, b, data)
    MOCK.popups[#MOCK.popups + 1] = {which = which, data = data, a = a, b = b}
    MOCK.currentPopup = which
    return StaticPopupDialogs[which]
end
function StaticPopup_Hide(which) MOCK.currentPopup = nil end
function StaticPopup_Visible(which) return MOCK.currentPopup == which end

-- press "accept" on the most recent popup
function MOCK.acceptPopup()
    local p = MOCK.popups[#MOCK.popups]
    if not p then return false, 'no popup shown' end
    local d = StaticPopupDialogs[p.which]
    if not d then return false, 'popup ' .. tostring(p.which) .. ' not registered' end
    if d.OnAccept then
        local ok, err = pcall(d.OnAccept, {data = p.data}, p.data)
        if not ok then MOCK.errors[#MOCK.errors + 1] = 'popup OnAccept: ' .. tostring(err) end
    end
    MOCK.currentPopup = nil
    return true, p.which
end

--[[ interface options ]]--

InterfaceOptionsFrame = MOCK.newObject('Frame', 'InterfaceOptionsFrame', UIParent)
InterfaceOptionsFrame:Hide()
InterfaceOptionsFramePanelContainer = MOCK.newObject('Frame', 'InterfaceOptionsFramePanelContainer', InterfaceOptionsFrame)
MOCK.optionsCategories = {}
function InterfaceOptions_AddCategory(frame)
    MOCK.optionsCategories[#MOCK.optionsCategories + 1] = frame
    table.insert(INTERFACEOPTIONS_ADDONCATEGORIES, frame)
    return frame
end
function InterfaceOptionsFrame_OpenToCategory(frame)
    MOCK.openedCategory = frame
    InterfaceOptionsFrame:Show()
    if type(frame) == 'table' then frame:Show() end
end
function ShowUIPanel(f) if f then f:Show() end end
function HideUIPanel(f) if f then f:Hide() end end

--[[ addons ]]--

function GetAddOnMetadata(addon, field)
    local a = MOCK.addons[addon]
    return a and a.metadata and a.metadata[field:lower()] or nil
end
function GetNumAddOns()
    local n = 0
    for _ in pairs(MOCK.addons) do n = n + 1 end
    return n
end
function GetAddOnInfo(name)
    local a = MOCK.addons[name]
    if not a then return nil end
    return name, a.metadata and a.metadata.title or name, a.metadata and a.metadata.notes or '', true, 'LOADED'
end
function IsAddOnLoaded(name) return MOCK.loaded[name] or false end
function EnableAddOn() end
function DisableAddOn() end
function LoadAddOn(name)
    if MOCK.loaded[name] then return true end
    local ok, err = MOCK.loadAddon(name)
    if not ok then MOCK.errors[#MOCK.errors + 1] = 'LoadAddOn(' .. name .. '): ' .. tostring(err) end
    return ok
end

--[[ bindings / slash ]]--

SlashCmdList = {}
hash_SlashCmdList = {}
MOCK.bindings = {}
function GetBindingKey(action) return MOCK.bindings[action] end
function GetBindingAction(key) for a, k in pairs(MOCK.bindings) do if k == key then return a end end return '' end
function SetBinding(key, action) MOCK.bindings[action] = key return true end
function SetBindingClick(key, frame) return true end
function SaveBindings() end
function GetCurrentBindingSet() return 1 end

-- run a slash command the way the chat box would
function MOCK.slash(text)
    local cmd, rest = text:match('^(%S+)%s*(.*)$')
    if not cmd then return false, 'empty command' end
    for name, handler in pairs(SlashCmdList) do
        local i = 1
        while _G['SLASH_' .. name .. i] do
            if _G['SLASH_' .. name .. i]:lower() == cmd:lower() then
                local ok, err = pcall(handler, rest, ChatFrame1EditBox)
                if not ok then MOCK.errors[#MOCK.errors + 1] = 'slash ' .. text .. ': ' .. tostring(err) end
                return true, name
            end
            i = i + 1
        end
    end
    return false, 'no handler for ' .. cmd
end

--[[ misc leftovers the bundled libs touch ]]--

function GetSpellInfo(id) return 'Spell' .. tostring(id), '', 'Interface/Icons/Temp' end
function GetSpellCooldown() return 0, 0, 0 end
function GetItemInfoInstant(q)
    local id = tonumber(tostring(q):match('item:(%d+)')) or tonumber(q)
    local it = id and MOCK.items[id]
    if not it then return nil end
    return id, it[5], it[6], it[8], it[9], 0, 0
end
function GetNumEquipmentSets() return 0 end
function GetEquipmentSetInfo() return nil end
function GetEquipmentSetItemIDs() return {} end
function EquipmentManager_UnpackLocation() return false, false, false, nil, nil end
function GetAuctionItemClasses() return 'Weapon', 'Armor', 'Trade Goods' end
function GetAuctionItemSubClasses() return 'Cloth', 'Leather' end
AUCTION_CATEGORY_WEAPONS = 1
LE_ITEM_QUALITY_POOR = 0
function GetMinimapShape() return 'ROUND' end
function PanelTemplates_TabResize() end
function PanelTemplates_SetDisabledTabState() end
function PanelTemplates_SelectTab() end
function PanelTemplates_DeselectTab() end
function AceGUIEditBoxInsertLink() end
function AceGUIMultiLineEditBoxInsertLink() end
function UIFrameFadeIn(frame, duration, from, to) frame:SetAlpha(to) end
function UIFrameFadeOut(frame, duration, from, to) frame:SetAlpha(to) end
CharacterFrame = MOCK.newObject('Frame', 'CharacterFrame', UIParent)
CharacterFrame:Hide()
StackSplitFrame = MOCK.newObject('Frame', 'StackSplitFrame', UIParent)
StackSplitFrame:Hide()
function OpenStackSplitFrame() StackSplitFrame:Show() end
function IsBagSlotFlagEnabled() return false end
newproxy = function() return {} end
