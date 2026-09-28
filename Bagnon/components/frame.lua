--[[
	frame.lua
		A Bagnon frame widget

	Layout (all metrics come from Bagnon.Style):

		+--------------------------------------------------+
		| [player][bags][search]  Title ....  [sort][opt] X|  header row
		|--------------------------------------------------|
		| [bag][bag][bag][bag][bag]                        |  bag frame (optional)
		| [item][item][item][item][item][item][item][item] |  item frame
		| ...                                              |
		|--------------------------------------------------|
		| [#] 12/96   < broker plugin >          12g 3s 4c |  footer (optional)
		+--------------------------------------------------+
--]]

local Bagnon = LibStub('AceAddon-3.0'):GetAddon('Bagnon')
local L = LibStub('AceLocale-3.0'):GetLocale('Bagnon')
local Frame = Bagnon.Classy:New('Frame')
Frame:Hide()
Bagnon.Frame = Frame

--SmallMoneyFrameTemplate reserves this much empty space right of the copper icon
local MONEY_FRAME_RIGHT_PADDING = 13


--[[
	Constructor
--]]

function Frame:New(frameID)
	local Style = Bagnon.Style
	local f = self:Bind(CreateFrame('Frame', 'BagnonFrame' .. frameID, UIParent))
	f:Hide()
	f:SetClampedToScreen(true)
	f:SetMovable(true)
	f:EnableMouse(true)
	f:SetBackdrop(Style.frameBackdrop)

	--header band and section dividers
	f.headerBand = Style:CreateHeaderBand(f)
	f.headerDivider = Style:CreateDivider(f)
	f.footerDivider = Style:CreateDivider(f)

	f:SetScript('OnShow', f.OnShow)
	f:SetScript('OnHide', f.OnHide)
	f.frameID = frameID
	f:Rescale()
	f:UpdateEverything()

	table.insert(UISpecialFrames, f:GetName())

	return f
end


--[[
	Frame Messages
--]]

function Frame:UpdateEvents()
	self:UnregisterAllMessages()

	self:RegisterMessage('FRAME_SHOW')

	if self:IsVisible() then
		self:RegisterMessage('FRAME_HIDE')
		self:RegisterMessage('FRAME_LAYER_UPDATE')
		self:RegisterMessage('FRAME_MOVE_START')
		self:RegisterMessage('FRAME_MOVE_STOP')
		self:RegisterMessage('FRAME_POSITION_UPDATE')
		self:RegisterMessage('FRAME_OPACITY_UPDATE')
		self:RegisterMessage('FRAME_COLOR_UPDATE')
		self:RegisterMessage('FRAME_BORDER_COLOR_UPDATE')
		self:RegisterMessage('FRAME_SCALE_UPDATE')
		self:RegisterMessage('FRAME_SETTINGS_RESET')
		self:RegisterMessage('BAG_FRAME_UPDATE_SHOWN')
		self:RegisterMessage('BAG_FRAME_UPDATE_LAYOUT')
		self:RegisterMessage('ITEM_FRAME_SIZE_CHANGE')
		self:RegisterMessage('PLAYER_UPDATE', 'LayoutForFrame')

		self:RegisterMessage('BAG_FRAME_ENABLE_UPDATE', 'LayoutForFrame')
		self:RegisterMessage('MONEY_FRAME_ENABLE_UPDATE', 'LayoutForFrame')
		self:RegisterMessage('DATABROKER_FRAME_ENABLE_UPDATE', 'LayoutForFrame')
		self:RegisterMessage('SEARCH_TOGGLE_ENABLE_UPDATE', 'LayoutForFrame')
		self:RegisterMessage('OPTIONS_TOGGLE_ENABLE_UPDATE', 'LayoutForFrame')
		self:RegisterMessage('SORT_BUTTON_ENABLE_UPDATE', 'LayoutForFrame')
		self:RegisterMessage('SLOT_COUNTER_ENABLE_UPDATE', 'LayoutForFrame')
	end
end

--generic handler for any "<component> changed" message that only needs a relayout
function Frame:LayoutForFrame(msg, frameID)
	if self:GetFrameID() == frameID then
		self:Layout()
	end
end

function Frame:FRAME_SHOW(msg, frameID)
	if self:GetFrameID() == frameID then
		self:Show()
	end
end

function Frame:FRAME_HIDE(msg, frameID)
	if self:GetFrameID() == frameID then
		self:Hide()
	end
end

function Frame:FRAME_MOVE_START(msg, frameID)
	if self:GetFrameID() == frameID then
		self:StartMoving()
	end
end

function Frame:FRAME_MOVE_STOP(msg, frameID)
	if self:GetFrameID() == frameID then
		self:StopMovingOrSizing()
		self:SavePosition()
	end
end

function Frame:FRAME_POSITION_UPDATE(msg, frameID)
	if self:GetFrameID() == frameID then
		self:UpdatePosition()
	end
end

function Frame:FRAME_SCALE_UPDATE(msg, frameID, scale)
	if self:GetFrameID() == frameID then
		self:UpdateScale()
	end
end

function Frame:FRAME_OPACITY_UPDATE(msg, frameID, opacity)
	if self:GetFrameID() == frameID then
		self:UpdateOpacity()
	end
end

function Frame:FRAME_COLOR_UPDATE(msg, frameID, r, g, b, a)
	if self:GetFrameID() == frameID then
		self:UpdateBackdrop()
	end
end

function Frame:FRAME_BORDER_COLOR_UPDATE(msg, frameID, r, g, b, a)
	if self:GetFrameID() == frameID then
		self:UpdateBackdropBorder()
	end
end

function Frame:FRAME_SETTINGS_RESET(msg, frameID)
	if self:GetFrameID() == frameID then
		--apply the default scale directly; UpdateScale would shift the (now default) position
		self:Rescale()
		self:UpdatePosition()
		self:UpdateOpacity()
		self:UpdateBackdrop()
		self:UpdateBackdropBorder()
		self:UpdateFrameLayer()

		if self.brokerDisplay then
			self.brokerDisplay:UpdateDisplay()
		end
		self:Layout()
	end
end

function Frame:BAG_FRAME_UPDATE_SHOWN(msg, frameID)
	if self:GetFrameID() == frameID then
		self:Layout()
	end
end

function Frame:BAG_FRAME_UPDATE_LAYOUT(msg, frameID)
	if self:GetFrameID() == frameID then
		self:Layout()
	end
end

function Frame:ITEM_FRAME_SIZE_CHANGE(msg, frameID)
	if self:GetFrameID() == frameID then
		self:Layout()
	end
end

function Frame:FRAME_LAYER_UPDATE(msg, frameID, layer)
	if self:GetFrameID() == frameID then
		self:SetFrameLayer(layer)
	end
end


--[[
	Frame Events
--]]

function Frame:OnShow()
	PlaySound('igBackPackOpen')

	self:UpdateEvents()
	self:UpdateLook()
end

function Frame:OnHide()
	PlaySound('igBackPackClose')

	if self:IsBankFrame() then
		self:CloseBankFrame()
	end

	self:UpdateEvents()

	--fix issue where a frame is hidden, but not via bagnon controlled methods (ie, close on escape)
	if self:IsFrameShown() then
		self:HideFrame()
	end
end

function Frame:CloseBankFrame()
	if Bagnon.PlayerInfo:AtBank() then
		CloseBankFrame()
	end
end

function Frame:IsBankFrame()
	return self:GetFrameID() == 'bank'
end


--[[
	Update Methods
--]]

function Frame:UpdateEverything()
	self:UpdateEvents()
	self:UpdateLook()
end

function Frame:UpdateLook()
	if not self:IsVisible() then
		return
	end

	self:UpdatePosition()
	self:UpdateScale()
	self:UpdateOpacity()
	self:UpdateBackdrop()
	self:UpdateBackdropBorder()
	self:UpdateShown()
	self:UpdateFrameLayer()
	self:Layout()
end


--[[
	Frame Scale
--]]

--alter the frame's scale, but maintain the same relative position of the frame
function Frame:UpdateScale()
	local oldScale = self:GetScale()
	local newScale = self:GetFrameScale()

	if oldScale ~= newScale then
		local point, x, y = self:GetFramePosition()
		local ratio = newScale / oldScale

		self:SetScale(newScale)
		self:GetSettings():SetPosition(point, x/ratio, y/ratio)
	end
end

function Frame:GetFrameScale()
	return self:GetSettings():GetScale()
end

--rescale frame without altering position, needed when loading settings
function Frame:Rescale()
	self:SetScale(self:GetFrameScale())
end


--[[
	Frame Opacity
--]]

function Frame:UpdateOpacity()
	self:SetAlpha(self:GetFrameOpacity())
end

function Frame:GetFrameOpacity()
	return self:GetSettings():GetOpacity()
end


--[[
	Frame Position
--]]

--position
function Frame:SavePosition()
	local point, x, y = self:GetRelativePosition()
	if point then
		self:GetSettings():SetPosition(point, x, y)
	end
end

--get a frame's position relative to its parent
function Frame:GetRelativePosition()
	local parent = self:GetParent()
	local w, h = parent:GetWidth(), parent:GetHeight()
	local x, y = self:GetCenter()
	local s = self:GetScale()
	if not (x and y) then return end

	w = w/s h = h/s

	local dx, dy
	local hHalf = (x > w/2) and 'RIGHT' or 'LEFT'
	if hHalf == 'RIGHT' then
		dx = self:GetRight() - w
	else
		dx = self:GetLeft()
	end

	local vHalf = (y > h/2) and 'TOP' or 'BOTTOM'
	if vHalf == 'TOP' then
		dy = self:GetTop() - h
	else
		dy = self:GetBottom()
	end

	return vHalf..hHalf, dx, dy
end

function Frame:UpdatePosition()
	self:ClearAllPoints()
	self:SetPoint(self:GetFramePosition())
end

function Frame:GetFramePosition()
	return self:GetSettings():GetPosition()
end


--[[
	Frame Color
--]]

--background
function Frame:UpdateBackdrop()
	self:SetBackdropColor(self:GetFrameBackdropColor())
end

function Frame:GetFrameBackdropColor()
	return self:GetSettings():GetColor()
end

--border
function Frame:UpdateBackdropBorder()
	self:SetBackdropBorderColor(self:GetFrameBackdropBorderColor())
end

function Frame:GetFrameBackdropBorderColor()
	return self:GetSettings():GetBorderColor()
end


--[[
	Frame Visibility
--]]

function Frame:UpdateShown()
	if self:IsFrameShown() then
		self:Show()
	else
		self:Hide()
	end
end

function Frame:IsFrameShown()
	return self:GetSettings():IsShown()
end

function Frame:HideFrame()
	self:GetSettings():Hide()
end


--[[
	Frame Layer/Strata
--]]

function Frame:UpdateFrameLayer()
	self:SetFrameLayer(self:GetFrameLayer())
end

function Frame:SetFrameLayer(layer)
	local strata, topLevel = nil, false

	if layer == 'TOPLEVEL' then
		strata = 'HIGH'
		topLevel = true
	elseif layer == 'MEDIUMLOW' then
		strata = 'LOW'
		topLevel = true
	elseif layer == 'MEDIUMHIGH' then
		strata = 'MEDIUM'
		topLevel = true
	else
		strata = layer
		topLevel = false
	end

	self:SetFrameStrata(strata)
	self:SetToplevel(topLevel)
end

function Frame:GetFrameLayer()
	return self:GetSettings():GetLayer()
end


--[[
	Layout Methods
--]]

--place components & update size
function Frame:Layout()
	if not self:IsVisible() then
		return
	end

	local Style = Bagnon.Style
	local padding, gap = Style.PADDING, Style.GAP

	--header row
	local leftWidth = self:PlaceMenuButtons()
	local rightWidth = self:PlaceRightButtons()
	local titleWidth = self:PlaceTitleFrame(leftWidth, rightWidth)
	self:PlaceSearchFrame(leftWidth, rightWidth)

	local width = leftWidth + titleWidth + rightWidth + gap * 2
	local y = padding + Style.MENU_BUTTON_SIZE + gap
	self:PlaceHeaderChrome(y)
	y = y + gap

	--middle
	local w, h = self:PlaceBagFrame(y)
	width = math.max(width, w)
	if h > 0 then
		y = y + h + gap
	end

	w, h = self:PlaceItemFrame(y)
	width = math.max(width, w)
	y = y + h

	--footer
	w, h = self:PlaceFooter()
	width = math.max(width, w)
	if h > 0 then
		y = y + gap * 2 + h
		self.footerDivider:ClearAllPoints()
		self.footerDivider:SetPoint('BOTTOMLEFT', self, 'BOTTOMLEFT', padding, padding + h + gap)
		self.footerDivider:SetPoint('BOTTOMRIGHT', self, 'BOTTOMRIGHT', -padding, padding + h + gap)
		self.footerDivider:Show()
	else
		self.footerDivider:Hide()
	end

	--adjust size
	self:SetWidth(math.max(width + padding * 2, Style.MIN_FRAME_WIDTH))
	self:SetHeight(y + padding)
	self:SavePosition()
end

function Frame:PlaceHeaderChrome(headerHeight)
	local inset = Bagnon.Style.frameBackdrop.insets.left

	self.headerBand:ClearAllPoints()
	self.headerBand:SetPoint('TOPLEFT', self, 'TOPLEFT', inset, -inset)
	self.headerBand:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT', -inset, -headerHeight)

	self.headerDivider:ClearAllPoints()
	self.headerDivider:SetPoint('TOPLEFT', self, 'TOPLEFT', inset, -headerHeight)
	self.headerDivider:SetPoint('TOPRIGHT', self, 'TOPRIGHT', -inset, -headerHeight)
end


--[[ Menu Button Placement ]]--

--places a row of buttons from the given corner, hiding anything not in the list.  returns the row width
local function placeButtonRow(frame, buttons, anchor)
	local Style = Bagnon.Style
	local width = 0

	for i, button in ipairs(buttons) do
		button:ClearAllPoints()
		if i == 1 then
			if anchor == 'TOPRIGHT' then
				button:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', -(Style.PADDING + Style.MENU_BUTTON_SIZE + Style.GAP), -Style.PADDING)
			else
				button:SetPoint('TOPLEFT', frame, 'TOPLEFT', Style.PADDING, -Style.PADDING)
			end
		elseif anchor == 'TOPRIGHT' then
			button:SetPoint('TOPRIGHT', buttons[i-1], 'TOPLEFT', -Style.GAP, 0)
		else
			button:SetPoint('TOPLEFT', buttons[i-1], 'TOPRIGHT', Style.GAP, 0)
		end
		button:Show()
		width = width + button:GetWidth() + (i > 1 and Style.GAP or 0)
	end

	return width
end

--left side of the header: player selector, bag toggle, search toggle
function Frame:PlaceMenuButtons()
	local menuButtons = self.menuButtons or {}
	self.menuButtons = menuButtons

	--hide the old buttons
	for i, button in pairs(menuButtons) do
		button:Hide()
		menuButtons[i] = nil
	end

	if self:HasPlayerSelector() then
		table.insert(menuButtons, self:GetPlayerSelector() or self:CreatePlayerSelector())
	end

	if self:HasBagFrame() and self:HasBagToggle() then
		table.insert(menuButtons, self:GetBagToggle() or self:CreateBagToggle())
	end

	if self:HasSearchToggle() then
		table.insert(menuButtons, self:GetSearchToggle() or self:CreateSearchToggle())
	end

	return placeButtonRow(self, menuButtons, 'TOPLEFT')
end

--right side of the header: sort button, options toggle, then the close button in the corner
function Frame:PlaceRightButtons()
	local Style = Bagnon.Style
	local rightButtons = self.rightButtons or {}
	self.rightButtons = rightButtons

	for i, button in pairs(rightButtons) do
		button:Hide()
		rightButtons[i] = nil
	end

	if self:HasOptionsToggle() then
		table.insert(rightButtons, self:GetOptionsToggle() or self:CreateOptionsToggle())
	elseif self:GetOptionsToggle() then
		self:GetOptionsToggle():Hide()
	end

	if self:HasSortButton() then
		table.insert(rightButtons, self:GetSortButton() or self:CreateSortButton())
	elseif self:GetSortButton() then
		self:GetSortButton():Hide()
	end

	local width = self:PlaceCloseButton()
	local rowWidth = placeButtonRow(self, rightButtons, 'TOPRIGHT')
	if rowWidth > 0 then
		width = width + Style.GAP + rowWidth
	end
	return width
end



--[[
	Frame Components
--]]


--[[ close button ]]--

local function CloseButton_OnClick(self)
	self:GetParent():GetSettings():Hide(true) --force hide the frame
end

function Frame:CreateCloseButton()
	local b = CreateFrame('Button', self:GetName() .. 'CloseButton', self, 'UIPanelCloseButton')
	b:SetScript('OnClick', CloseButton_OnClick)
	self.closeButton = b
	return b
end

function Frame:GetCloseButton()
	return self.closeButton
end

function Frame:PlaceCloseButton()
	local Style = Bagnon.Style
	local size = Style.MENU_BUTTON_SIZE

	--the stock close button texture has transparent padding; oversize it to match toolbar buttons
	local b = self:GetCloseButton() or self:CreateCloseButton()
	b:SetWidth(size + 10)
	b:SetHeight(size + 10)
	b:ClearAllPoints()
	b:SetPoint('CENTER', self, 'TOPRIGHT', -(Style.PADDING + size / 2), -(Style.PADDING + size / 2))
	b:Show()

	return size
end


--[[ search frame ]]--

function Frame:CreateSearchFrame()
	local f = Bagnon.SearchFrame:New(self:GetFrameID(), self)
	self.searchFrame = f
	return f
end

function Frame:GetSearchFrame()
	return self.searchFrame
end

function Frame:PlaceSearchFrame(leftWidth, rightWidth)
	local Style = Bagnon.Style
	local frame = self:GetSearchFrame() or self:CreateSearchFrame()

	frame:ClearAllPoints()
	frame:SetPoint('TOPLEFT', self, 'TOPLEFT', Style.PADDING + leftWidth + (leftWidth > 0 and Style.GAP or 0), -Style.PADDING)
	frame:SetPoint('TOPRIGHT', self, 'TOPRIGHT', -(Style.PADDING + rightWidth + Style.GAP), -Style.PADDING)
	frame:SetHeight(Style.MENU_BUTTON_SIZE)

	return frame:GetWidth(), frame:GetHeight()
end


--[[ search toggle ]]--

function Frame:CreateSearchToggle()
	local toggle =  Bagnon.SearchToggle:New(self:GetFrameID(), self)
	self.searchToggle = toggle
	return toggle
end

function Frame:GetSearchToggle()
	return self.searchToggle
end

function Frame:HasSearchToggle()
	return self:GetSettings():HasSearchToggle()
end


--[[ bag frame ]]--

function Frame:CreateBagFrame()
	local f =  Bagnon.BagFrame:New(self:GetFrameID(), self)
	self.bagFrame = f
	return f
end

function Frame:GetBagFrame()
	return self.bagFrame
end

function Frame:HasBagFrame()
	return self:GetSettings():HasBagFrame()
end

function Frame:IsBagFrameShown()
	return self:GetSettings():IsBagFrameShown()
end

function Frame:PlaceBagFrame(top)
	if self:HasBagFrame() then
		--the bag frame has to be created here to respond to events
		local frame = self:GetBagFrame() or self:CreateBagFrame()
		if self:IsBagFrameShown() then
			frame:ClearAllPoints()
			frame:SetPoint('TOPLEFT', self, 'TOPLEFT', Bagnon.Style.PADDING, -top)
			frame:Show()

			return frame:GetWidth(), frame:GetHeight()
		else
			frame:Hide()
			return 0, 0
		end
	end

	local frame = self:GetBagFrame()
	if frame then
		frame:Hide()
	end
	return 0, 0
end


--[[ bag toggle ]]--

function Frame:CreateBagToggle()
	local toggle = Bagnon.BagToggle:New(self:GetFrameID(), self)
	self.bagToggle = toggle
	return toggle
end

function Frame:GetBagToggle()
	return self.bagToggle
end

--this exists purely so that it can be overridden by guildBank
function Frame:HasBagToggle()
	return true
end


--[[ title frame ]]--

function Frame:CreateTitleFrame()
	local f = Bagnon.TitleFrame:New(self:GetFrameID(), self)
	self.titleFrame = f
	return f
end

function Frame:GetTitleFrame()
	return self.titleFrame
end

--returns the width the title needs
function Frame:PlaceTitleFrame(leftWidth, rightWidth)
	local Style = Bagnon.Style
	local frame = self:GetTitleFrame() or self:CreateTitleFrame()

	frame:ClearAllPoints()
	frame:SetPoint('TOPLEFT', self, 'TOPLEFT', Style.PADDING + leftWidth + (leftWidth > 0 and Style.GAP or 0), -Style.PADDING)
	frame:SetPoint('TOPRIGHT', self, 'TOPRIGHT', -(Style.PADDING + rightWidth + Style.GAP), -Style.PADDING)
	frame:SetHeight(Style.MENU_BUTTON_SIZE)
	frame:Show()

	return (frame:GetTextWidth() or 0) + Style.GAP
end


--[[ item frame ]]--

function Frame:CreateItemFrame()
	local f = Bagnon.ItemFrame:New(self:GetFrameID(), self)
	self.itemFrame = f
	return f
end

function Frame:GetItemFrame()
	return self.itemFrame
end

function Frame:PlaceItemFrame(top)
	local frame = self:GetItemFrame() or self:CreateItemFrame()

	--ItemFrame:Layout() is normally deferred to the next OnUpdate tick (so a burst of bag
	--events only lays out once); flush it here so the size read below is never stale, which
	--otherwise showed up as a wrong-sized container on first open and after toggling a bag
	if frame:NeedsLayout() then
		frame:Layout()
	end

	frame:ClearAllPoints()
	frame:SetPoint('TOPLEFT', self, 'TOPLEFT', Bagnon.Style.PADDING, -top)
	frame:Show()

	return frame:GetWidth(), frame:GetHeight()
end


--[[ player selector ]]--

function Frame:GetPlayerSelector()
	return self.playerSelector
end

function Frame:CreatePlayerSelector()
	local f = Bagnon.PlayerSelector:New(self:GetFrameID(), self)
	self.playerSelector = f
	return f
end

function Frame:HasPlayerSelector()
	return BagnonDB and true or false
end


--[[ footer: slot counter, broker display, money frame ]]--

--returns the minimum width and the height of the footer (0, 0 when empty)
function Frame:PlaceFooter()
	local Style = Bagnon.Style
	local centerY = Style.PADDING + Style.FOOTER_HEIGHT / 2
	local width = 0

	local money = self:PlaceMoneyFrame(centerY)
	local counter = self:PlaceSlotCounter(centerY)
	local broker = self:PlaceBrokerDisplayFrame(centerY, counter, money)

	if money then
		width = width + money:GetWidth()
	end
	if counter then
		width = width + counter:GetWidth() + Style.GAP * 2
	end
	if broker then
		width = width + 60
	end

	if money or counter or broker then
		return width, Style.FOOTER_HEIGHT
	end
	return 0, 0
end


--[[ money frame ]]--

function Frame:GetMoneyFrame()
	return self.moneyFrame
end

function Frame:CreateMoneyFrame()
	local f = Bagnon.MoneyFrame:New(self:GetFrameID(), self)
	self.moneyFrame = f
	return f
end

function Frame:HasMoneyFrame()
	return self:GetSettings():HasMoneyFrame()
end

function Frame:PlaceMoneyFrame(centerY)
	if self:HasMoneyFrame() then
		local frame = self:GetMoneyFrame() or self:CreateMoneyFrame()
		frame:ClearAllPoints()
		frame:SetPoint('RIGHT', self, 'BOTTOMRIGHT', MONEY_FRAME_RIGHT_PADDING - Bagnon.Style.PADDING, centerY)
		frame:Show()
		return frame
	end

	local frame = self:GetMoneyFrame()
	if frame then
		frame:Hide()
	end
end


--[[ slot counter ]]--

function Frame:GetSlotCounter()
	return self.slotCounter
end

function Frame:CreateSlotCounter()
	local f = Bagnon.SlotCounter:New(self:GetFrameID(), self)
	self.slotCounter = f
	return f
end

function Frame:HasSlotCounter()
	return self:GetSettings():HasSlotCounter()
end

function Frame:PlaceSlotCounter(centerY)
	if self:HasSlotCounter() then
		local frame = self:GetSlotCounter() or self:CreateSlotCounter()
		frame:ClearAllPoints()
		frame:SetPoint('LEFT', self, 'BOTTOMLEFT', Bagnon.Style.PADDING, centerY)
		frame:Show()
		frame:Update()
		return frame
	end

	local frame = self:GetSlotCounter()
	if frame then
		frame:Hide()
	end
end


--[[ libdatabroker display ]]--

function Frame:GetBrokerDisplay()
	return self.brokerDisplay
end

function Frame:CreateBrokerDisplay()
	local f = Bagnon.BrokerDisplay:New(1, self:GetFrameID(), self)
	self.brokerDisplay = f
	return f
end

function Frame:HasBrokerDisplay()
	return self:GetSettings():HasDBOFrame()
end

function Frame:PlaceBrokerDisplayFrame(centerY, counter, money)
	local Style = Bagnon.Style

	if self:HasBrokerDisplay() then
		local frame = self:GetBrokerDisplay() or self:CreateBrokerDisplay()
		frame:ClearAllPoints()

		if counter then
			frame:SetPoint('LEFT', counter, 'RIGHT', Style.GAP * 2, 0)
		else
			frame:SetPoint('LEFT', self, 'BOTTOMLEFT', Style.PADDING, centerY)
		end

		if money then
			--the money frame's own right padding means its LEFT edge is the visible edge
			frame:SetPoint('RIGHT', money, 'LEFT', -Style.GAP, 0)
		else
			frame:SetPoint('RIGHT', self, 'BOTTOMRIGHT', -Style.PADDING, centerY)
		end

		frame:Show()
		return frame
	end

	local frame = self:GetBrokerDisplay()
	if frame then
		frame:Hide()
	end
end


--[[ options toggle ]]--

function Frame:GetOptionsToggle()
	return self.optionsToggle
end

function Frame:CreateOptionsToggle()
	local f = Bagnon.OptionsToggle:New(self:GetFrameID(), self)
	self.optionsToggle = f
	return f
end

function Frame:HasOptionsToggle()
	local name, title, notes, enabled = GetAddOnInfo('Bagnon_Config')
	return enabled and self:GetSettings():HasOptionsToggle()
end


--[[ sort button ]]--

function Frame:GetSortButton()
	return self.sortButton
end

function Frame:CreateSortButton()
	local f = Bagnon.SortButton:New(self:GetFrameID(), self)
	self.sortButton = f
	return f
end

--only offered when BankStack is loaded, and never for cached (offline) characters
function Frame:HasSortButton()
	return self:GetSettings():HasSortButton()
		and Bagnon.SortButton:IsAvailable()
		and not Bagnon.PlayerInfo:IsCached(self:GetSettings():GetPlayerFilter())
end


--[[
	Frame Settings Access
--]]

function Frame:GetFrameID()
	return self.frameID
end

function Frame:GetSettings()
	return Bagnon.FrameSettings:Get(self:GetFrameID())
end
