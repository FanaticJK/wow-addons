--[[
	Tooltip.lua
		Appends a short section to item tooltips. Lines are only added after Blizzard's own,
		nothing in the original tooltip is changed.
--]]

local addonName, QIH = ...

local ipairs, tonumber, format = ipairs, tonumber, string.format

local ICON = [[|TInterface\DialogFrame\UI-Dialog-Icon-AlertNew:0|t ]]
local HEADER = 'Quest Item Helper'

local function QuestLabel(questID)
	return QIH:GetQuestTitle(questID) or format('Quest #%d', questID)
end

local function QuestStatus(questID)
	if QIH:IsQuestActive(questID) then
		return '|cff20ff20in your quest log|r'
	elseif QIH:IsQuestCompleted(questID) then
		return '|cff999999turned in|r'
	end
	return '|cffff8000not in your quest log|r'
end

local function AddFlagged(tooltip, verdict)
	tooltip:AddLine(' ')
	tooltip:AddLine(HEADER, 1, 0.5, 0)

	if verdict.reason == 'starter_done' then
		tooltip:AddLine(ICON .. 'This item starts a quest you have already completed.', 1, 0.82, 0, true)
	elseif verdict.reason == 'unlinked' then
		tooltip:AddLine(ICON .. 'No quest in your log uses this quest item.', 1, 0.82, 0, true)
		tooltip:AddLine('Which quest it belongs to is unknown, so check before deleting it.', 0.8, 0.8, 0.8, true)
		return
	else
		tooltip:AddLine(ICON .. 'This item may belong to an old/inactive quest.', 1, 0.82, 0, true)
	end

	local quests = verdict.quests
	if quests then
		tooltip:AddLine(#quests > 1 and 'Associated quests:' or 'Associated quest:', 1, 1, 1)
		for _, questID in ipairs(quests) do
			tooltip:AddDoubleLine('  ' .. QuestLabel(questID), QuestStatus(questID), 1, 1, 1)
		end
		if verdict.reason == 'inactive' then
			tooltip:AddLine(#quests > 1 and 'You do not currently have any of these quests.'
				or 'You do not currently have this quest.', 0.8, 0.8, 0.8, true)
		end
	end
end

local function AddActive(tooltip, verdict)
	local quests = verdict.quests
	if not quests then
		return
	end
	local names = {}
	for _, questID in ipairs(quests) do
		if QIH:IsQuestActive(questID) then
			names[#names + 1] = QuestLabel(questID)
		end
	end
	if #names > 0 then
		tooltip:AddLine(HEADER .. ': needed for ' .. table.concat(names, ', '), 0.25, 1, 0.25, true)
	end
end

local function OnTooltipSetItem(tooltip)
	local db = QIH.db
	if not (db and db.enabled and db.tooltipEnabled) then
		return
	end
	local _, link = tooltip:GetItem()
	local itemID = link and tonumber(link:match('item:(%d+)'))
	if not itemID then
		return
	end

	-- only items already judged from a bag slot have a verdict; anything else stays untouched
	local verdict = QIH:GetVerdict(itemID)
	if verdict.state == QIH.FLAG then
		AddFlagged(tooltip, verdict)
		tooltip:Show()  -- resize to fit the new lines
	elseif verdict.state == QIH.ACTIVE then
		AddActive(tooltip, verdict)
		tooltip:Show()
	end
end

function QIH:InstallTooltip()
	if self.tooltipInstalled then
		return
	end
	self.tooltipInstalled = true
	GameTooltip:HookScript('OnTooltipSetItem', OnTooltipSetItem)
end
