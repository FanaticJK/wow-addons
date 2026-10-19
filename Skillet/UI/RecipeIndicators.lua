--[[ Skillet: A tradeskill window replacement.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

]]--

--[[
	Recipe list indicators, shared by every trade shown in the Skillet window:

	  * a small square left of the recipe name in the crafted item's quality colour. It comes
	    from GetItemInfo(itemID), never from the recipe difficulty, so it does not change with
	    the player's skill rank.
	  * a quest marker ("<icon> have/need") on recipes whose crafted item is the target of an
	    item objective in the quest log.

	3.3.5 does not expose the item ID of a quest objective, only its text ("Linen Cloth: 2/5"),
	so objectives are keyed by item name and matched against the client-localized name of the
	recipe's itemID. The quest log is only read when it changed (UNIT_QUEST_LOG_CHANGED) or the
	window opens, and only once the window draws; held counts come from GetItemCount at draw time,
	so the existing BAG_UPDATE redraw keeps them current.
]]--

local AceEvent = AceLibrary("AceEvent-2.0")

local GetItemInfo = GetItemInfo
local GetItemCount = GetItemCount
local GetItemQualityColor = GetItemQualityColor
local GetNumQuestLogEntries = GetNumQuestLogEntries
local GetQuestLogTitle = GetQuestLogTitle
local GetNumQuestLeaderBoards = GetNumQuestLeaderBoards
local GetQuestLogLeaderBoard = GetQuestLogLeaderBoard
local GetQuestLogSelection = GetQuestLogSelection
local SelectQuestLogEntry = SelectQuestLogEntry
local ExpandQuestHeader = ExpandQuestHeader
local CollapseQuestHeader = CollapseQuestHeader
local tonumber, pairs, wipe = tonumber, pairs, wipe

local RARITY_SIZE = 8				-- inner colour square
local RARITY_GUTTER = 12			-- room the square takes in front of the name
local QUEST_ICON = "|TInterface\\GossipFrame\\ActiveQuestIcon:0|t"
local QUEST_COLOR = "|cffffd200"
local QUEST_DONE_COLOR = "|cff40c040"
local FULLWIDTH_COLON = "\239\188\154"	-- U+FF1A, used by the zhCN/zhTW/koKR objective texts

-- itemID -> { name = <string>, quality = <number> }, only for items whose info was available
local itemCache = {}
-- itemIDs already asked from the server this session (see RequestItem)
local requested = {}

-- item name -> { need = <sum of required counts>, quests = { { title, need }, ... } }
local questItems = {}
local questsDirty = true
local readingLog = false

--[[ item info ]]--

local function RefreshVisibleWindow()
	if Skillet.tradeSkillFrame and Skillet.tradeSkillFrame:IsVisible() then
		Skillet:UpdateTradeSkillWindow()
	end
end

local queryTip
local function RequestItem(itemID)
	if requested[itemID] then return end
	requested[itemID] = true

	-- 3.3.5 has no GET_ITEM_INFO_RECEIVED; setting a hyperlink on a hidden tooltip makes the client
	-- fetch the item, and one delayed redraw picks it up. Each item is asked for once per session.
	if not queryTip then
		queryTip = CreateFrame("GameTooltip", "SkilletItemQueryTooltip", nil, "GameTooltipTemplate")
	end
	queryTip:SetOwner(UIParent, "ANCHOR_NONE")
	queryTip:SetHyperlink("item:" .. itemID)
	queryTip:Hide()

	if not AceEvent:IsEventScheduled("Skillet_ItemInfo_Refresh") then
		AceEvent:ScheduleEvent("Skillet_ItemInfo_Refresh", RefreshVisibleWindow, 1)
	end
end

-- name, quality of a crafted item, or nil while the client has not cached it yet
local function GetCraftedItem(itemID)
	local info = itemCache[itemID]
	if info then
		return info.name, info.quality
	end

	local name, _, quality = GetItemInfo(itemID)
	if name and quality then
		itemCache[itemID] = { name = name, quality = quality }
		return name, quality
	end

	RequestItem(itemID)
end

local function QualityColor(quality)
	local c = ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality]
	if c then
		return c.r, c.g, c.b
	end
	local r, g, b = GetItemQualityColor(quality)
	if r then
		return r, g, b
	end
	return 0.5, 0.5, 0.5
end

--[[ quest log ]]--

-- "Linen Cloth: 2/5" -> "Linen Cloth", 2, 5. nil for objectives without a count.
local function ParseObjective(text)
	local head, have, need = text:match("^(.-)%s*(%d+)%s*/%s*(%d+)%s*$")
	if not head then return end

	if head:sub(-#FULLWIDTH_COLON) == FULLWIDTH_COLON then
		head = head:sub(1, -#FULLWIDTH_COLON - 1)
	end
	head = head:gsub("[%s:]+$", "")

	if head == "" then return end
	return head, tonumber(have), tonumber(need)
end

local function RecordQuest(index, title)
	for j = 1, GetNumQuestLeaderBoards(index) or 0 do
		local text, kind = GetQuestLogLeaderBoard(j, index)
		if kind == "item" and text then
			local name, _, need = ParseObjective(text)
			if name and need and need > 0 then
				local entry = questItems[name]
				if not entry then
					entry = { need = 0, quests = {} }
					questItems[name] = entry
				end
				entry.need = entry.need + need
				entry.quests[#entry.quests + 1] = { title = title, need = need }
			end
		end
	end
end

-- Reads every quest, including those under collapsed headers: 3.3.5 only lists visible rows, so
-- collapsed headers are expanded for the read and collapsed again afterwards.
local function ScanQuestLog()
	if readingLog then return end
	readingLog = true

	wipe(questItems)

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
		ExpandQuestHeader(0)		-- 0 = every header
		numEntries = GetNumQuestLogEntries() or 0
	end

	for i = 1, numEntries do
		local title, _, _, _, isHeader = GetQuestLogTitle(i)
		if title and not isHeader then
			RecordQuest(i, title)
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

	questsDirty = false
	readingLog = false
end

-- The quest log changed (accept, abandon, turn-in, objective progress). Header expand/collapse
-- only sends QUEST_LOG_UPDATE, which is deliberately not watched: listening to it would make
-- this scan and any other addon that expands headers wake each other up forever.
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("UNIT_QUEST_LOG_CHANGED")
eventFrame:SetScript("OnEvent", function(self, event, unit)
	if unit ~= "player" then return end
	questsDirty = true

	if Skillet.tradeSkillFrame and Skillet.tradeSkillFrame:IsVisible()
	   and not AceEvent:IsEventScheduled("Skillet_QuestItems_Refresh") then
		AceEvent:ScheduleEvent("Skillet_QuestItems_Refresh", RefreshVisibleWindow, 0.5)
	end
end)

-- called when the window opens, so it never shows quest state from before it was closed
function Skillet:InvalidateQuestItems()
	questsDirty = true
end

-- quest entry for a crafted item: { need, quests }, or nil
local function GetQuestEntry(itemName, recipeName)
	if questsDirty then
		ScanQuestLog()
	end
	return (itemName and questItems[itemName]) or (not itemName and recipeName and questItems[recipeName]) or nil
end

--[[ recipe buttons ]]--

local function GetRarityTextures(button)
	local square = button.skilletRarity
	if not square then
		-- created once per recycled button; a dark frame keeps grey/white readable on any row
		local border = button:CreateTexture(nil, "OVERLAY")
		border:SetWidth(RARITY_SIZE + 2)
		border:SetHeight(RARITY_SIZE + 2)
		border:SetTexture(0, 0, 0, 0.9)

		square = button:CreateTexture(nil, "OVERLAY")
		square:SetWidth(RARITY_SIZE)
		square:SetHeight(RARITY_SIZE)
		square:SetPoint("CENTER", border, "CENTER")

		button.skilletRarity = square
		button.skilletRarityBorder = border
	end
	return square, button.skilletRarityBorder
end

-- width the level column needs to leave room for the square
function Skillet:GetRecipeIndicatorGutter()
	if self.db.profile.show_item_quality then
		return RARITY_GUTTER
	end
	return 0
end

-- hide the square on rows that are not recipes (headers)
function Skillet:HideRecipeIndicators(button)
	if button.skilletRarity then
		button.skilletRarity:Hide()
		button.skilletRarityBorder:Hide()
	end
end

-- Draws the quality square for one recipe row and returns the quest prefix for its name ("" when
-- the recipe is not wanted by a quest). levelText is the row's level column, the square sits at
-- its right edge, just in front of the name.
function Skillet:UpdateRecipeIndicators(button, levelText, recipe, skill)
	local itemID = recipe and recipe.itemID
	if not itemID or itemID == 0 then
		-- enchants and other recipes without a crafted item
		self:HideRecipeIndicators(button)
		return ""
	end

	local itemName, quality = GetCraftedItem(itemID)

	if self.db.profile.show_item_quality then
		local square, border = GetRarityTextures(button)
		border:ClearAllPoints()
		border:SetPoint("RIGHT", levelText, "RIGHT", -1, 0)

		if quality then
			square:SetTexture(QualityColor(quality))
		else
			square:SetTexture(0.2, 0.2, 0.2, 1)		-- not cached yet, redrawn once it is
		end
		border:Show()
		square:Show()
	else
		self:HideRecipeIndicators(button)
	end

	if not self.db.profile.show_quest_items then
		return ""
	end

	-- the item name when known; the recipe name only while the item is still uncached
	local entry = GetQuestEntry(itemName, skill and skill.name)
	if not entry then
		return ""
	end

	local have = GetItemCount(itemID) or 0
	local color = have >= entry.need and QUEST_DONE_COLOR or QUEST_COLOR
	return QUEST_ICON .. color .. have .. "/" .. entry.need .. "|r "
end

-- tooltip lines for a recipe, one per quest that wants its item
function Skillet:AddRecipeQuestTooltip(tooltip, recipe, skill)
	if not self.db.profile.show_quest_items or not recipe or not recipe.itemID or recipe.itemID == 0 then
		return
	end

	local itemName = GetCraftedItem(recipe.itemID)
	local entry = GetQuestEntry(itemName, skill and skill.name)
	if not entry then return end

	local have = GetItemCount(recipe.itemID) or 0
	tooltip:AddLine(" ")
	for i = 1, #entry.quests do
		local q = entry.quests[i]
		local need = q.need
		local r, g, b = 1, 0.82, 0
		if have >= need then
			r, g, b = 0.25, 0.75, 0.25
		end
		tooltip:AddDoubleLine(QUEST_ICON .. " " .. q.title, math.min(have, need) .. "/" .. need, r, g, b, r, g, b)
	end
end
