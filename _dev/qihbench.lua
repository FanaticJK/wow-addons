--[[
    QuestItemHelper work-count benchmark.

        node _dev/run.js qihbench.lua

    Wall-clock time under fengari (a Lua VM written in JavaScript) says nothing about the WoW
    client, so this counts work instead: client API calls, bag scans, quest-log reads, header
    toggles and tables allocated, across fixed, deterministic workloads. The numbers are exact
    and repeatable, and comparable between two versions of the addon run on the same workload.

    Prints one "BENCH name value" line per metric. Returns 0; the gate asserts the budgets that
    matter in qih.lua ("work budgets").
--]]

local say = MOCK.say

-- count calls to client APIs. Must wrap BEFORE the addon loads: it caches them as upvalues.
local calls = {}
local function count(name)
    local real = _G[name]
    calls[name] = 0
    _G[name] = function(...)
        calls[name] = calls[name] + 1
        return real(...)
    end
end
for _, name in ipairs({'GetContainerItemID', 'GetContainerItemLink', 'GetItemInfo', 'GetContainerItemQuestInfo',
    'GetQuestLogTitle', 'GetNumQuestLogEntries', 'GetQuestLogLeaderBoard', 'ExpandQuestHeader', 'CollapseQuestHeader'}) do
    count(name)
end
local function snapshot()
    local t = {}
    for k, v in pairs(calls) do t[k] = v end
    return t
end
local function since(before, name) return calls[name] - (before[name] or 0) end

local function Settle()
    for _ = 1, 3 do
        MOCK.clock = MOCK.clock + 2
        MOCK.update(0.1)
    end
end
local function report(name, value) say(string.format('BENCH %-44s %s', name, tostring(value))) end

--[[ world: a full set of bags with a few quest items, a 20-quest log with 4 collapsed zones ]]--

local function questItem(id, name)
    MOCK.items[id] = {name, 1, 1, 1, 'Quest', 'Quest', 20, '', 'Interface/Icons/INV_Misc_Note_01', 0}
    MOCK.questInfo[id] = {true, nil}
end
for i = 0, 9 do questItem(60000 + i, 'Bench Item ' .. i) end
for slot = 1, 10 do MOCK.put(4, slot + 2, 60000 + slot - 1) end

MOCK.questLog = {}
for zone = 1, 5 do
    MOCK.questLog[#MOCK.questLog + 1] = {header = 'Zone ' .. zone, collapsed = zone > 1}
    for q = 1, 4 do
        local id = zone * 100 + q
        MOCK.questLog[#MOCK.questLog + 1] = {title = 'Quest ' .. id, id = id,
            objectives = {{'Bench Item ' .. ((zone + q) % 10) .. ': 0/5', 'item'}, {'Mobs slain: 0/8', 'monster'}}}
    end
end

QuestItemHelperDB = nil
QuestItemHelperCharDB = nil
MOCK.loadAddon('QuestItemHelper')
local QIH = _G.QuestItemHelper

local scans, fullScans, refreshes = 0, 0, 0
local realScan, realRefresh = QIH.ScanBags, QIH.RefreshButtons
QIH.ScanBags = function(self, all)
    scans = scans + 1
    if all then fullScans = fullScans + 1 end
    return realScan(self, all)
end
QIH.RefreshButtons = function(self, ...)
    refreshes = refreshes + 1
    return realRefresh(self, ...)
end

-- 120 tracked buttons, as with Bagnon's inventory and bank open
local container = CreateFrame('Frame', 'ContainerFrame1', UIParent)
container:SetID(4)
container.size = 12
for i = 1, 12 do
    local b = CreateFrame('Button', 'ContainerFrame1Item' .. i, container)
    b:SetID(i) b:SetWidth(37) b:SetHeight(37)
end
local extra = CreateFrame('Frame', nil, UIParent)
for i = 1, 108 do
    local b = CreateFrame('Button', nil, extra)
    b:SetWidth(37) b:SetHeight(37)
    QIH:UpdateButton(b, 1 + (i % 4), 1 + (i % 12))
end

--[[ 1. login ]]--

MOCK.loggedIn = true
local b = snapshot()
MOCK.fire('PLAYER_LOGIN')
MOCK.fire('PLAYER_ENTERING_WORLD')
MOCK.fire('QUEST_LOG_UPDATE')
Settle()
ContainerFrame_Update(container)
report('login: GetContainerItemID', since(b, 'GetContainerItemID'))
report('login: GetItemInfo', since(b, 'GetItemInfo'))
report('login: GetQuestLogTitle', since(b, 'GetQuestLogTitle'))
report('login: header toggles', since(b, 'ExpandQuestHeader') + since(b, 'CollapseQuestHeader'))
report('login: bag scans (full)', scans .. ' (' .. fullScans .. ')')

--[[ 2. looting: 50 bursts of BAG_UPDATE on two bags ]]--

scans, fullScans, refreshes = 0, 0, 0
b = snapshot()
for _ = 1, 50 do
    MOCK.fire('BAG_UPDATE', 0) MOCK.fire('BAG_UPDATE', 2) MOCK.fire('BAG_UPDATE', 0)
    Settle()
end
report('loot x50: GetContainerItemID', since(b, 'GetContainerItemID'))
report('loot x50: GetItemInfo', since(b, 'GetItemInfo'))
report('loot x50: bag scans (full)', scans .. ' (' .. fullScans .. ')')
report('loot x50: RefreshButtons', refreshes)

--[[ 3. questing: 50 QUEST_LOG_UPDATE with objective progress only ]]--

scans, fullScans, refreshes = 0, 0, 0
b = snapshot()
for i = 1, 50 do
    MOCK.questLog[2].objectives[2][1] = 'Mobs slain: ' .. (i % 8) .. '/8'
    MOCK.fire('QUEST_LOG_UPDATE')
    MOCK.fire('UNIT_QUEST_LOG_CHANGED', 'player')
    Settle()
end
report('progress x50: GetQuestLogTitle', since(b, 'GetQuestLogTitle'))
report('progress x50: header toggles', since(b, 'ExpandQuestHeader') + since(b, 'CollapseQuestHeader'))
report('progress x50: bag scans (full)', scans .. ' (' .. fullScans .. ')')
report('progress x50: RefreshButtons', refreshes)

--[[ 4. the addon switched off: 50 looting bursts ]]--

QIH.db.enabled = false
QIH:Invalidate()
Settle()
scans, fullScans, refreshes = 0, 0, 0
b = snapshot()
for _ = 1, 50 do
    MOCK.fire('BAG_UPDATE', 0)
    Settle()
end
report('disabled loot x50: RefreshButtons', refreshes)
report('disabled loot x50: GetContainerItemID', since(b, 'GetContainerItemID'))
QIH.db.enabled = true
QIH:Invalidate()
Settle()

--[[ 5. one item the client never caches, while looting for a minute ]]--

MOCK.uncached[60009] = true   -- GetItemInfo now returns nil for it
QIH:FullRescan()
scans, fullScans, refreshes = 0, 0, 0
b = snapshot()
for _ = 1, 30 do              -- a BAG_UPDATE every ~2 seconds
    MOCK.fire('BAG_UPDATE', 0)
    for _ = 1, 2 do MOCK.clock = MOCK.clock + 1 MOCK.update(0.1) end
end
Settle() Settle() Settle()
report('stuck item, 30 loots: bag scans (full)', scans .. ' (' .. fullScans .. ')')
report('stuck item, 30 loots: RefreshButtons', refreshes)
report('stuck item, 30 loots: GetContainerItemID', since(b, 'GetContainerItemID'))
MOCK.uncached[60009] = nil

-- (No memory metric: fengari does not implement collectgarbage('count'), so allocation in the
-- completed-quest handler is reasoned about in MODERNIZATION_LOG, not measured.)

say('')
return 0
