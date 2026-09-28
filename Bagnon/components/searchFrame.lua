--[[
	searchFrame.lua
		A search frame widget
--]]

local Bagnon = LibStub('AceAddon-3.0'):GetAddon('Bagnon')
local L = LibStub('AceLocale-3.0'):GetLocale('Bagnon')
local SearchFrame = Bagnon.Classy:New('EditBox')
SearchFrame:Hide()

Bagnon.SearchFrame = SearchFrame


function SearchFrame:New(frameID, parent)
	local Style = Bagnon.Style
	local f = self:Bind(CreateFrame('EditBox', nil, parent))
	f:SetToplevel(true)
	f:Hide()

	f:SetFrameStrata('DIALOG')
	f:SetTextInsets(8, 22, 0, 0)
	f:SetFontObject('ChatFontNormal')
	f:SetMaxLetters(100)

	f:SetBackdrop(Style.flatBackdrop)
	f:SetBackdropColor(unpack(Style.colors.inputBackground))
	f:SetBackdropBorderColor(Style.colors.accent[1], Style.colors.accent[2], Style.colors.accent[3], 0.8)

	--placeholder text, shown while the box is empty
	local placeholder = f:CreateFontString(nil, 'ARTWORK', 'GameFontDisableSmall')
	placeholder:SetPoint('LEFT', 8, 0)
	placeholder:SetText(L.SearchPlaceholder)
	f.placeholder = placeholder

	--clear button
	local clear = Style:CreateTextButton(f, 'x', 18, 18)
	clear:SetPoint('RIGHT', -2, 0)
	clear:SetScript('OnClick', function(self)
		local editBox = self:GetParent()
		editBox:SetText('')
		editBox:SetFocus()
	end)
	f.clearButton = clear

	f:SetScript('OnShow', f.OnShow)
	f:SetScript('OnHide', f.OnHide)
	f:SetScript('OnTextChanged', f.OnTextChanged)
	f:SetScript('OnEscapePressed', f.OnEscapePressed)
	f:SetScript('OnEnterPressed', f.OnEnterPressed)
	f:SetScript('OnEnter', f.OnEnter)
	f:SetScript('OnLeave', f.OnLeave)

	f:SetFrameID(frameID)
	f:UpdateEvents()
	f:SetAutoFocus(false)

	return f
end

--[[ Messages ]]--

function SearchFrame:TEXT_SEARCH_ENABLE(msg, frameID)
	if self:GetFrameID() == frameID then
		self:UpdateShown()
	end
end

function SearchFrame:TEXT_SEARCH_DISABLE(msg, frameID)
	if self:GetFrameID() == frameID then
		self:UpdateShown()
	end
end


--[[ Frame Events ]]--

function SearchFrame:OnShow()
	self:UpdateEvents()
	self:SetText(self:GetLastSearch())
	self:HighlightText()
	self:SetFocus()
	self:UpdatePlaceholder()
end

function SearchFrame:OnHide()
	self:UpdateEvents()

	self:ClearFocus()
	self:SetSearch('')
end

function SearchFrame:OnTextChanged()
	self:SetSearch(self:GetText())
	self:UpdatePlaceholder()
end

function SearchFrame:OnEscapePressed()
	self:DisableSearch()
end

function SearchFrame:OnEnterPressed()
	self:DisableSearch()
end

function SearchFrame:OnEnter()
	Bagnon.Style:AnchorTooltip(self)
	Bagnon.Style:SetTooltip(GameTooltip, L.SearchPlaceholder, L.TipSearchHelp)
end

function SearchFrame:OnLeave()
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
end


--[[ Update Methods ]]--

function SearchFrame:UpdateEvents()
	self:UnregisterAllMessages()

	self:RegisterMessage('TEXT_SEARCH_ENABLE')
	self:RegisterMessage('TEXT_SEARCH_DISABLE')
end

function SearchFrame:UpdateShown()
	if self:IsSearchEnabled() then
		if not self:IsShown() then
			UIFrameFadeIn(self, 0.1)
		end
	else
		self:Hide()
	end
end

function SearchFrame:UpdateText()
	self:SetText(self:GetSearch())
end

function SearchFrame:UpdatePlaceholder()
	local empty = (self:GetText() or '') == ''
	if empty then
		self.placeholder:Show()
		self.clearButton:Hide()
	else
		self.placeholder:Hide()
		self.clearButton:Show()
	end
end


--[[ Propertiesish ]]--

function SearchFrame:SetFrameID(frameID)
	if self:GetFrameID() ~= frameID then
		self.frameID = frameID
		self:UpdateShown()
		self:UpdateText()
	end
end

function SearchFrame:GetFrameID()
	return self.frameID
end


--[[ Frame Settings ]]--

function SearchFrame:GetSettings()
	return Bagnon.FrameSettings:Get(self:GetFrameID())
end

function SearchFrame:SetSearch(search)
	Bagnon.Settings:SetTextSearch(search)
end

function SearchFrame:GetSearch()
	return Bagnon.Settings:GetTextSearch()
end

function SearchFrame:GetLastSearch()
	return Bagnon.Settings:GetLastTextSearch()
end

function SearchFrame:EnableSearch()
	self:GetSettings():EnableTextSearch()
end

function SearchFrame:DisableSearch()
	self:GetSettings():DisableTextSearch()
end

function SearchFrame:IsSearchEnabled()
	return self:GetSettings():IsTextSearchEnabled()
end
