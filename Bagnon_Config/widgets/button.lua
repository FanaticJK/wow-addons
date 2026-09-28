--[[
	button.lua
		A bagnon options push button, with optional confirmation dialog
--]]

local Bagnon = LibStub('AceAddon-3.0'):GetAddon('Bagnon')
local OptionsButton = Bagnon.Classy:New('Button')
Bagnon.OptionsButton = OptionsButton

local L = LibStub('AceLocale-3.0'):GetLocale('Bagnon-Config')
local CONFIRM_DIALOG = 'BAGNON_OPTIONS_CONFIRM'


--[[ Constructor ]]--

function OptionsButton:New(text, parent, width)
	local b = self:Bind(CreateFrame('Button', nil, parent, 'UIPanelButtonTemplate'))
	b:SetText(text)
	b:SetWidth(width or math.max(b:GetTextWidth() + 24, 100))
	b:SetHeight(22)
	b:SetScript('OnClick', b.OnClick)

	return b
end


--[[ Frame Events ]]--

function OptionsButton:OnClick()
	PlaySound('igMainMenuOptionCheckBoxOn')

	if self.confirmText then
		self:ShowConfirmation()
	else
		self:OnAccept()
	end
end


--[[ Confirmation ]]--

--when set, clicking asks for confirmation before calling OnAccept
function OptionsButton:SetConfirmation(text)
	self.confirmText = text
end

function OptionsButton:ShowConfirmation()
	if not StaticPopupDialogs[CONFIRM_DIALOG] then
		StaticPopupDialogs[CONFIRM_DIALOG] = {
			button1 = YES,
			button2 = NO,
			OnAccept = function(self, data)
				if data and data.OnAccept then
					data:OnAccept()
				end
			end,
			timeout = 0,
			whileDead = 1,
			hideOnEscape = 1,
			showAlert = 1,
		}
	end

	StaticPopupDialogs[CONFIRM_DIALOG].text = self.confirmText
	local dialog = StaticPopup_Show(CONFIRM_DIALOG)
	if dialog then
		dialog.data = self
	end
end

function OptionsButton:OnAccept()
	assert(false, 'Hey, you forgot to implement OnAccept for an options button')
end
