--[[
	Bagnon Tooltips
		Adds "who has what" ownership lines to item tooltips, based on Bagnon_Forever data
--]]

if not (BagnonDB and BagnonDB.GetPlayers and BagnonDB.GetItemCount) then
	return
end

local currentPlayer = UnitName('player')
local SILVER = '|cffc7c7cf%s|r'
local TEAL = '|cff00ff9a%s|r'


--[[ Counting ]]--

local function CountItem(link, player)
	local invCount = BagnonDB:GetItemCount(link, KEYRING_CONTAINER, player)
	for bag = 0, NUM_BAG_SLOTS do
		invCount = invCount + BagnonDB:GetItemCount(link, bag, player)
	end

	local bankCount = BagnonDB:GetItemCount(link, BANK_CONTAINER, player)
	for i = 1, NUM_BANKBAGSLOTS do
		bankCount = bankCount + BagnonDB:GetItemCount(link, NUM_BAG_SLOTS + i, player)
	end

	local equipCount = BagnonDB:GetItemCount(link, 'e', player)

	return invCount or 0, bankCount or 0, equipCount or 0
end

local function CountsToInfoString(invCount, bankCount, equipCount)
	local info
	local total = invCount + bankCount + equipCount

	if invCount > 0 then
		info = BAGNON_NUM_BAGS:format(invCount)
	end

	if bankCount > 0 then
		local count = BAGNON_NUM_BANK:format(bankCount)
		if info then
			info = strjoin(', ', info, count)
		else
			info = count
		end
	end

	if equipCount > 0 then
		if info then
			info = strjoin(', ', info, BAGNON_EQUIPPED)
		else
			info = BAGNON_EQUIPPED
		end
	end

	if info then
		if not (total == invCount or total == bankCount or total == equipCount) then
			return format(TEAL, total) .. format(SILVER, format(' (%s)', info)), total
		end
		return format(TEAL, info), total
	end
	return '', 0
end


--[[
	Caching
		Tooltip updates run several times a second while hovering, and counting an item scans
		every saved slot.  Results are cached per player per item.  Other characters' data can't
		change this session; the current character's cache is cleared when their items change.
--]]

local function NewCache()
	return setmetatable({}, {__index = function(self, link)
		local info = {}
		self[link] = info
		return info
	end})
end

local playerCaches = {}

local function GetOwnerInfo(player, link)
	local cache = playerCaches[player]
	if not cache then
		cache = NewCache()
		playerCaches[player] = cache
	end

	local info = cache[link]
	if not info.text then
		info.text, info.total = CountsToInfoString(CountItem(link, player))
	end
	return info.text, info.total
end

do
	local f = CreateFrame('Frame')
	f:SetScript('OnEvent', function(self, event, unit)
		if event ~= 'UNIT_INVENTORY_CHANGED' or unit == 'player' then
			playerCaches[currentPlayer] = nil
		end
	end)
	f:RegisterEvent('BAG_UPDATE')
	f:RegisterEvent('PLAYERBANKSLOTS_CHANGED')
	f:RegisterEvent('UNIT_INVENTORY_CHANGED')
end


--[[ Tooltip Hooks ]]--

local function ClassColor(player)
	local class = BagnonDB.GetPlayerClass and BagnonDB:GetPlayerClass(player)
	local color = class and RAID_CLASS_COLORS and RAID_CLASS_COLORS[class]
	if color then
		return color.r, color.g, color.b
	end
	return 0, 1, 0.6
end

local function AddOwners(frame, link)
	local owners, grandTotal = 0, 0

	for player in BagnonDB:GetPlayers() do
		local infoString, total = GetOwnerInfo(player, link)

		if infoString and infoString ~= '' then
			local r, g, b = ClassColor(player)
			frame:AddDoubleLine(player, infoString, r, g, b)
			owners = owners + 1
			grandTotal = grandTotal + (total or 0)
		end
	end

	if owners > 1 then
		frame:AddDoubleLine(TOTAL or 'Total', format(TEAL, grandTotal), 0.62, 0.62, 0.65)
	end

	if owners > 0 then
		frame:Show()
	end
end

local function HookTip(tooltip)
	if not tooltip then return end

	tooltip:HookScript('OnTooltipSetItem', function(self, ...)
		local itemLink = select(2, self:GetItem())
		if itemLink and GetItemInfo(itemLink) then --fix for blizzard doing craziness when doing getiteminfo
			AddOwners(self, itemLink)
		end
	end)
end

HookTip(GameTooltip)
HookTip(ItemRefTooltip)
