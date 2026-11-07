--[[
	Loot Roll Tooltip Fix

	Problem: on the Need/Greed/Disenchant roll popup (GroupLootFrame1..4), Blizzard sets the item
	tooltip only once, in the icon's OnEnter. If anything else touches the shared GameTooltip while
	the mouse is still on the icon (a tooltip-scanning add-on, a bag or chat-loot event that makes
	an add-on redraw it, a new roll popup appearing), the tooltip disappears or changes and does
	not come back until you move the mouse off the icon and back on. It looks like it showed for a
	split second.

	Fix: while the mouse is over a roll icon, check a few times a second. If the tooltip is hidden
	or no longer belongs to that icon, show it again for that roll. No settings, no saved data.
]]

local CHECK_INTERVAL = 0.1 -- seconds between checks while a roll popup is open

local GameTooltip = GameTooltip
local GetMouseFocus = GetMouseFocus
local getglobal = getglobal

local icons = {}

local function CollectIcons()
	local count = NUM_GROUP_LOOT_FRAMES or 4
	for i = 1, count do
		local icon = getglobal("GroupLootFrame" .. i .. "IconFrame")
		if icon then
			icons[#icons + 1] = icon
		end
	end
end

local function ShowRollTooltip(icon)
	local frame = icon:GetParent()
	local rollID = frame and frame.rollID
	if not rollID then return end
	GameTooltip:SetOwner(icon, "ANCHOR_RIGHT")
	GameTooltip:SetLootRollItem(rollID)
	if CursorUpdate then CursorUpdate(icon) end
end

local driver = CreateFrame("Frame")
local elapsedSinceCheck = 0

driver:SetScript("OnUpdate", function(self, elapsed)
	elapsedSinceCheck = elapsedSinceCheck + elapsed
	if elapsedSinceCheck < CHECK_INTERVAL then return end
	elapsedSinceCheck = 0

	local focus = GetMouseFocus()
	if not focus then return end
	for i = 1, #icons do
		local icon = icons[i]
		if focus == icon then
			if icon:IsVisible() and (not GameTooltip:IsShown() or GameTooltip:GetOwner() ~= icon or GameTooltip:NumLines() == 0) then
				ShowRollTooltip(icon)
			end
			return
		end
	end
end)

-- Only run the check while at least one roll popup is on screen.
local function UpdateDriver()
	for i = 1, #icons do
		local frame = icons[i]:GetParent()
		if frame and frame:IsShown() then
			driver:Show()
			return
		end
	end
	driver:Hide()
end

CollectIcons()
for i = 1, #icons do
	local frame = icons[i]:GetParent()
	if frame then
		frame:HookScript("OnShow", UpdateDriver)
		frame:HookScript("OnHide", UpdateDriver)
	end
end
UpdateDriver()
