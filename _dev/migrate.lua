--[[
    SavedVariables migration / repair scenario.

    Run with the legacy + corrupted database preloaded:
        node _dev/run.js migrate.lua sv_legacy.lua

    Asserts three separate things, because all three are easy to get wrong:
      1. corrupted values are repaired instead of erroring
      2. old formats are migrated
      3. deliberate user settings and unknown keys are NOT wiped
--]]

local say = MOCK.say
local failures, checks = 0, 0

local function Step(name) say('') say('== ' .. name .. ' ==') end
local function Check(cond, msg)
    checks = checks + 1
    if cond then say('  ok    ' .. msg)
    else failures = failures + 1 say('  FAIL  ' .. msg) end
    return cond
end
local function Note(msg) say('  ..    ' .. msg) end

local VALID_POINTS = {
    TOPLEFT = true, TOP = true, TOPRIGHT = true, LEFT = true, CENTER = true,
    RIGHT = true, BOTTOMLEFT = true, BOTTOM = true, BOTTOMRIGHT = true,
}
local function VALID_POINT_CHECK(p) return VALID_POINTS[p] == true end

local function eq(a, b) return a == b end
local function approx(a, b) return type(a) == 'number' and type(b) == 'number' and math.abs(a - b) < 0.0001 end

Step('load with a legacy 2.6.0 + partly corrupted database')
local before = #MOCK.errors
for _, name in ipairs({'Bagnon_Forever', 'Bagnon'}) do MOCK.loadAddon(name) end

local Bagnon = LibStub('AceAddon-3.0'):GetAddon('Bagnon')
Check(Bagnon ~= nil, 'Bagnon loaded on top of the legacy database')

-- Read every database straight away, BEFORE any window is created. Once a frame
-- exists it saves its own position back, and this harness has no real geometry,
-- so the stored anchors would stop being the ones the migration produced.
local db = Bagnon.SavedSettings:GetDB()
local invDB = Bagnon.SavedFrameSettings:Get('inventory'):GetDB()
local bankDB = Bagnon.SavedFrameSettings:Get('bank'):GetDB()
local keysDB = Bagnon.SavedFrameSettings:Get('keys'):GetDB()

local newErrors = {}
for i = before + 1, #MOCK.errors do newErrors[#newErrors + 1] = MOCK.errors[i] end
if not Check(#newErrors == 0, 'no runtime errors while reading the corrupted database') then
    for _, e in ipairs(newErrors) do say('          ' .. e) end
end

--[[ global settings ]]--

Step('global settings: repaired values')
Check(approx(db.highlightOpacity, 0.5), 'out-of-range highlightOpacity (5) reset to 0.5, got ' .. tostring(db.highlightOpacity))
Check(eq(db.itemBorderStyle, 'thin'), 'invalid itemBorderStyle "rainbow" reset to "thin", got ' .. tostring(db.itemBorderStyle))
Check(db.highlightQuestItems == true, 'wrongly-typed highlightQuestItems ("yes please") reset to true, got ' .. tostring(db.highlightQuestItems))
Check(type(db.slotColors.ammo) == 'table' and type(db.slotColors.ammo[1]) == 'number',
    'corrupted slotColors.ammo replaced with a real color')
-- an unknown color type that is still well formed is left alone on purpose:
-- the addon repairs what it knows is broken and never discards data it merely
-- does not recognise
Check(type(db.slotColors.bogus) == 'table', 'a well-formed but unknown slot color type was left alone')

Step('global settings: preserved user choices')
Check(db.highlightItemsByQuality == false, 'highlightItemsByQuality stayed false')
Check(db.colorBagSlots == false, 'colorBagSlots stayed false')
Check(db.lockFramePositions == true, 'lockFramePositions stayed true')
Check(db.enabledFrames.bank == false, 'the disabled bank window stayed disabled')
Check(db.autoDisplayEvents.inventory.bank == false, 'autoDisplayEvents.inventory.bank stayed false')
Check(type(db.slotColors.trade) == 'table' and approx(db.slotColors.trade[1], 0.1),
    'the custom trade slot color survived')
Check(db.unknownLegacyKey == 'keep me', 'an unknown legacy key was NOT wiped')

Step('global settings: migrated formats')
Check(db.autoDisplayEvents[1] == nil and db.autoDisplayEvents[2] == nil and db.autoDisplayEvents[3] == nil,
    'the pre-2.6.3 autoDisplayEvents array part was cleared')
Check(db.version == GetAddOnMetadata('Bagnon', 'Version'),
    'database version stamped forward to ' .. tostring(db.version))

--[[ frame settings ]]--

Step('frame settings: repaired values')
local frames = BagnonFrameSettings.frames
local inv = invDB
Check(type(inv) == 'table', 'the inventory frame entry is a table')
Check(frames.inventory == inv, 'the addon repaired the stored table in place (no data was replaced wholesale)')
Check(inv.point == 'BOTTOMRIGHT', 'invalid anchor "NOWHERE" reset to BOTTOMRIGHT, got ' .. tostring(inv.point))
Check(inv.x == 0 and inv.y == 150, 'x/y reset along with the invalid anchor, got ' .. tostring(inv.x) .. '/' .. tostring(inv.y))
Check(approx(inv.scale, 1), 'scale 0 reset to 1, got ' .. tostring(inv.scale))
Check(approx(inv.opacity, 1), 'opacity 0 reset to 1, got ' .. tostring(inv.opacity))
Check(inv.itemFrameColumns == 8, 'fractional itemFrameColumns (0.5) reset to 8, got ' .. tostring(inv.itemFrameColumns))
Check(inv.frameLayer == 'HIGH', 'invalid frameLayer "SUBSPACE" reset to HIGH, got ' .. tostring(inv.frameLayer))
Check(type(inv.frameColor[1]) == 'number', 'corrupted frameColor component replaced with a number')

Step('frame settings: migrated hiddenBags')
Note('hiddenBags now: ' .. (function()
    local parts = {}
    for k, v in pairs(inv.hiddenBags or {}) do parts[#parts + 1] = tostring(k) .. '=' .. tostring(v) end
    table.sort(parts)
    return table.concat(parts, ' ')
end)())
Check(inv.hiddenBags[2] == true, 'legacy hiddenBags {[1]=2} migrated to {[2]=true}')
Check(inv.hiddenBags[1] ~= 2, 'the legacy array entry is gone')

Step('frame settings: a non-table entry is replaced, not fatal')
Check(type(bankDB) == 'table', 'the corrupted bank entry ("this is not a table") became a table')
Check(bankDB.point ~= nil and bankDB.scale ~= nil, 'the replacement bank entry has real defaults')
Check(frames.bank == bankDB, 'the repaired bank entry was written back into the database')

Step('frame settings: a valid entry is preserved')
local keys = keysDB
Check(keys.point == 'TOPLEFT', 'keyring anchor preserved, got ' .. tostring(keys.point))
Check(keys.x == 42 and keys.y == -42, 'keyring position preserved, got ' .. tostring(keys.x) .. '/' .. tostring(keys.y))
Check(approx(keys.scale, 1.5), 'keyring scale preserved, got ' .. tostring(keys.scale))

--[[ offline cache ]]--

Step('now drive the UI on top of the migrated data')
local mark0 = #MOCK.errors
MOCK.loggedIn = true
MOCK.fire('PLAYER_LOGIN')
MOCK.fire('PLAYER_ENTERING_WORLD')
for bag = 0, 4 do MOCK.fire('BAG_UPDATE', bag) end
Bagnon:ToggleFrame('inventory')
MOCK.openBank()
MOCK.closeBank()
Bagnon:ToggleFrame('keys')
Bagnon:ToggleFrame('keys')
MOCK.update(0.2)
local errs0 = {}
for i = mark0 + 1, #MOCK.errors do errs0[#errs0 + 1] = MOCK.errors[i] end
if not Check(#errs0 == 0, 'the windows open and close cleanly on migrated settings') then
    for _, e in ipairs(errs0) do say('          ' .. e) end
end
Check(Bagnon:GetFrame('inventory') ~= nil, 'the inventory window was built')
Check(Bagnon:IsFrameEnabled('bank') == false, 'the bank window stayed disabled, as the user had it')

Step('offline cache with a stale character')
local BagnonDB = _G.BagnonDB
if Check(BagnonDB ~= nil, 'BagnonDB loaded') then
    local players = BagnonDB:GetPlayerList()
    local names = {}
    for _, p in ipairs(players) do names[#names + 1] = p end
    table.sort(names)
    Note('players: [' .. table.concat(names, ', ') .. ']')
    Check(#players >= 2, 'the stale "Ghost" character was kept alongside the live one')

    local fs = Bagnon.FrameSettings:Get('inventory')
    local mark = #MOCK.errors
    fs:SetPlayerFilter('Ghost')
    MOCK.update(0.2)
    local errs = {}
    for i = mark + 1, #MOCK.errors do errs[#errs + 1] = MOCK.errors[i] end
    if not Check(#errs == 0, 'viewing a stale offline character does not error') then
        for _, e in ipairs(errs) do say('          ' .. e) end
    end
    fs:SetPlayerFilter(nil)
    MOCK.update(0.2)
end

--[[ round trip ]]--

Step('logout, then reload the saved data a second time')

-- snapshot the EFFECTIVE values before logout. On logout the addon strips every
-- value that equals its default, so the file shrinks and users pick up improved
-- defaults later; the values themselves must still come back the same.
local snapshot = {
    opacity = BagnonGlobalSettings.highlightOpacity,
    border = BagnonGlobalSettings.itemBorderStyle,
    unknown = BagnonGlobalSettings.unknownLegacyKey,
    quality = BagnonGlobalSettings.highlightItemsByQuality,
    version = BagnonGlobalSettings.version,
}

MOCK.fire('PLAYER_LOGOUT')
Check(BagnonGlobalSettings.highlightOpacity == nil,
    'logout stripped highlightOpacity because it now equals the default (file stays small)')
Check(BagnonGlobalSettings.highlightItemsByQuality == false,
    'logout kept highlightItemsByQuality, because it differs from the default')
Note('after logout, the saved frames are: ' .. (function()
    local parts = {}
    for k in pairs(BagnonFrameSettings.frames) do parts[#parts + 1] = k end
    table.sort(parts)
    return table.concat(parts, ', ')
end)())

-- simulate the next session: drop the cached handles and read the DB again
Bagnon.SavedSettings.db = nil
Bagnon.SavedFrameSettings.db = nil
for id in pairs(Bagnon.SavedFrameSettings.objects) do
    Bagnon.SavedFrameSettings.objects[id].frameDB = nil
end

local mark = #MOCK.errors
local db2 = Bagnon.SavedSettings:GetDB()
local inv2 = Bagnon.SavedFrameSettings:Get('inventory'):GetDB()
local errs = {}
for i = mark + 1, #MOCK.errors do errs[#errs + 1] = MOCK.errors[i] end
if not Check(#errs == 0, 'reading the saved data back produced no errors') then
    for _, e in ipairs(errs) do say('          ' .. e) end
end

Check(approx(db2.highlightOpacity, snapshot.opacity), 'highlightOpacity is stable across a reload')
Check(db2.itemBorderStyle == snapshot.border, 'itemBorderStyle is stable across a reload')
Check(db2.unknownLegacyKey == snapshot.unknown, 'the unknown legacy key survived a full save/load cycle')
Check(db2.highlightItemsByQuality == snapshot.quality, 'the user choice survived a full save/load cycle')
Check(db2.version == GetAddOnMetadata('Bagnon', 'Version'), 'the version stamp is stable (migration is idempotent)')
Check(VALID_POINT_CHECK(inv2.point), 'the reloaded inventory anchor is still a valid anchor point: ' .. tostring(inv2.point))
Check(inv2.itemFrameColumns == 8, 'the repaired column count is stable')
Check(inv2.hiddenBags[2] == true, 'the migrated hiddenBags entry is stable')

Step('result')
say('  checks run: ' .. checks)
say('  failures:   ' .. failures)
say('  mock errors collected: ' .. #MOCK.errors)
for i, e in ipairs(MOCK.errors) do say('    [' .. i .. '] ' .. e) end
say('  addon chat output:')
for _, line in ipairs(MOCK.printed) do say('    ' .. line) end

return failures + #MOCK.errors
