--[[
    QuestItemHelper scenario.

        node _dev/run.js qih.lua

    Drives the whole verdict pipeline against the mock quest log:
      1. a damaged SavedVariables file is repaired without losing the readable parts
      2. every verdict path in QIH:Evaluate (active objective, learned link, quest starter,
         daily, unlinked, onlyCompleted) gives the documented answer
      3. collapsed quest log headers are read and then restored exactly as the player left them
      4. a turn-in seen on the reward panel is recorded, a cancelled reward panel is not
      5. the server's completed-quest history only replaces the cache when it really arrived
      6. overlays on Blizzard and Bagnon item buttons follow the verdicts and the settings
      7. tooltips gain lines only for judged items
      8. the options panel fits the 3.3.5 options area and disables dependent controls
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

local function errorsSince(mark)
    local out = {}
    for i = mark + 1, #MOCK.errors do out[#out + 1] = MOCK.errors[i] end
    return out
end
local function NoNewErrors(mark, label)
    local new = errorsSince(mark)
    if not Check(#new == 0, label) then
        for _, e in ipairs(new) do say('          ' .. e) end
    end
end

-- let the addon's debounce timer fire: move the clock past any pending delay, run OnUpdate
local function Settle()
    for _ = 1, 3 do
        MOCK.clock = MOCK.clock + 2
        MOCK.update(0.1)
    end
end

local function printedSince(mark)
    local out = {}
    for i = mark + 1, #MOCK.printed do out[#out + 1] = MOCK.printed[i] end
    return table.concat(out, '\n')
end

--[[ world ]]--

-- id -> {name, quality, ilvl, minLevel, class, subclass, maxStack, equipSlot, texture, price}
local function questItem(id, name)
    MOCK.items[id] = {name, 1, 1, 1, 'Quest', 'Quest', 20, '', 'Interface/Icons/INV_Misc_Note_01', 0}
end
questItem(50001, 'Bear Pelt')      -- objective of an active quest
questItem(50002, 'Old Letter')     -- learned link to a quest no longer in the log
questItem(50003, 'Strange Orb')    -- starts a quest that was turned in
questItem(50004, 'Daily Token')    -- learned link to a daily
questItem(50005, 'Mystery Shard')  -- no known quest at all
questItem(50006, 'Signal Flare')   -- the "use" item of a quest under a collapsed header

MOCK.questInfo[50003] = {false, 300}
MOCK.questInfo[50001] = {true, nil}
MOCK.questInfo[50002] = {true, nil}
MOCK.questInfo[50004] = {true, nil}
MOCK.questInfo[50005] = {true, nil}
MOCK.questInfo[50006] = {true, nil}

-- the backpack holds the quest items, bag 1 keeps the usual mock contents
for slot = 1, 16 do MOCK.bags[BACKPACK_CONTAINER].slots[slot] = nil end
MOCK.put(BACKPACK_CONTAINER, 1, 50001, 2)
MOCK.put(BACKPACK_CONTAINER, 2, 50002)
MOCK.put(BACKPACK_CONTAINER, 3, 50003)
MOCK.put(BACKPACK_CONTAINER, 4, 50004)
MOCK.put(BACKPACK_CONTAINER, 5, 50005)
MOCK.put(BACKPACK_CONTAINER, 6, 50006)
MOCK.put(BACKPACK_CONTAINER, 7, 2589, 20)

MOCK.questLog = {
    {header = 'Elwynn Forest'},
    {title = 'Bear Necessities', id = 100, objectives = {{'Bear Pelt: 2/5', 'item'}, {'Bears slain: 1/3', 'monster'}}},
    {header = 'Stormwind', collapsed = true},
    {title = 'Light the Way', id = 500, special = 50006, objectives = {{'Signal fired: 0/1', 'event'}}},
}
MOCK.questSelection = 2
MOCK.questsCompleted = {[300] = true, [42] = true}

--[[ SavedVariables: a partly damaged file from an earlier version ]]--

QuestItemHelperDB = {
    enabled = true,
    showIcon = false,                       -- a real user choice, must survive
    highlightColor = {r = 0 / 0, g = 0.25, b = 5},  -- NaN and out of range
    tickColor = 'green',                    -- wrong type
    futureOption = 'keep me',               -- unknown key from a newer version
    knowledge = {
        links = {
            [50002] = {[200] = true, oops = true},   -- one damaged quest key inside a valid entry
            [50004] = {[400] = true},
            [50099] = 'garbage',            -- damaged entry
        },
        titles = {[200] = 'Lost Correspondence', [400] = 'Daily Hunt', [1] = {}},
        daily = {[400] = true},
    },
}
QuestItemHelperCharDB = {completed = {[999] = true}}

--[[ 1. load ]]--

Step('load Bagnon, then QuestItemHelper (OptionalDeps order)')
local mark, printMark = #MOCK.errors, #MOCK.printed
for _, name in ipairs({'Bagnon_Forever', 'Bagnon'}) do
    MOCK.loadAddon(name)
end
-- every global that exists before QuestItemHelper loads, to catch accidental global writes
-- (check.js only catches undefined global READS)
local globalsBefore = {}
for k in pairs(_G) do globalsBefore[k] = true end
MOCK.loadAddon('QuestItemHelper')
NoNewErrors(mark, 'loaded without runtime errors')

local QIH = _G.QuestItemHelper
Check(type(QIH) == 'table' and QIH.db ~= nil, 'QuestItemHelper initialised its database')

Step('SavedVariables repair')
local db = QIH.db
Check(db.showIcon == false, 'the user choice showIcon=false survived')
Check(db.futureOption == 'keep me', 'an unknown key was not discarded')
Check(db.highlightColor.r == 1, 'NaN highlight red reset to the default, got ' .. tostring(db.highlightColor.r))
Check(db.highlightColor.g == 0.25, 'valid highlight green kept, got ' .. tostring(db.highlightColor.g))
Check(db.highlightColor.b == 0, 'out-of-range highlight blue reset to the default, got ' .. tostring(db.highlightColor.b))
Check(type(db.tickColor) == 'table' and db.tickColor.g == 1, 'wrongly-typed tickColor rebuilt from the defaults')
Check(db.knowledge.links[50099] == nil, 'the damaged link entry was dropped')
Check(db.knowledge.links[50002] and db.knowledge.links[50002][200], 'the readable link entries were kept')
Check(db.knowledge.links[50002].oops == nil, 'a non-numeric quest key inside a link was dropped (table.sort would throw on it)')
Check(db.knowledge.titles[1] == nil and db.knowledge.titles[200] == 'Lost Correspondence', 'only the damaged title was dropped')
Check(printedSince(printMark):find('removed 3 damaged entries', 1, true) ~= nil, 'the player was told about the repair')
Check(QuestItemHelperCharDB.completed[999] == true, 'the cached completed-quest history was loaded')

--[[ 2. login and first scan ]]--

Step('login, quest log read and first scan')
MOCK.loggedIn = true
mark = #MOCK.errors
local queriesBefore = MOCK.questQueries or 0
MOCK.fire('PLAYER_LOGIN')
Check((MOCK.questQueries or 0) == queriesBefore + 1, 'completed quests were requested from the server at login')
MOCK.fire('PLAYER_ENTERING_WORLD')
MOCK.fire('QUEST_LOG_UPDATE')
Settle()
NoNewErrors(mark, 'first scan raised no errors')
Check(QIH:IsReady(), 'the quest log was read')
Check(QIH:IsQuestActive(500), 'a quest under a collapsed header was read')
Check(MOCK.questLog[3].collapsed == true, 'the collapsed header was collapsed again afterwards')
Check(MOCK.questSelection == 2, 'the quest log selection was restored')

-- the server's history arrives: replaces the cache
MOCK.fire('QUEST_QUERY_COMPLETE')
Settle()
Check(QIH:IsQuestCompleted(300) and not QIH:IsQuestCompleted(999), 'the server history replaced the cached one')

local function state(id)
    local v = QIH:GetVerdict(id)
    return v.state, v.reason
end
local function expect(id, wantState, wantReason, label)
    local s, r = state(id)
    Check(s == wantState and (not wantReason or r == wantReason),
        label .. ': ' .. tostring(s) .. ' (' .. tostring(r) .. ')')
end

Step('no accidental globals')
local leaked = {}
for k in pairs(_G) do
    if not globalsBefore[k] and type(k) == 'string'
    and not k:find('^QuestItemHelper') and not k:find('^SLASH_QUESTITEMHELPER') then
        leaked[#leaked + 1] = k
    end
end
table.sort(leaked)
Check(#leaked == 0, 'loading and the first scan created only QuestItemHelper* globals'
    .. (#leaked > 0 and (': ' .. table.concat(leaked, ', ')) or ''))

Step('verdicts')
expect(50001, 'ACTIVE', 'quest_active', 'objective item of a quest in the log')
expect(50002, 'FLAG', 'inactive', 'item linked to a quest no longer in the log')
expect(50003, 'FLAG', 'starter_done', 'starter of a turned-in quest')
expect(50004, 'NONE', 'daily', 'item linked to a daily')
expect(50005, 'NONE', 'unknown', 'unlinked quest item (flagUnlinked off)')
expect(50006, 'ACTIVE', 'quest_active', '"use" item of a quest under a collapsed header')
expect(2589, 'NONE', 'not_quest_item', 'ordinary trade good')
Check(db.knowledge.links[50001] and db.knowledge.links[50001][100], 'the objective item was learned as belonging to quest 100')
Check(db.knowledge.links[50006] and db.knowledge.links[50006][500], 'the quest "use" item was learned as belonging to quest 500')

--[[ 3. turn-in vs abandon ]]--

Step('a turn-in is recorded, an abandoned quest is not')
MOCK.questTitleText = 'Bear Necessities'
MOCK.fire('QUEST_COMPLETE')
table.remove(MOCK.questLog, 2)
MOCK.fire('QUEST_FINISHED')
MOCK.fire('UNIT_QUEST_LOG_CHANGED', 'player')
Settle()
Check(QIH:IsQuestCompleted(100), 'quest 100, removed right after its reward panel, counts as turned in')
expect(50001, 'FLAG', 'inactive', 'its objective item is now flagged')

-- abandon quest 500: it leaves the log with no reward panel
MOCK.questTitleText = nil
for i = #MOCK.questLog, 1, -1 do
    if MOCK.questLog[i].id == 500 then table.remove(MOCK.questLog, i) end
end
MOCK.fire('UNIT_QUEST_LOG_CHANGED', 'player')
Settle()
Check(not QIH:IsQuestCompleted(500), 'the abandoned quest was not recorded as turned in')
expect(50006, 'FLAG', 'inactive', 'the abandoned quest\'s item is flagged by default')

db.onlyCompleted = true
QIH:Invalidate()
Settle()
expect(50006, 'NONE', 'not_confirmed', 'with "only turned-in quests", the abandoned quest\'s item is left alone')
expect(50001, 'FLAG', 'inactive', 'with "only turned-in quests", the turned-in quest\'s item is still flagged')
db.onlyCompleted = false

db.flagUnlinked = true
QIH:Invalidate()
Settle()
expect(50005, 'FLAG', 'unlinked', 'with "flag unlinked", an unlinked quest item is flagged')
db.flagUnlinked = false
QIH:Invalidate()
Settle()

--[[ 4. completed-history robustness ]]--

Step('completed-quest history is only replaced by a real answer')
local saved = _G.GetQuestsCompleted
_G.GetQuestsCompleted = nil
mark = #MOCK.errors
MOCK.fire('QUEST_QUERY_COMPLETE')
_G.GetQuestsCompleted = saved
NoNewErrors(mark, 'QUEST_QUERY_COMPLETE without the API raised no error')
Check(QIH:IsQuestCompleted(300) and QIH:IsQuestCompleted(100), 'the cached history was kept')

--[[ 5. overlays ]]--

local BORDER = [[Interface\Buttons\UI-ActionButton-Border]]
local TICK = [[Interface\Buttons\UI-CheckBox-Check]]

local function overlay(button)
    local border, tick = false, false
    for _, r in ipairs(button.__regions) do
        if r.__texture == BORDER and r:IsShown() then border = true end
    end
    for _, child in ipairs(button.__children or {}) do
        for _, r in ipairs(child.__regions or {}) do
            if r.__texture == TICK and child:IsShown() then tick = true end
        end
    end
    return border, tick
end

Step('Blizzard container buttons')
local container = CreateFrame('Frame', 'ContainerFrame1', UIParent)
container:SetID(BACKPACK_CONTAINER)
container.size = 7
for i = 1, 7 do
    local b = CreateFrame('Button', 'ContainerFrame1Item' .. i, container, 'ContainerFrameItemButtonTemplate')
    b:SetID(i)
    b:SetWidth(37) b:SetHeight(37)
end
mark = #MOCK.errors
ContainerFrame_Update(container)
NoNewErrors(mark, 'ContainerFrame_Update hook raised no errors')
local function slotButton(i) return _G['ContainerFrame1Item' .. i] end
local border, tick = overlay(slotButton(2))
Check(border and not tick, 'flagged slot (Old Letter) has a border and no tick')
border, tick = overlay(slotButton(7))
Check(not border and not tick, 'ordinary item has no overlay')

-- put an active quest back to see a tick
table.insert(MOCK.questLog, 2, {title = 'Bear Necessities II', id = 101, objectives = {{'Bear Pelt: 0/5', 'item'}}})
MOCK.fire('UNIT_QUEST_LOG_CHANGED', 'player')
Settle()
ContainerFrame_Update(container)
border, tick = overlay(slotButton(1))
Check(tick and not border, 'Bear Pelt, needed again by a new quest, shows the tick instead of the border')

db.showQuestTick = false
QIH:Invalidate() Settle()
ContainerFrame_Update(container)
border, tick = overlay(slotButton(1))
Check(not tick, 'turning the tick off removes it')
db.showQuestTick = true

db.enabled = false
QIH:Invalidate() Settle()
ContainerFrame_Update(container)
border = overlay(slotButton(2))
Check(not border, 'disabling the addon clears the border')
db.enabled = true
QIH:Invalidate() Settle()

Step('Bagnon item slots')
local Bagnon = LibStub('AceAddon-3.0'):GetAddon('Bagnon')
mark = #MOCK.errors
MOCK.fire('PLAYER_LOGIN')
Bagnon:ToggleFrame('inventory')
MOCK.update(0.2)
NoNewErrors(mark, 'opening the Bagnon inventory with QuestItemHelper raised no errors')
local inv = Bagnon:GetFrame('inventory')
local flaggedSlot
if inv then
    for _, slot in inv:GetItemFrame():GetAllItemSlots() do
        if slot:GetBag() == BACKPACK_CONTAINER and slot:GetID() == 2 then flaggedSlot = slot end
    end
end
if Check(flaggedSlot ~= nil, 'found the Bagnon slot holding the Old Letter') then
    flaggedSlot:Update()
    Check((overlay(flaggedSlot)), 'the Bagnon slot shows the flag border')
end

--[[ 6. tooltips ]]--

Step('tooltips')
local function tooltipFor(id)
    GameTooltip:SetOwner(UIParent, 'ANCHOR_RIGHT')
    GameTooltip:SetHyperlink(MOCK.itemLink(id))
    local lines = {}
    for i = 1, GameTooltip:NumLines() do lines[#lines + 1] = tostring(GameTooltip:GetLine(i)) end
    return table.concat(lines, ' | ')
end
mark = #MOCK.errors
local text = tooltipFor(50002)
Check(text:find('Quest Item Helper', 1, true) and text:find('Lost Correspondence', 1, true),
    'flagged item tooltip names the quest: ' .. text)
text = tooltipFor(2589)
Check(not text:find('Quest Item Helper', 1, true), 'ordinary item tooltip is untouched')
text = tooltipFor(50001)
Check(text:find('needed for Bear Necessities II', 1, true) ~= nil, 'active item tooltip names the quest that needs it')
NoNewErrors(mark, 'tooltips raised no errors')

--[[ 7. options panel ]]--

Step('options panel')
local panel = _G.QuestItemHelperOptions
Check(panel ~= nil, 'the options panel exists')
mark = #MOCK.errors
QIH:SlashCommand('config')
panel:Show()
NoNewErrors(mark, 'opening the options raised no errors')

-- every control is placed from the panel's top-left corner; check it stays inside 413x428
local overflow = {}
local function checkBox(obj, label)
    local point, rel, relPoint, x, y = obj:GetPoint(1)
    if rel ~= panel or point ~= 'TOPLEFT' or relPoint ~= 'TOPLEFT' then return end
    local w, h = obj:GetWidth() or 0, obj:GetHeight() or 0
    if obj.__kind == 'CheckButton' then
        w = 26 + (obj.__labelText and obj.__labelText:GetStringWidth() or 0)
        h = 26
    elseif obj.__kind == 'FontString' then
        w = math.max(w, obj:GetStringWidth() > (obj:GetWidth() or 0) and (obj:GetWidth() or obj:GetStringWidth()) or 0)
        h = math.max(h, 12)
    end
    if x < 0 or x + w > QIH.PANEL_WIDTH or y > 0 or -y + h > QIH.PANEL_HEIGHT then
        overflow[#overflow + 1] = label .. ' at ' .. x .. ',' .. y .. ' size ' .. w .. 'x' .. h
    end
end
local placed = 0
for _, child in ipairs(panel.__children) do checkBox(child, child:GetName() or child.__kind) placed = placed + 1 end
for _, region in ipairs(panel.__regions) do checkBox(region, region.__kind) placed = placed + 1 end
Check(placed > 10, 'the panel placed its controls (' .. placed .. ')')
Check(#overflow == 0, 'every control fits the 413x428 options area' .. (#overflow > 0 and (': ' .. table.concat(overflow, '; ')) or ''))
Check(panel.layoutBottom <= QIH.PANEL_HEIGHT, 'the layout ends at ' .. tostring(panel.layoutBottom) .. 'px')

local function checkFor(key)
    for _, child in ipairs(panel.__children) do
        if child.option and child.option.key == key then return child end
    end
end
local highlight, icon = checkFor('highlightEnabled'), checkFor('showIcon')
Check(highlight and icon and icon:IsEnabled(), 'the icon option starts enabled')
highlight:SetChecked(false)
highlight:Click()
Check(db.highlightEnabled == false, 'unticking "Highlight" saved the setting')
Check(not icon:IsEnabled(), 'the dependent icon option is now disabled')
icon:Fire('OnEnter')
local tipLines = {}
for i = 1, GameTooltip:NumLines() do tipLines[#tipLines + 1] = tostring(GameTooltip:GetLine(i)) end
Check(table.concat(tipLines, ' | '):find('Highlight old quest items', 1, true) ~= nil,
    'hovering it says why it is disabled: ' .. table.concat(tipLines, ' | '))
icon:Fire('OnLeave')
Check(_G[icon:GetName() .. 'Text']:GetFontObject() == 'GameFontDisable', 'its label uses the disabled font')

-- the panel copies a few of Bagnon's design tokens instead of depending on Bagnon; make sure the
-- copies have not drifted from Bagnon/utility/style.lua
local Style = LibStub('AceAddon-3.0'):GetAddon('Bagnon').Style
local function same(a, b)
    for i = 1, 4 do if math.abs((a[i] or 1) - (b[i] or 1)) > 0.001 then return false end end
    return true
end
local swatch
for _, child in ipairs(panel.__children) do if child.key == 'highlightColor' then swatch = child end end
Check(swatch and same({swatch:GetBackdropBorderColor()}, Style.colors.buttonBorder), 'swatch border matches Bagnon.Style.colors.buttonBorder')
Check(swatch and swatch:GetBackdrop().edgeSize == Style.flatBackdrop.edgeSize and swatch:GetBackdrop().bgFile == Style.flatBackdrop.bgFile,
    'swatch chrome matches Bagnon.Style.flatBackdrop')
local ruleOk = false
for _, region in ipairs(panel.__regions) do
    if region.__kind == 'Texture' and type(region.__texture) == 'number' then
        ruleOk = same(region.__textureArgs, Style.colors.divider) or ruleOk
    end
end
Check(ruleOk, 'section rules use Bagnon.Style.colors.divider')
highlight:SetChecked(true)
highlight:Click()
Check(icon:IsEnabled() and db.highlightEnabled == true, 'ticking "Highlight" re-enables it')

local master = checkFor('enabled')
master:SetChecked(false)
master:Click()
Check(not checkFor('tooltipEnabled'):IsEnabled(), 'turning the addon off disables the other options')
Check(not checkFor('debug'):IsEnabled() == false, 'the debug option stays usable while the addon is off')
master:SetChecked(true)
master:Click()

mark = #MOCK.errors
panel.scanButton:Click()
NoNewErrors(mark, 'the Rescan button raised no errors')

-- Defaults: settings are restored, learned links are kept
panel.default()
Check(db.showIcon == true and db.highlightColor.r == 1, 'Defaults restored the settings')
Check(db.knowledge.links[50002] ~= nil, 'Defaults kept the learned item/quest links')

--[[ 8. slash commands ]]--

Step('slash commands')
mark = #MOCK.errors
for _, cmd in ipairs({'', 'scan', 'list', 'debug', 'debug', 'help', 'reset', 'forget'}) do
    QIH:SlashCommand(cmd)
end
NoNewErrors(mark, 'every slash command ran without errors')
Check(next(db.knowledge.links) == nil, '/qih forget cleared the learned links')

--[[ 9. work budgets (see qihbench.lua for the full comparison against the original) ]]--

Step('work budgets')
local fullScans, refreshes = 0, 0
local realScan, realRefresh = QIH.ScanBags, QIH.RefreshButtons
QIH.ScanBags = function(self, all) if all then fullScans = fullScans + 1 end return realScan(self, all) end
QIH.RefreshButtons = function(self, ...) refreshes = refreshes + 1 return realRefresh(self, ...) end
local function loot(times)
    for _ = 1, times do
        MOCK.fire('BAG_UPDATE', BACKPACK_CONTAINER)
        for _ = 1, 2 do MOCK.clock = MOCK.clock + 1 MOCK.update(0.1) end
    end
    Settle() Settle() Settle()
end

-- an item the client never caches must not turn every bag change into a full rescan
MOCK.uncached[50005] = true
QIH:FullRescan()
fullScans = 0
loot(30)
Check(fullScans <= 6, 'a never-cached item costs a bounded number of full rescans while looting (got ' .. fullScans .. ', budget 6)')

-- ...and must not use up the retries of an item that arrives later
questItem(50007, 'Late Parcel')
MOCK.uncached[50007] = true
MOCK.put(BACKPACK_CONTAINER, 8, 50007)
MOCK.fire('BAG_UPDATE', BACKPACK_CONTAINER)
Settle()
Check(QIH:GetVerdict(50007).state == 'PENDING', 'the late item is pending while uncached')
MOCK.uncached[50007] = nil
Settle() Settle()
Check(QIH:GetVerdict(50007).state ~= 'PENDING', 'once cached, the late item is judged by a retry despite the stuck item ('
    .. QIH:GetVerdict(50007).state .. ')')
MOCK.uncached[50005] = nil

-- switched off: bag changes cost nothing
db.enabled = false
QIH:Invalidate() Settle()
refreshes, fullScans = 0, 0
loot(10)
Check(refreshes == 0 and fullScans == 0, 'while disabled, 10 bag changes cause no redraw or scan (redraws ' .. refreshes .. ', scans ' .. fullScans .. ')')
db.enabled = true
QIH:Invalidate() Settle()
Check(refreshes == 1, 'switching back on redraws the buttons once (got ' .. refreshes .. ')')
QIH.ScanBags, QIH.RefreshButtons = realScan, realRefresh

Step('result')
say('  checks run: ' .. checks)
say('  failures:   ' .. failures)
say('  mock errors collected: ' .. #MOCK.errors)
for _, e in ipairs(MOCK.errors) do say('    ' .. e) end
return failures + #MOCK.errors
