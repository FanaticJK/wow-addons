--[[
	BagnonDBUI
		Functions for the dropdown menu for showing cached data
		No alterations if this code should be needed to make it work with other databases

	Essentially the dropdown is used to switch between the inventory of other characters
	Why not use a normal dropdown?  It takes a lot of memory
--]]

local currentFrame
local dropdown
local info = {}

--adds a checkable item to a dropdown menu
local function AddCheckItem(text, value, func, checked, hasArrow, level, arg1, arg2)
	info.text = text
	info.func = func
	info.value = value
	info.hasArrow = (hasArrow and true) or nil
	info.notCheckable = false
	info.checked = checked
	info.arg1 = arg1
	info.arg2 = arg2
	UIDropDownMenu_AddButton(info, level)
end

--adds an uncheckable item to a dropdown menu
local function AddItem(text, value, func, level, arg1, arg2)
	info.text = text
	info.func = func
	info.value = value
	info.hasArrow = false
	info.notCheckable = true
	info.checked = false
	info.arg1 = arg1
	info.arg2 = arg2
	UIDropDownMenu_AddButton(info, level)
end

--removing a character permanently deletes its cached data, so ask first
local function ConfirmRemovePlayer(player, frame)
	if not StaticPopupDialogs['BAGNON_FOREVER_REMOVE_PLAYER'] then
		StaticPopupDialogs['BAGNON_FOREVER_REMOVE_PLAYER'] = {
			text = 'Remove all saved Bagnon data for %s?',
			button1 = YES,
			button2 = NO,
			OnAccept = function(self, data)
				BagnonDB:RemovePlayer(data.player)
				if data.frame and data.frame.SetPlayer then
					data.frame:SetPlayer(UnitName('player'))
				end
			end,
			timeout = 0, whileDead = 1, hideOnEscape = 1, showAlert = 1,
		}
	end

	local dialog = StaticPopup_Show('BAGNON_FOREVER_REMOVE_PLAYER', player)
	if dialog then
		dialog.data = {player = player, frame = frame}
	end
end

local function CharSelect_OnClick(self, player, delete)
	if delete then
		ConfirmRemovePlayer(player, currentFrame)
	else
		--show the given player, and check the selected one
		currentFrame:SetPlayer(player)
	end

	--hide the previous dropdown menus (hack)
	for i = 1, UIDROPDOWNMENU_MENU_LEVEL-1 do
		local list = _G['DropDownList' .. i]
		if list then
			list:Hide()
		end
	end
end

local function GetDisplayName(player)
	local class = BagnonDB.GetPlayerClass and BagnonDB:GetPlayerClass(player)
	local color = class and RAID_CLASS_COLORS and RAID_CLASS_COLORS[class]
	if color then
		return string.format('|cff%02x%02x%02x%s|r', color.r * 255, color.g * 255, color.b * 255, player)
	end
	return player
end

--populate the list, add a delete button to all characters that aren't the current player
local function CharSelect_Initialize(self, level)
	local playerList = BagnonDB:GetPlayerList()
	local level = level or 1

	if level == 1 then
		local selected = currentFrame:GetPlayer()
		local current = UnitName('player')

		for i,player in ipairs(playerList) do
			AddCheckItem(GetDisplayName(player), i, CharSelect_OnClick, player == selected, player ~= current, level, player)
		end
	elseif level == 2 then
		AddItem(REMOVE, nil, CharSelect_OnClick, level, playerList[UIDROPDOWNMENU_MENU_VALUE], true)
	end
end

local function CharSelect_Create()
	dropdown = CreateFrame("Frame", "BagnonDBCharSelect", UIParent, "UIDropDownMenuTemplate")
	dropdown:SetID(1)
	UIDropDownMenu_Initialize(dropdown, CharSelect_Initialize, "MENU")

	return dropdown
end


--[[ Usable Functions ]]--

--set which frame to "parent" the dropdown to
function BagnonDB:SetDropdownFrame(frame)
	currentFrame = frame
end

--show the character select list at the given location
function BagnonDB:ToggleDropdown(anchor, offX, offY)
	ToggleDropDownMenu(1, nil, dropdown or CharSelect_Create(), anchor, offX, offY)
end