--[[
	Bags.lua
		Draws the flag (colored border + corner icon) on bag item buttons, a small tick on quest
		items a quest in the log still needs, and the adapters that tell us which button shows
		which bag slot.

		Every adapter only has to call QIH:UpdateButton(button, bag, slot) whenever its bag addon
		(re)draws a slot. Other bag addons can integrate the same way through the public
		QuestItemHelper global, or register an adapter with QuestItemHelper:RegisterBagAdapter().
--]]

local addonName, QIH = ...

local _G = _G
local pairs, ipairs, type = pairs, ipairs, type
local hooksecurefunc = hooksecurefunc
local IsAddOnLoaded = IsAddOnLoaded

-- Blizzard's own textures, so no art ships with the addon
local BORDER_TEXTURE = [[Interface\Buttons\UI-ActionButton-Border]]
local ICON_TEXTURE = [[Interface\DialogFrame\UI-Dialog-Icon-AlertNew]]
local TICK_TEXTURE = [[Interface\Buttons\UI-CheckBox-Check]]

-- button -> { bag, slot, border, icon, tick }. Weak keys: bag addons recycle and drop buttons freely,
-- and nothing is stored on the (secure template) buttons themselves.
local tracked = setmetatable({}, { __mode = 'k' })

local function CreateOverlay(button, record)
	local border = button:CreateTexture(nil, 'OVERLAY')
	border:SetTexture(BORDER_TEXTURE)
	border:SetBlendMode('ADD')
	border:SetAlpha(0.9)
	-- the action button border art is 64px with the visible edge around the middle ~36px
	local size = (button:GetWidth() or 37) * 1.8
	border:SetWidth(size)
	border:SetHeight(size)
	border:SetPoint('CENTER', button, 'CENTER', 0, 0)
	border:Hide()

	local icon = button:CreateTexture(nil, 'OVERLAY')
	icon:SetTexture(ICON_TEXTURE)
	icon:SetWidth(16)
	icon:SetHeight(16)
	icon:SetPoint('TOPLEFT', button, 'TOPLEFT', -2, 2)
	icon:Hide()

	record.border, record.icon = border, icon
end

local function CreateTick(button, record)
	local tick = button:CreateTexture(nil, 'OVERLAY')
	tick:SetTexture(TICK_TEXTURE)
	tick:SetWidth(16)
	tick:SetHeight(16)
	tick:SetPoint('TOPRIGHT', button, 'TOPRIGHT', 2, 2)
	tick:Hide()
	record.tick = tick
end

local function HideFlag(record)
	if record.border then
		record.border:Hide()
		record.icon:Hide()
	end
end

local function HideOverlay(record)
	HideFlag(record)
	if record.tick then
		record.tick:Hide()
	end
end

-- Show or clear the flag/tick on one button. bag/slot nil clears it (empty or offline-cached slot).
function QIH:UpdateButton(button, bag, slot)
	if type(button) ~= 'table' or not button.CreateTexture then
		return
	end
	local record = tracked[button]
	if not record then
		record = {}
		tracked[button] = record
	end
	record.bag, record.slot = bag, slot

	local db = self.db
	if not (db and db.enabled and bag and slot) then
		HideOverlay(record)
		return
	end

	local itemID = self.GetBagItemID(bag, slot)
	local verdict = itemID and self:GetVerdict(itemID, bag, slot)
	local state = verdict and verdict.state

	if state == self.ACTIVE and db.showQuestTick then
		if not record.tick then
			CreateTick(button, record)
		end
		record.tick:Show()
	elseif record.tick then
		record.tick:Hide()
	end

	if not (state == self.FLAG and db.highlightEnabled) then
		HideFlag(record)
		return
	end

	if not record.border then
		CreateOverlay(button, record)
	end
	local color = db.highlightColor
	record.border:SetVertexColor(color.r or 1, color.g or 0.5, color.b or 0)
	record.border:Show()
	if db.showIcon then
		record.icon:Show()
	else
		record.icon:Hide()
	end
end

-- verdicts or settings changed: redraw every visible button we have seen
function QIH:RefreshButtons()
	for button, record in pairs(tracked) do
		if button:IsVisible() then
			self:UpdateButton(button, record.bag, record.slot)
		else
			HideOverlay(record)
		end
	end
end

--[[ adapters ]]--

local adapters = {}

-- addonName nil means "always available" (Blizzard UI). install() runs once, after that addon loads.
function QIH:RegisterBagAdapter(name, ownerAddon, install)
	adapters[#adapters + 1] = { name = name, addon = ownerAddon, install = install }
	if self.db then
		self:InstallAdapters()
	end
end

function QIH:InstallAdapters()
	for _, adapter in ipairs(adapters) do
		if not adapter.installed and (not adapter.addon or IsAddOnLoaded(adapter.addon)) then
			adapter.installed = true
			local ok, err = pcall(adapter.install)
			if ok then
				self:Debug('Bag integration enabled: ' .. adapter.name)
			else
				self:Debug('Bag integration failed: ' .. adapter.name .. ' (' .. tostring(err) .. ')')
			end
		end
	end
end

-- Blizzard bags (backpack, bags 1-4, keyring, bank bags). ContainerFrame_Update redraws a whole
-- container frame; its buttons are <frame>Item1..N, bag = frame ID, slot = button ID.
QIH:RegisterBagAdapter('Blizzard', nil, function()
	hooksecurefunc('ContainerFrame_Update', function(frame)
		local bag, name = frame:GetID(), frame:GetName()
		for i = 1, frame.size or 0 do
			local button = _G[name .. 'Item' .. i]
			if button then
				QIH:UpdateButton(button, bag, button:GetID())
			end
		end
	end)
end)

-- Bagnon 2.x: every slot redraws through ItemSlot:Update(). Instances look methods up through the
-- class metatable, so hooking the class covers slots that already exist. Offline (cached) views of
-- other characters or a closed bank are skipped: their slots are not in the live bags.
QIH:RegisterBagAdapter('Bagnon', 'Bagnon', function()
	local ItemSlot = _G.Bagnon and _G.Bagnon.ItemSlot
	if not (ItemSlot and ItemSlot.Update) then
		return
	end
	hooksecurefunc(ItemSlot, 'Update', function(slot)
		if not slot:IsVisible() then
			return
		end
		if slot.IsCached and slot:IsCached() then
			QIH:UpdateButton(slot)
		else
			QIH:UpdateButton(slot, slot:GetBag(), slot:GetID())
		end
	end)
end)

-- Baggins: every button is drawn by Baggins:UpdateItemButton(bagframe, button, bag, slot)
QIH:RegisterBagAdapter('Baggins', 'Baggins', function()
	local Baggins = _G.Baggins
	if not (Baggins and Baggins.UpdateItemButton) then
		return
	end
	hooksecurefunc(Baggins, 'UpdateItemButton', function(_, _, button, bag, slot)
		QIH:UpdateButton(button, bag, slot)
	end)
end)

--[[ wiring, called from Core's event handlers ]]--

function QIH:OnAddonLoaded()
	if self.db then
		self:InstallAdapters()
	end
end
