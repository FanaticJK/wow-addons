--[[
	slotCounter.lua
		Footer widget showing how many bag slots are free
--]]

local Bagnon = LibStub('AceAddon-3.0'):GetAddon('Bagnon')
local L = LibStub('AceLocale-3.0'):GetLocale('Bagnon')
local SlotCounter = Bagnon.Classy:New('Button')
SlotCounter:Hide()
Bagnon.SlotCounter = SlotCounter

local ICON_SIZE = 14


--[[ Constructor ]]--

function SlotCounter:New(frameID, parent)
	local Style = Bagnon.Style
	local f = self:Bind(CreateFrame('Button', nil, parent))
	f:SetHeight(Style.FOOTER_HEIGHT)

	local icon = f:CreateTexture(nil, 'ARTWORK')
	icon:SetWidth(ICON_SIZE)
	icon:SetHeight(ICON_SIZE)
	icon:SetPoint('LEFT')
	icon:SetTexture([[Interface\Buttons\Button-Backpack-Up]])
	f.icon = icon

	local text = f:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
	text:SetPoint('LEFT', icon, 'RIGHT', Style.GAP, 0)
	f.text = text

	f:SetScript('OnShow', f.OnShow)
	f:SetScript('OnHide', f.OnHide)
	f:SetScript('OnEnter', f.OnEnter)
	f:SetScript('OnLeave', f.OnLeave)

	f.frameID = frameID
	return f
end


--[[ Messages ]]--

function SlotCounter:ITEM_FRAME_CONTENTS_UPDATE(msg, frameID)
	if frameID == self.frameID then
		self:Update()
	end
end


--[[ Frame Events ]]--

function SlotCounter:OnShow()
	self:RegisterMessage('ITEM_FRAME_CONTENTS_UPDATE')
	self:Update()
end

function SlotCounter:OnHide()
	self:UnregisterAllMessages()
end

function SlotCounter:OnEnter()
	Bagnon.Style:AnchorTooltip(self)

	local free, total, specialFree, specialTotal = self:GetCounts()
	GameTooltip:SetText(L.TipFreeSlots, 1, 1, 1)
	GameTooltip:AddLine(string.format(L.TipFreeSlotsDetail, free, total))
	if specialTotal > 0 then
		GameTooltip:AddLine(string.format(L.TipSpecialtySlots, specialFree, specialTotal), 0.62, 0.62, 0.65)
	end
	GameTooltip:Show()
end

function SlotCounter:OnLeave()
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
end


--[[ Update Methods ]]--

function SlotCounter:GetCounts()
	local itemFrame = self:GetParent().GetItemFrame and self:GetParent():GetItemFrame()
	if itemFrame and itemFrame.GetSlotCounts then
		return itemFrame:GetSlotCounts()
	end
	return 0, 0, 0, 0
end

function SlotCounter:Update()
	if not self:IsVisible() then return end

	local colors = Bagnon.Style.colors
	local free, total = self:GetCounts()

	local color = colors.text
	if total > 0 and free == 0 then
		color = colors.bad
	elseif total > 0 and free <= math.max(2, math.floor(total * 0.1)) then
		color = colors.warning
	end

	self.text:SetFormattedText('%d/%d', free, total)
	self.text:SetTextColor(color[1], color[2], color[3])
	self:SetWidth(ICON_SIZE + Bagnon.Style.GAP + self.text:GetStringWidth())
end
