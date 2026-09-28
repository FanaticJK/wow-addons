--[[
	dropdown.lua
		A bagnon dropdown menu
--]]

local Bagnon = LibStub('AceAddon-3.0'):GetAddon('Bagnon')
local OptionsDropdown = Bagnon.Classy:New('Frame')
Bagnon.OptionsDropdown = OptionsDropdown

function OptionsDropdown:New(name, parent, width, tooltip)
	local f = self:Bind(CreateFrame('Frame', parent:GetName() .. name, parent, 'UIDropDownMenuTemplate'))
	f.width = width

	--UIDropDownMenu_SetWidth makes the frame 25px wider on each side; the first ~16px are transparent
	f.layoutWidth = width + 50
	f.layoutHeight = 32

	local text = f:CreateFontString(nil, 'BACKGROUND', 'GameFontNormalSmall')
	text:SetPoint('BOTTOMLEFT', f, 'TOPLEFT', 16, 3)
	text:SetText(name)
	f.titleText = text

	f:SetScript('OnShow', f.OnShow)

	if tooltip then
		Bagnon.OptionsTooltip:Attach(f, name, tooltip)
		f:EnableMouse(true)
	end

	return f
end


--[[ Frame Events ]]--

function OptionsDropdown:OnShow()
	UIDropDownMenu_SetWidth(self, self.width)
	UIDropDownMenu_Initialize(self, self.Initialize)
	UIDropDownMenu_SetSelectedValue(self, self:GetSavedValue())
end

--refreshes the displayed selection after the saved value changed elsewhere
function OptionsDropdown:UpdateValue()
	if self:IsVisible() then
		UIDropDownMenu_Initialize(self, self.Initialize)
		UIDropDownMenu_SetSelectedValue(self, self:GetSavedValue())
	end
end


--[[ Update Methods ]]--

function OptionsDropdown:Initialize()
	assert(false, 'Hey you forgot to implement Initialize for ' .. self:GetName())
end

function OptionsDropdown:SetSavedValue(value)
	assert(false, 'Hey you forgot to implement SetSavedValue for ' .. self:GetName())
end

function OptionsDropdown:GetSavedValue()
	assert(false, 'Hey you forgot to implement GetSavedValue for ' .. self:GetName())
end


--[[ Item Adding ]]--

local function item_OnClick(self, dropdown)
	dropdown:SetSavedValue(self.value)
	UIDropDownMenu_SetSelectedValue(dropdown, self.value)
end

function OptionsDropdown:AddItem(name, value)
	local info = UIDropDownMenu_CreateInfo()
	info.text = name
	info.value = value or name
	info.arg1 = self
	info.func = item_OnClick
	info.checked = (self:GetSavedValue() == info.value)

	UIDropDownMenu_AddButton(info)
end
