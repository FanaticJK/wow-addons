--[[
	Compat.lua
		Thin wrappers around the 3.3.5a (WotLK, build 12340) client API.

		Every client call the rest of the addon needs about bags, items and the quest log goes
		through here, so a future port (Classic Wrath, C_Container, ...) only has to touch this file.
--]]

local addonName, QIH = ...

-- The one public global: lets other bag addons call QuestItemHelper:UpdateButton(button, bag, slot)
QuestItemHelper = QIH
QIH.name = addonName

local _G = _G
local select, tonumber, type = select, tonumber, type
local GetContainerNumSlots = GetContainerNumSlots
local GetContainerItemID = GetContainerItemID
local GetContainerItemLink = GetContainerItemLink
local GetItemInfo = GetItemInfo
local GetQuestLogTitle = GetQuestLogTitle
local GetQuestLink = GetQuestLink

-- 3.3.0+: returns isQuestItem, questID (the quest this item STARTS), isActive (that quest is in
-- the log). It does NOT say which quest an objective item belongs to; nothing in the 3.3.5 API does.
local GetContainerItemQuestInfo = _G.GetContainerItemQuestInfo

-- Localized name of the "Quest" item class. GetAuctionItemClasses() lists the 12 classes in a
-- fixed order on 3.3.5 and "Quest" is the 12th (Bagnon relies on the same position).
local QUEST_CLASS
do
	local classes = { GetAuctionItemClasses() }
	QUEST_CLASS = classes[12]
end

-- Bags the player carries: backpack (0), bags 1..4 and the keyring (-2, 3.3.5 still has it)
local BAGS = {}
for bag = _G.BACKPACK_CONTAINER or 0, _G.NUM_BAG_SLOTS or 4 do
	BAGS[#BAGS + 1] = bag
end
if _G.KEYRING_CONTAINER then
	BAGS[#BAGS + 1] = _G.KEYRING_CONTAINER
end
QIH.BAGS = BAGS

function QIH.GetBagNumSlots(bag)
	return GetContainerNumSlots(bag) or 0
end

-- itemID in a bag slot, or nil for an empty slot
function QIH.GetBagItemID(bag, slot)
	local itemID = GetContainerItemID and GetContainerItemID(bag, slot)
	if itemID then
		return itemID
	end
	local link = GetContainerItemLink(bag, slot)
	return link and tonumber(link:match('item:(%d+)'))
end

-- isQuestItem, startsQuestID. Both nil when the client lacks the API (pre-3.3) or the slot is empty.
function QIH.GetBagItemQuestInfo(bag, slot)
	if not GetContainerItemQuestInfo then
		return nil, nil
	end
	local isQuestItem, questID = GetContainerItemQuestInfo(bag, slot)
	if questID == 0 then
		questID = nil
	end
	return isQuestItem and true or false, questID
end

-- name, isQuestClass. name is nil while the item is not in the client cache yet.
function QIH.GetItemBasics(itemID)
	local name, _, _, _, _, itemType = GetItemInfo(itemID)
	if not name then
		return nil
	end
	return name, (QUEST_CLASS ~= nil and itemType == QUEST_CLASS)
end

function QIH.GetQuestIDFromLink(link)
	return link and tonumber(link:match('|Hquest:(%d+)'))
end

-- title, isHeader, isCollapsed, isDaily, questID for one quest log row.
-- 3.3.5 GetQuestLogTitle returns (title, level, tag, suggestedGroup, isHeader, isCollapsed,
-- isComplete, isDaily, questID). The quest link is the more reliable ID source, so prefer it.
function QIH.GetQuestLogEntry(index)
	local title, _, _, _, isHeader, isCollapsed, _, isDaily, questID = GetQuestLogTitle(index)
	if not title then
		return nil
	end
	if not isHeader then
		questID = QIH.GetQuestIDFromLink(GetQuestLink(index)) or tonumber(questID)
	else
		questID = nil
	end
	return title, isHeader and true or false, isCollapsed and true or false, isDaily and true or false, questID
end

-- itemID of the "use this item" button a quest offers (3.3: GetQuestLogSpecialItemInfo)
function QIH.GetQuestSpecialItemID(index)
	local fn = _G.GetQuestLogSpecialItemInfo
	local link = fn and fn(index)
	return type(link) == 'string' and tonumber(link:match('item:(%d+)')) or nil
end

-- Completed-quest history. 3.3.0+: QueryQuestsCompleted() asks the server, the answer arrives with
-- QUEST_QUERY_COMPLETE and is read with GetQuestsCompleted(table).
function QIH.RequestCompletedQuests()
	local fn = _G.QueryQuestsCompleted
	if fn then
		fn()
		return true
	end
	return false
end

function QIH.ReadCompletedQuests(into)
	local fn = _G.GetQuestsCompleted
	if fn then
		fn(into)
		return true
	end
	return false
end

-- Title shown on the quest completion (reward) panel
function QIH.GetCompletingQuestTitle()
	local fn = _G.GetTitleText
	return fn and fn() or nil
end
