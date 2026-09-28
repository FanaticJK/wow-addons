--[[
    End-to-end smoke scenario.

    Drives the addons through a realistic session: login, opening the inventory /
    bank / keyring windows, searching, changing every layout option, hovering and
    clicking items, the whole options UI, the guild bank, the slash commands and
    finally logout, then reports what the SavedVariables ended up looking like.

    Returns the number of failed checks; run.js turns that into the exit code.
--]]

local say = MOCK.say
local failures = 0
local checks = 0

local function Step(name)
    say('')
    say('== ' .. name .. ' ==')
end

local function Check(cond, msg)
    checks = checks + 1
    if cond then
        say('  ok    ' .. msg)
    else
        failures = failures + 1
        say('  FAIL  ' .. msg)
    end
    return cond
end

local function Note(msg) say('  ..    ' .. msg) end

local function errorsSince(mark)
    local out = {}
    for i = mark + 1, #MOCK.errors do out[#out + 1] = MOCK.errors[i] end
    return out
end

-- run f, report any runtime error it produced as a failed check
local function Quiet(label, f, ...)
    local mark = #MOCK.errors
    local ok, err = pcall(f, ...)
    if not ok then
        failures = failures + 1
        say('  FAIL  ' .. label .. ' raised: ' .. tostring(err))
        return false
    end
    local new = errorsSince(mark)
    if #new > 0 then
        failures = failures + 1
        say('  FAIL  ' .. label .. ' logged ' .. #new .. ' error(s):')
        for _, e in ipairs(new) do say('          ' .. e) end
        return false
    end
    checks = checks + 1
    say('  ok    ' .. label)
    return true
end

-- GetAllItemSlots returns an iterator, not a table
local function itemCount(frame)
    local n = 0
    local f = frame and frame:GetItemFrame()
    if f then for _ in f:GetAllItemSlots() do n = n + 1 end end
    return n
end

--[[ 1. load ]]--

Step('load addons')
for _, name in ipairs({'BankStack', 'Bagnon_Forever', 'Bagnon', 'Bagnon_Tooltips'}) do
    local mark = #MOCK.errors
    local ok, err = MOCK.loadAddon(name)
    local new = errorsSince(mark)
    if not Check(ok and #new == 0, 'loaded ' .. name) then
        say('          ' .. tostring(err))
        for _, e in ipairs(new) do say('          ' .. e) end
    end
end

local Bagnon = LibStub('AceAddon-3.0'):GetAddon('Bagnon')
Check(Bagnon ~= nil, 'Bagnon addon object exists')
Check(_G.Bagnon == Bagnon, 'the global Bagnon is still the addon table (not a frame)')

--[[ 2. login ]]--

Step('login')
MOCK.loggedIn = true
Quiet('PLAYER_LOGIN', MOCK.fire, 'PLAYER_LOGIN')
Quiet('PLAYER_ENTERING_WORLD', MOCK.fire, 'PLAYER_ENTERING_WORLD')
Quiet('BAG_UPDATE x5', function()
    for bag = 0, 4 do MOCK.fire('BAG_UPDATE', bag) end
end)
Quiet('one OnUpdate tick', MOCK.update, 0.1)

--[[ 3. the inventory window ]]--

Step('inventory window')
Quiet('ToggleFrame(inventory)', function() Bagnon:ToggleFrame('inventory') end)
local inv = Bagnon:GetFrame('inventory')
Check(inv ~= nil, 'inventory frame created')
Check(inv and inv:IsShown(), 'inventory frame is shown')

if inv then
    local slots = itemCount(inv)
    Check(slots == 72, 'inventory shows all 72 item slots (got ' .. slots .. ')')
    Check(inv:GetWidth() > 0 and inv:GetHeight() > 0,
        'inventory has a non-zero size (' .. floor(inv:GetWidth()) .. 'x' .. floor(inv:GetHeight()) .. ')')

    local title = inv:GetTitleFrame()
    local text = title and title:GetText()
    Check(type(text) == 'string' and text ~= '', 'title reads: ' .. tostring(text))
    Check(text and not text:find('%%s'), 'the title format string was actually substituted')

    local counter = inv:HasSlotCounter() and inv:GetSlotCounter()
    if counter then
        local free, total = counter:GetCounts()
        Check(type(free) == 'number' and type(total) == 'number' and total == 72,
            'slot counter reports ' .. tostring(free) .. '/' .. tostring(total))
    else
        Note('slot counter not enabled for this frame')
    end
end

--[[ 4. search ]]--

Step('text search')
local settings = Bagnon.Settings
local function searchFor(text, label)
    Quiet('search ' .. label, function()
        settings:SetTextSearch(text)
        MOCK.update(0.5)
    end)
end
searchFor('linen', '"linen" (plain text)')
searchFor('[', '"[" (malformed Lua pattern - must not error)')
searchFor('%', '"%" (dangling escape)')
searchFor('q>=2', '"q>=2" (quality operator)')
searchFor('bag:1', '"bag:1"')
searchFor('type:cloth', '"type:cloth"')
searchFor('ilvl>10', '"ilvl>10"')
searchFor('', 'cleared')

--[[ 5. layout options ]]--

Step('layout options')
local fs = Bagnon.FrameSettings:Get('inventory')
Check(fs ~= nil, 'inventory FrameSettings exist')

if fs then
    Quiet('columns 8 -> 12 -> 8', function()
        fs:SetItemFrameColumns(12) MOCK.update(0.1)
        fs:SetItemFrameColumns(8)
    end)
    Quiet('spacing 2 -> 8 -> 2', function()
        fs:SetItemFrameSpacing(8) MOCK.update(0.1)
        fs:SetItemFrameSpacing(2)
    end)
    Quiet('bag break on/off', function()
        fs:SetBagBreak(true) MOCK.update(0.1)
        fs:SetBagBreak(false)
    end)
    Quiet('reverse slot order on/off', function()
        fs:SetReverseSlotOrder(true) MOCK.update(0.1)
        fs:SetReverseSlotOrder(false)
    end)
    Quiet('scale 0.5 / 1.5 / 1', function()
        fs:SetScale(0.5) fs:SetScale(1.5) fs:SetScale(1)
    end)
    Quiet('opacity 0 / 1 / 0.8', function()
        fs:SetOpacity(0) fs:SetOpacity(1) fs:SetOpacity(0.8)
    end)
    Quiet('background + border colors', function()
        fs:SetColor(0.2, 0.1, 0.1, 0.9)
        fs:SetBorderColor(1, 0.8, 0, 1)
    end)
    Quiet('every frame layer', function()
        for _, layer in ipairs(fs:GetAvailableLayers()) do fs:SetLayer(layer) end
    end)
    Quiet('toggle slot counter', function()
        fs:SetHasSlotCounter(false) MOCK.update(0.1)
        fs:SetHasSlotCounter(true)
    end)
    Quiet('toggle sort button', function()
        fs:SetHasSortButton(false) MOCK.update(0.1)
        fs:SetHasSortButton(true)
    end)
    Quiet('toggle money frame', function()
        fs:SetHasMoneyFrame(false) MOCK.update(0.1)
        fs:SetHasMoneyFrame(true)
    end)
    Quiet('toggle bag frame', function()
        fs:SetHasBagFrame(true) MOCK.update(0.1)
        fs:ToggleBagFrame() MOCK.update(0.1)
        fs:ShowBagFrame()
    end)
    -- GetBagSlots returns an iterator, like most of the Bagnon accessors.
    -- Some slots start hidden (the keyring is hidden inside the inventory frame),
    -- so record the original visibility and put it back afterwards.
    Quiet('hide/show individual bag slots', function()
        local slots, wasShown = {}, {}
        for _, slot in fs:GetBagSlots() do
            slots[#slots + 1] = slot
            wasShown[slot] = fs:IsBagSlotShown(slot)
        end
        Note('frame owns ' .. #slots .. ' bag slots')
        for _, slot in ipairs(slots) do
            fs:HideBagSlot(slot)
            MOCK.update(0.05)
            fs:ShowBagSlot(slot)
            MOCK.update(0.05)
        end
        for _, slot in ipairs(slots) do
            if wasShown[slot] then fs:ShowBagSlot(slot) else fs:HideBagSlot(slot) end
        end
        MOCK.update(0.1)
    end)

    -- the item slots must survive all of that
    local slots = itemCount(inv)
    Check(slots == 72, 'still 72 item slots after every layout change (got ' .. slots .. ')')
end

--[[ 6. mouse interaction ]]--

Step('mouse interaction')
if inv then
    local hovered, clicked = 0, 0
    Quiet('hover + leave every item slot', function()
        for _, slot in inv:GetItemFrame():GetAllItemSlots() do
            slot:Fire('OnEnter')
            hovered = hovered + 1
            slot:Fire('OnLeave')
        end
    end)
    Note('hovered ' .. hovered .. ' slots')

    Quiet('shift-click an item (chat link)', function()
        MOCK.shift = true
        for _, slot in inv:GetItemFrame():GetAllItemSlots() do
            if slot.GetItem and slot:GetItem() then slot:Click('LeftButton') clicked = clicked + 1 break end
        end
        MOCK.shift = false
    end)
    Note('clicked ' .. clicked .. ' item slot(s)')

    -- sorting is BankStack moving real items around; nothing may be lost
    local function inventoryTotals()
        local t = {}
        for _, bagID in ipairs(MOCK.bagOrder(false)) do
            local bag = MOCK.bags[bagID]
            for i = 1, bag.size do
                local s = bag.slots[i]
                if s then t[s.id] = (t[s.id] or 0) + (s.count or 1) end
            end
        end
        return t
    end

    if inv:HasSortButton() then
        local before = inventoryTotals()
        Quiet('click the sort button and let the sort finish', function()
            inv:GetSortButton():Click('LeftButton')
            for _ = 1, 200 do MOCK.update(0.1) end
        end)
        local after = inventoryTotals()
        local lost = {}
        for id, n in pairs(before) do
            if (after[id] or 0) ~= n then
                lost[#lost + 1] = (MOCK.items[id] and MOCK.items[id][1] or id) ..
                    ' ' .. n .. '->' .. tostring(after[id] or 0)
            end
        end
        for id, n in pairs(after) do
            if not before[id] then lost[#lost + 1] = 'appeared: ' .. tostring(id) .. ' x' .. n end
        end
        Check(#lost == 0, 'sorting conserved every item (' .. table.concat(lost, ', ') .. ')')
        local slots = itemCount(inv)
        Check(slots == 72, 'inventory still has 72 slots after sorting (got ' .. slots .. ')')
    else
        Note('no sort button on this frame')
    end

    Quiet('hover the slot counter', function()
        if inv:HasSlotCounter() then
            inv:GetSlotCounter():Fire('OnEnter')
            inv:GetSlotCounter():Fire('OnLeave')
        end
    end)

    Quiet('hover the money frame', function()
        if inv:HasMoneyFrame() then
            inv:GetMoneyFrame():Fire('OnEnter')
            inv:GetMoneyFrame():Fire('OnLeave')
        end
    end)
end

--[[ 7. tooltips ]]--

Step('tooltips')
Quiet('GameTooltip:SetHyperlink on a stackable item', function()
    GameTooltip:SetOwner(UIParent, 'ANCHOR_RIGHT')
    GameTooltip:SetHyperlink(MOCK.itemLink(2589))
end)
Note('tooltip lines: ' .. GameTooltip:NumLines())
Check(GameTooltip:NumLines() > 0, 'tooltip produced at least one line')

--[[ 8. bank + keyring ]]--

Step('bank')
Quiet('bank opened', MOCK.openBank)
local bank = Bagnon:GetFrame('bank')
if Check(bank ~= nil, 'bank frame created on BANKFRAME_OPENED') then
    Check(bank:IsShown(), 'bank frame is shown')
    local slots = itemCount(bank)
    Check(slots == 40, 'bank shows 40 slots (28 generic + 12 in the one bank bag), got ' .. slots)
end
Quiet('bank closed', MOCK.closeBank)
Check(not (bank and bank:IsShown()), 'bank frame hidden on BANKFRAME_CLOSED')

Step('keyring')
Quiet('ToggleFrame(keys)', function() Bagnon:ToggleFrame('keys') end)
local keys = Bagnon:GetFrame('keys')
if Check(keys ~= nil, 'keyring frame created') then
    local slots = itemCount(keys)
    Check(slots == 32, 'keyring shows 32 slots (got ' .. slots .. ')')
end
Quiet('ToggleFrame(keys) again', function() Bagnon:ToggleFrame('keys') end)

--[[ 9. cached characters (Bagnon_Forever) ]]--

Step('cached characters')
local BagnonDB = _G.BagnonDB
if Check(BagnonDB ~= nil, 'BagnonDB exists (Bagnon_Forever loaded)') then
    -- GetPlayers is an iterator; GetPlayerList returns the sorted table
    local players = {}
    for _, p in ipairs(BagnonDB:GetPlayerList()) do players[#players + 1] = p end
    Note('cached players: [' .. table.concat(players, ', ') .. ']')
    Check(#players > 0, 'the current character was recorded in BagnonDB')

    if fs and #players > 0 then
        Quiet('switch the inventory to a cached character', function()
            fs:SetPlayerFilter(players[1])
            MOCK.update(0.2)
        end)
        Quiet('switch back to the live character', function()
            fs:SetPlayerFilter(nil)
            MOCK.update(0.2)
        end)
    end

    if inv and inv:HasPlayerSelector() then
        Quiet('open the player selector dropdown', function()
            local sel = inv:GetPlayerSelector()
            sel:Click('LeftButton')
            local buttons = MOCK.buildDropDown(MOCK.openDropDown or sel, 1)
            Note('player selector offered ' .. #buttons .. ' entries')
        end)
    else
        Note('inventory has no player selector')
    end
end

--[[ 10. Bagnon_Tooltips ownership lines ]]--

Step('item ownership tooltips')
Quiet('tooltip on an item the player owns', function()
    GameTooltip:SetOwner(UIParent, 'ANCHOR_RIGHT')
    GameTooltip:SetHyperlink(MOCK.itemLink(2589))
    MOCK.fire('TOOLTIP_SHOWN')
end)
local lines = {}
for i = 1, GameTooltip:NumLines() do lines[#lines + 1] = tostring(GameTooltip:GetLine(i)) end
Note('lines: ' .. table.concat(lines, ' | '))

--[[ 11. the options UI ]]--

Step('options UI')
Quiet('ShowOptions()', function() Bagnon:ShowOptions() end)
Check(MOCK.loaded['Bagnon_Config'] == true, 'Bagnon_Config was loaded on demand')
Check(_G.Bagnon == Bagnon, 'the global Bagnon survived loading Bagnon_Config')

Quiet('ShowFrameOptions(inventory)', function() Bagnon:ShowFrameOptions('inventory') end)

-- click every control in every options panel
local buttons, sliders, dropdowns = 0, 0, 0
Quiet('exercise every options widget', function()
    for _, f in ipairs({table.unpack(MOCK.frames)}) do
        local name = f:GetName()
        if name and name:find('^Bagnon') then
            if f.__kind == 'CheckButton' or f.__kind == 'Button' then
                if f.__scripts.OnClick then
                    f:Fire('OnEnter')
                    f:Click('LeftButton')
                    f:Click('LeftButton')   -- back to where it was
                    f:Fire('OnLeave')
                    buttons = buttons + 1
                end
            elseif f.__kind == 'Slider' then
                local lo, hi = f:GetMinMaxValues()
                local was = f:GetValue()
                f:SetValue(lo) f:SetValue(hi) f:SetValue(was)
                sliders = sliders + 1
            end
        end
    end
end)
Note('clicked ' .. buttons .. ' buttons, moved ' .. sliders .. ' sliders')
Check(buttons > 0, 'the options UI actually produced clickable controls')

-- every control must fit the panel area of the 3.3.5 Interface Options window (413x428).
-- The panels used to be laid out for a ~620px wide window and spilled out of it.
for _, key in ipairs({'GeneralOptions', 'FrameOptions', 'DisplayOptions', 'ColorOptions'}) do
    local panel = Bagnon[key]
    local placed = panel and panel.boxes and #panel.boxes or 0
    Check(placed > 0, key .. ' tracked the layout of its controls (' .. placed .. ')')
    local overflow = panel and panel:GetLayoutOverflow()
    Check(not overflow, key .. ' fits inside the options window'
        .. (overflow and (': ' .. table.concat(overflow, ', ')) or ''))
end

-- the windows must still be intact after all that clicking
if inv then
    local slots = itemCount(inv)
    Check(slots == 72, 'inventory still has 72 slots after the options pass (got ' .. slots .. ')')
end

--[[ 12. guild bank ]]--

Step('guild bank')
Quiet('guild bank opened', MOCK.openGuildBank)
Check(MOCK.loaded['Bagnon_GuildBank'] == true, 'Bagnon_GuildBank was loaded on demand')
-- the guild bank window belongs to the GuildBank module, not Bagnon:GetFrame()
local gbModule = Bagnon:GetModule('GuildBank', true)
local gb = gbModule and gbModule:GetFrame()
if Check(gb ~= nil, 'guild bank frame created') then
    Check(gb:IsShown(), 'guild bank frame is shown')
    local slots = itemCount(gb)
    Check(slots == MAX_GUILDBANK_SLOTS_PER_TAB,
        'guild bank shows a full tab of ' .. MAX_GUILDBANK_SLOTS_PER_TAB .. ' slots (got ' .. slots .. ')')
    Quiet('switch guild bank tabs', function()
        for tab = 1, GetNumGuildBankTabs() do
            SetCurrentGuildBankTab(tab)
            MOCK.update(0.1)
        end
    end)
    Quiet('hover every guild bank slot', function()
        for _, slot in gb:GetItemFrame():GetAllItemSlots() do
            slot:Fire('OnEnter')
            slot:Fire('OnLeave')
        end
    end)
end
Quiet('guild bank closed', CloseGuildBankFrame)
Check(not (gb and gb:IsShown()), 'guild bank frame hidden on GUILDBANKFRAME_CLOSED')

--[[ 13. slash commands ]]--

Step('slash commands')
for _, cmd in ipairs({'/bagnon', '/bagnon bags', '/bagnon bank', '/bagnon keys',
                      '/bagnon version', '/bagnon help', '/bagnon config',
                      '/bagnon nonsense', '/bagnon debug'}) do
    local mark = #MOCK.errors
    local ok, which = MOCK.slash(cmd)
    local new = errorsSince(mark)
    if not Check(ok and #new == 0, cmd) then
        say('          ' .. tostring(which))
        for _, e in ipairs(new) do say('          ' .. e) end
    end
end

--[[ 14. reset positions ]]--

Step('reset frame positions')
-- earlier steps (toggling frames in the options UI) queue their own popups
wipe(MOCK.popups)
Quiet('ResetFramePositions()', function() Bagnon:ResetFramePositions() end)
if #MOCK.popups > 0 then
    local ok, which = MOCK.acceptPopup()
    Check(ok, 'confirmation popup accepted (' .. tostring(which) .. ')')
else
    Note('no confirmation popup was shown')
end

--[[ 15. combat ]]--

Step('combat lockdown')
Quiet('enter combat and toggle windows', function()
    MOCK.inCombat = true
    MOCK.fire('PLAYER_REGEN_DISABLED')
    Bagnon:ToggleFrame('inventory')
    Bagnon:ToggleFrame('inventory')
    MOCK.update(0.2)
    MOCK.inCombat = false
    MOCK.fire('PLAYER_REGEN_ENABLED')
    MOCK.update(0.2)
end)

--[[ 16. logout and SavedVariables ]]--

Step('logout')
Quiet('PLAYER_LOGOUT', MOCK.fire, 'PLAYER_LOGOUT')

local function describe(v, depth)
    depth = depth or 0
    if type(v) ~= 'table' then return tostring(v) end
    if depth > 1 then return '{...}' end
    local keys = {}
    for k in pairs(v) do keys[#keys + 1] = tostring(k) end
    table.sort(keys)
    return '{' .. table.concat(keys, ',') .. '}'
end

Step('SavedVariables after logout')
for _, addon in ipairs(MOCK.loadOrder) do
    local vars = MOCK.savedVariables(addon)
    for _, var in ipairs(vars) do
        local v = _G[var]
        say(string.format('  %-28s %-8s %s', var, type(v), describe(v)))
        Check(v == nil or type(v) == 'table' or type(v) == 'string' or type(v) == 'number' or type(v) == 'boolean',
            var .. ' is a serializable type')
    end
end

Step('result')
say('  checks run: ' .. checks)
say('  failures:   ' .. failures)
say('  mock errors collected: ' .. #MOCK.errors)
for i, e in ipairs(MOCK.errors) do say('    [' .. i .. '] ' .. e) end
if #MOCK.printed > 0 then
    say('  addon chat output:')
    for _, line in ipairs(MOCK.printed) do say('    ' .. line) end
end

return failures + #MOCK.errors
