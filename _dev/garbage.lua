--[[
    Unrecoverably corrupted SavedVariables.
        node _dev/run.js garbage.lua sv_garbage.lua
    The addon must notice, tell the user, and come up with working defaults.
--]]
local say = MOCK.say
local failures, checks = 0, 0
local function Check(cond, msg)
    checks = checks + 1
    if cond then say('  ok    ' .. msg) else failures = failures + 1 say('  FAIL  ' .. msg) end
    return cond
end

say('== load on top of garbage ==')
for _, name in ipairs({'Bagnon_Forever', 'Bagnon'}) do MOCK.loadAddon(name) end
local Bagnon = LibStub('AceAddon-3.0'):GetAddon('Bagnon')

MOCK.loggedIn = true
MOCK.fire('PLAYER_LOGIN')
MOCK.fire('PLAYER_ENTERING_WORLD')
for bag = 0, 4 do MOCK.fire('BAG_UPDATE', bag) end
Bagnon:ToggleFrame('inventory')
MOCK.openBank()
MOCK.closeBank()
Bagnon:ToggleFrame('keys')
MOCK.update(0.2)
MOCK.fire('PLAYER_LOGOUT')

Check(#MOCK.errors == 0, 'no runtime errors at all')
for i, e in ipairs(MOCK.errors) do say('          [' .. i .. '] ' .. e) end

Check(type(BagnonGlobalSettings) == 'table', 'BagnonGlobalSettings was rebuilt as a table')
Check(type(BagnonFrameSettings) == 'table', 'BagnonFrameSettings was rebuilt as a table')
Check(BagnonGlobalSettings.version == GetAddOnMetadata('Bagnon', 'Version'), 'the new database is stamped with the current version')
Check(Bagnon:GetFrame('inventory') ~= nil, 'the inventory window still works')
local inv = Bagnon:GetFrame('inventory')
local n = 0
for _ in inv:GetItemFrame():GetAllItemSlots() do n = n + 1 end
Check(n == 72, 'the inventory still shows all 72 slots (got ' .. n .. ')')

local told = false
for _, line in ipairs(MOCK.printed) do
    if line:lower():find('corrupt') or line:lower():find('reset') or line:lower():find('default') then told = true end
end
Check(told, 'the user was told the settings could not be read')
say('  addon chat output:')
for _, line in ipairs(MOCK.printed) do say('    ' .. line) end

say('')
say('  checks run: ' .. checks .. '  failures: ' .. failures)
return failures + #MOCK.errors
