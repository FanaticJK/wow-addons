--[[
	Core.lua
		Settings, quest log reading, the item -> quest knowledge base, item verdicts and events.

	How an item is judged (see QIH:Evaluate):
		1. Quest starter ("This Item Begins a Quest"): the client names the quest it starts.
		   In the log -> active. Already turned in (server history) -> flag. Otherwise it can
		   still start its quest -> leave it alone.
		2. Not a quest item (no "Quest Item" binding, not of class Quest) -> never flagged.
		3. Quest item: associated quests are the ones learned while they were in the log
		   (objective names, quest "use" items) plus whatever the current log mentions.
		   Any associated quest active -> not flagged. All of them gone -> flagged.
		   No association known at all -> unknown, not flagged unless the player opts in.
--]]

local addonName, QIH = ...

local _G = _G
local pairs, ipairs, type, wipe = pairs, ipairs, type, wipe
local tostring, format, tconcat = tostring, string.format, table.concat
local GetTime = GetTime
local GetNumQuestLogEntries = GetNumQuestLogEntries
local GetNumQuestLeaderBoards = GetNumQuestLeaderBoards
local GetQuestLogLeaderBoard = GetQuestLogLeaderBoard
local GetQuestLogTitle = GetQuestLogTitle
local GetQuestLogSelection = GetQuestLogSelection
local SelectQuestLogEntry = SelectQuestLogEntry
local ExpandQuestHeader = ExpandQuestHeader
local CollapseQuestHeader = CollapseQuestHeader

QIH.defaults = {
	enabled = true,
	highlightEnabled = true,
	tooltipEnabled = true,
	showIcon = true,
	-- small tick on quest items a quest in the log still needs
	showQuestTick = true,
	highlightColor = { r = 1, g = 0.5, b = 0 },
	-- "only flag when the quest is completely inactive": require the server to confirm the quest
	-- was turned in, so items of abandoned (re-acceptable) quests stay unflagged
	onlyCompleted = false,
	-- quest-bound items no known quest uses; there is no proof which quest they belong to
	flagUnlinked = false,
	debug = false,
}

-- Verdict states
local FLAG, ACTIVE, NONE, PENDING = 'FLAG', 'ACTIVE', 'NONE', 'PENDING'
QIH.FLAG, QIH.ACTIVE, QIH.NONE, QIH.PENDING = FLAG, ACTIVE, NONE, PENDING

local PENDING_VERDICT = { state = PENDING, reason = 'pending' }

--[[ state ]]--

local db, knowledge, completed

local questLogReady = false     -- false until the client has delivered the quest log once
local activeQuests = {}         -- questID -> title, for every quest in the log
local activeTitles = {}         -- title -> true, covers quests whose ID could not be read
local itemObjectives = {}       -- { text = 'Bear Pelt: 3/10', questID = 123 or false }, item-type objectives
local specialItems = {}         -- itemID -> questID, the quest log "use item" buttons
local questSignature = ''       -- detects real quest log changes among the many QUEST_LOG_UPDATEs

local itemData = {}             -- itemID -> { name, isQuest, starter }  (static item facts)
local verdicts = {}             -- itemID -> verdict; wiped whenever quest state or settings change
local slotItems = {}            -- bag -> { slot -> itemID }, the last scan
local dirtyBags = {}            -- bag -> true, BAG_UPDATE since the last scan

local pendingTurnIn             -- title on the reward panel, see QUEST_COMPLETE
local pendingTurnInExpires = 0
local retries = 0

QIH.activeQuests = activeQuests
QIH.slotItems = slotItems

--[[ output ]]--

function QIH:Print(msg)
	local frame = _G.DEFAULT_CHAT_FRAME
	if frame then
		frame:AddMessage('|cffff8000Quest Item Helper|r: ' .. tostring(msg))
	end
end

function QIH:Debug(msg)
	if db and db.debug then
		self:Print('|cff999999' .. tostring(msg) .. '|r')
	end
end

--[[ saved variables ]]--

local function ApplyDefaults(target, defaults)
	for key, value in pairs(defaults) do
		if type(value) == 'table' then
			if type(target[key]) ~= 'table' then
				target[key] = {}
			end
			ApplyDefaults(target[key], value)
		elseif type(target[key]) ~= type(value) then
			target[key] = value
		end
	end
end

local function InitSavedVariables()
	if type(_G.QuestItemHelperDB) ~= 'table' then
		_G.QuestItemHelperDB = {}
	end
	db = _G.QuestItemHelperDB
	ApplyDefaults(db, QIH.defaults)

	-- learned item -> quest associations, shared by all characters (they are game facts)
	if type(db.knowledge) ~= 'table' then
		db.knowledge = {}
	end
	knowledge = db.knowledge
	for _, key in ipairs({ 'links', 'titles', 'daily' }) do
		if type(knowledge[key]) ~= 'table' then
			knowledge[key] = {}
		end
	end

	-- completed quests are per character; cached so they are known before the server answers
	if type(_G.QuestItemHelperCharDB) ~= 'table' then
		_G.QuestItemHelperCharDB = {}
	end
	local charDB = _G.QuestItemHelperCharDB
	if type(charDB.completed) ~= 'table' then
		charDB.completed = {}
	end
	completed = charDB.completed

	QIH.db, QIH.knowledge, QIH.completed = db, knowledge, completed
end

function QIH:ResetSettings()
	local kept = db.knowledge
	wipe(db)
	db.knowledge = kept
	ApplyDefaults(db, self.defaults)
	self:Invalidate()
end

function QIH:ForgetKnowledge()
	wipe(knowledge.links)
	wipe(knowledge.titles)
	wipe(knowledge.daily)
	self:Invalidate()
end

--[[ scheduling: a hidden frame whose OnUpdate only runs while a refresh is pending ]]--

local timer = CreateFrame('Frame')
timer:Hide()
local timerDue = 0
local questsDirty, fullScan = false, false

timer:SetScript('OnUpdate', function(self)
	if GetTime() >= timerDue then
		self:Hide()
		QIH:Run()
	end
end)

-- trailing debounce: bursts of BAG_UPDATE / QUEST_LOG_UPDATE collapse into one run
function QIH:Schedule(delay)
	timerDue = GetTime() + (delay or 0.2)
	timer:Show()
end

-- quest state or settings changed: every verdict and every visible flag must be recomputed
function QIH:Invalidate()
	wipe(verdicts)
	fullScan = true
	self:Schedule(0.05)
end

--[[ quest log ]]--

local readingLog = false
local ignoreLogEventsUntil = 0  -- our own header expand/collapse fires QUEST_LOG_UPDATE too
local sawQuestLogUpdate = false
local newActive, newTitles = {}, {}

local function RecordQuest(index, title, isDaily, questID)
	newTitles[title] = true
	if questID then
		newActive[questID] = title
		knowledge.titles[questID] = title
		if isDaily then
			knowledge.daily[questID] = true
		end
	end

	-- objectives of type "item": the text is "<item name>: x/y" in most locales
	for j = 1, GetNumQuestLeaderBoards(index) or 0 do
		local text, kind = GetQuestLogLeaderBoard(j, index)
		if kind == 'item' and text and text ~= '' then
			itemObjectives[#itemObjectives + 1] = { text = text, questID = questID or false }
		end
	end

	local specialID = QIH.GetQuestSpecialItemID(index)
	if specialID and questID then
		specialItems[specialID] = questID
	end
end

-- Reads every quest, including those hidden under collapsed headers. 3.3.5 only exposes rows that
-- are visible in the log, so collapsed headers are expanded for the read and collapsed again after.
local function ReadQuestLog()
	if readingLog then
		return false
	end
	readingLog = true

	local numEntries = GetNumQuestLogEntries() or 0
	local collapsed
	for i = 1, numEntries do
		local title, _, _, _, isHeader, isCollapsed = GetQuestLogTitle(i)
		if isHeader and isCollapsed and title then
			collapsed = collapsed or {}
			collapsed[title] = true
		end
	end

	local selection = GetQuestLogSelection()
	if collapsed then
		ExpandQuestHeader(0)  -- 0 = all headers
		numEntries = GetNumQuestLogEntries() or 0
	end

	wipe(newActive)
	wipe(newTitles)
	wipe(itemObjectives)
	wipe(specialItems)

	for i = 1, numEntries do
		local title, isHeader, _, isDaily, questID = QIH.GetQuestLogEntry(i)
		if title and not isHeader then
			RecordQuest(i, title, isDaily, questID)
		end
	end

	if collapsed then
		-- backwards, so collapsing a header never shifts the rows still to be visited
		for i = numEntries, 1, -1 do
			local title, _, _, _, isHeader = GetQuestLogTitle(i)
			if isHeader and title and collapsed[title] then
				CollapseQuestHeader(i)
			end
		end
	end
	if selection and selection > 0 then
		SelectQuestLogEntry(selection)
	end

	if collapsed then
		ignoreLogEventsUntil = GetTime() + 1
	end
	readingLog = false
	return true
end

local function BuildSignature()
	local parts = {}
	for questID in pairs(newActive) do
		parts[#parts + 1] = questID
	end
	table.sort(parts)
	local titles = {}
	for title in pairs(newTitles) do
		titles[#titles + 1] = title
	end
	table.sort(titles)
	return tconcat(parts, ',') .. '|' .. tconcat(titles, '\031') .. '|' .. #itemObjectives
end

-- returns true when the set of quests in the log changed
local function UpdateQuests()
	-- at login the log can read as empty before the client has it; wait for its first update
	if not questLogReady and not sawQuestLogUpdate and (GetNumQuestLogEntries() or 0) == 0 then
		return false
	end
	if not ReadQuestLog() then
		return false
	end

	local signature = BuildSignature()
	if signature == questSignature and questLogReady then
		return false
	end

	-- a quest that left the log right after its reward panel closed was turned in
	local now = GetTime()
	for questID, title in pairs(activeQuests) do
		if not newActive[questID] then
			if pendingTurnIn == title and now <= pendingTurnInExpires then
				completed[questID] = true
				QIH:Debug(format('Quest turned in: %s (%d)', title, questID))
			else
				QIH:Debug(format('Quest left the log: %s (%d)', title, questID))
			end
		end
	end

	wipe(activeQuests)
	for questID, title in pairs(newActive) do
		activeQuests[questID] = title
	end
	wipe(activeTitles)
	for title in pairs(newTitles) do
		activeTitles[title] = true
	end

	questSignature = signature
	questLogReady = true
	return true
end

function QIH:IsReady()
	return questLogReady
end

function QIH:IsQuestActive(questID)
	return activeQuests[questID] ~= nil
end

function QIH:IsQuestCompleted(questID)
	return completed[questID] == true
end

function QIH:GetQuestTitle(questID)
	return activeQuests[questID] or knowledge.titles[questID]
end

function QIH:IsQuestDaily(questID)
	return knowledge.daily[questID] == true
end

--[[ items ]]--

-- static facts about an item. Starter info needs a bag slot, so it is filled in the first time
-- the item is seen in one. Returns nil while the item is not in the client cache.
local function GetItemData(itemID, bag, slot)
	local data = itemData[itemID]
	if data and (data.starterKnown or not bag) then
		return data
	end

	local name, isQuestClass = QIH.GetItemBasics(itemID)
	if not name then
		return nil
	end

	data = data or {}
	data.name = name
	data.isQuest = isQuestClass
	if bag and slot then
		local isQuestItem, starter = QIH.GetBagItemQuestInfo(bag, slot)
		data.isQuest = data.isQuest or isQuestItem or (starter ~= nil)
		data.starter = starter
		data.starterKnown = true
	end
	itemData[itemID] = data
	return data
end

local function Learn(itemID, questID)
	if not questID then
		return
	end
	local links = knowledge.links[itemID]
	if not links then
		links = {}
		knowledge.links[itemID] = links
	end
	if not links[questID] then
		links[questID] = true
		QIH:Debug(format('Learned: item %d belongs to quest %d', itemID, questID))
	end
end

-- Does any item objective in the log name this item? Learns the quest when the objective text
-- starts with the item name (the "<name>: x/y" form); a looser substring hit only protects the item.
local function MatchObjectives(itemID, name)
	local hit = false
	local len = #name
	for _, objective in ipairs(itemObjectives) do
		local text = objective.text
		if text:find(name, 1, true) then
			hit = true
			if objective.questID and text:sub(1, len) == name then
				Learn(itemID, objective.questID)
			end
		end
	end
	return hit
end

local function Verdict(state, reason, quests)
	return { state = state, reason = reason, quests = quests }
end

-- the core decision, see the header of this file
function QIH:Evaluate(itemID, data)
	local starter = data.starter
	if starter then
		if activeQuests[starter] then
			return Verdict(ACTIVE, 'starter_active', { starter })
		elseif completed[starter] and not knowledge.daily[starter] then
			return Verdict(FLAG, 'starter_done', { starter })
		end
		return Verdict(NONE, 'starter_available', { starter })
	end

	if not data.isQuest then
		return Verdict(NONE, 'not_quest_item')
	end

	-- current quest log first, learning associations as a side effect
	local special = specialItems[itemID]
	if special then
		Learn(itemID, special)
	end
	local inObjectives = MatchObjectives(itemID, data.name)

	local links = knowledge.links[itemID]
	local quests
	if links then
		quests = {}
		for questID in pairs(links) do
			quests[#quests + 1] = questID
		end
		table.sort(quests)
		for _, questID in ipairs(quests) do
			if activeQuests[questID] then
				return Verdict(ACTIVE, 'quest_active', quests)
			end
		end
	end
	if special or inObjectives then
		return Verdict(ACTIVE, 'quest_active', quests)
	end

	if not quests then
		if db.flagUnlinked then
			return Verdict(FLAG, 'unlinked')
		end
		return Verdict(NONE, 'unknown')
	end

	-- every associated quest is out of the log
	for _, questID in ipairs(quests) do
		if knowledge.daily[questID] then
			-- repeatable: the item may be needed again tomorrow
			return Verdict(NONE, 'daily', quests)
		end
		if db.onlyCompleted and not completed[questID] then
			return Verdict(NONE, 'not_confirmed', quests)
		end
	end
	return Verdict(FLAG, 'inactive', quests)
end

local function DebugVerdict(bag, slot, itemID, data, verdict)
	if not (db.debug and data and (data.isQuest or data.starter)) then
		return
	end
	QIH:Debug(format('Scanning bag %s slot %s', tostring(bag), tostring(slot)))
	QIH:Debug(format('  Item: %s (ID %d)', data.name or '?', itemID))
	if verdict.quests then
		for _, questID in ipairs(verdict.quests) do
			QIH:Debug(format('  Quest association: %d %s | in log: %s | turned in: %s', questID,
				QIH:GetQuestTitle(questID) or '?', activeQuests[questID] and 'YES' or 'NO',
				completed[questID] and 'YES' or 'NO'))
		end
	else
		QIH:Debug('  Quest association: none known')
	end
	QIH:Debug(format('  Result: %s (%s)', verdict.state == FLAG and 'FLAG ITEM' or verdict.state, verdict.reason))
end

-- Verdict for an item. bag/slot are optional (tooltips pass none); without them only items
-- already seen in the bags can be judged. Never errors: anything missing yields PENDING.
function QIH:GetVerdict(itemID, bag, slot)
	if not (itemID and db and db.enabled and questLogReady) then
		return PENDING_VERDICT
	end
	local verdict = verdicts[itemID]
	if verdict then
		return verdict
	end
	local data = GetItemData(itemID, bag, slot)
	if not (data and data.starterKnown) then
		if bag then
			retries = retries + 1  -- item not cached yet; Run() retries a few times
		end
		return PENDING_VERDICT
	end
	verdict = self:Evaluate(itemID, data)
	verdicts[itemID] = verdict
	DebugVerdict(bag, slot, itemID, data, verdict)
	return verdict
end

--[[ bag scan ]]--

local function ScanBag(bag)
	local slots = slotItems[bag]
	if not slots then
		slots = {}
		slotItems[bag] = slots
	else
		wipe(slots)
	end
	for slot = 1, QIH.GetBagNumSlots(bag) do
		local itemID = QIH.GetBagItemID(bag, slot)
		if itemID then
			slots[slot] = itemID
			QIH:GetVerdict(itemID, bag, slot)
		end
	end
end

function QIH:ScanBags(all)
	for _, bag in ipairs(self.BAGS) do
		if all or dirtyBags[bag] or not slotItems[bag] then
			ScanBag(bag)
		end
	end
	wipe(dirtyBags)
end

-- slots currently flagged: calls fn(bag, slot, itemID, verdict)
function QIH:ForEachFlagged(fn)
	for _, bag in ipairs(self.BAGS) do
		local slots = slotItems[bag]
		if slots then
			for slot, itemID in pairs(slots) do
				local verdict = verdicts[itemID]
				if verdict and verdict.state == FLAG then
					fn(bag, slot, itemID, verdict)
				end
			end
		end
	end
end

--[[ the refresh pipeline ]]--

function QIH:Run()
	if not db then
		return
	end
	if questsDirty then
		questsDirty = false
		if UpdateQuests() then
			wipe(verdicts)
			fullScan = true
		end
	end
	if not (db.enabled and questLogReady) then
		self:RefreshButtons()
		return
	end

	retries = 0
	local all = fullScan
	fullScan = false
	self:ScanBags(all)
	if all then
		self:RefreshButtons()
	end

	-- some item was not in the client cache yet: try again shortly, a bounded number of times
	if retries > 0 then
		self.retryRounds = (self.retryRounds or 0) + 1
		if self.retryRounds <= 5 then
			fullScan = true
			self:Schedule(1)
		end
	else
		self.retryRounds = 0
	end
end

-- /qih scan: forget all cached verdicts and scan everything now
function QIH:FullRescan()
	wipe(verdicts)
	wipe(itemData)
	questsDirty = true
	fullScan = true
	self.retryRounds = 0
	self:Run()
	local count = 0
	self:ForEachFlagged(function() count = count + 1 end)
	return count
end

--[[ events ]]--

local events = CreateFrame('Frame')
local handlers = {}

function handlers.ADDON_LOADED(name)
	if name == addonName then
		InitSavedVariables()
		if QIH.OnInitialize then
			QIH:OnInitialize()
		end
	end
	if QIH.OnAddonLoaded then
		QIH:OnAddonLoaded(name)
	end
end

function handlers.PLAYER_LOGIN()
	QIH.RequestCompletedQuests()
	if QIH.OnLogin then
		QIH:OnLogin()
	end
end

function handlers.PLAYER_ENTERING_WORLD()
	questsDirty = true
	fullScan = true
	QIH:Schedule(1)
end

local function QuestsChanged()
	questsDirty = true
	QIH:Schedule(0.5)
end

function handlers.QUEST_LOG_UPDATE()
	sawQuestLogUpdate = true
	if readingLog or GetTime() < ignoreLogEventsUntil then
		return  -- echo of our own header expand/collapse; real changes also send UNIT_QUEST_LOG_CHANGED
	end
	QuestsChanged()
end

function handlers.UNIT_QUEST_LOG_CHANGED(unit)
	if unit == 'player' then
		QuestsChanged()
	end
end

-- the reward panel is up; remember which quest so its removal from the log counts as a turn-in
function handlers.QUEST_COMPLETE()
	pendingTurnIn = QIH.GetCompletingQuestTitle()
	pendingTurnInExpires = GetTime() + 600
end

-- the quest frame closed: a turn-in removes the quest within a moment, a cancel never does
function handlers.QUEST_FINISHED()
	if pendingTurnIn then
		pendingTurnInExpires = GetTime() + 5
	end
end

function handlers.QUEST_QUERY_COMPLETE()
	wipe(completed)
	QIH.ReadCompletedQuests(completed)
	QIH:Debug('Completed quest history received from the server')
	QIH:Invalidate()
end

function handlers.BAG_UPDATE(bag)
	if bag then
		dirtyBags[bag] = true
	end
	QIH:Schedule(0.2)
end

events:SetScript('OnEvent', function(_, event, ...)
	handlers[event](...)
end)
for event in pairs(handlers) do
	events:RegisterEvent(event)
end
