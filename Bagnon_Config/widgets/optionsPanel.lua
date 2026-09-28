--[[
	optionsPanel.lua
		A bagnon options panel, plus layout helpers shared by all panels
--]]

local Bagnon = LibStub('AceAddon-3.0'):GetAddon('Bagnon')
local OptionsPanel = Bagnon.Classy:New('Frame')
Bagnon.OptionsPanel = OptionsPanel

--the area a panel gets inside the 3.3.5 Interface Options window.  InterfaceOptionsFrame is a
--fixed 648x520 there (it only grew to 858x660 in later clients), and the panel container sits
--right of the 175px category list: 648 - 22 - 175 - 16 - 22 = 413 wide, 429 - 1 = 428 tall.
--Every panel is laid out to fit inside this box; anything placed past it spills out of the window.
OptionsPanel.WIDTH = 413
OptionsPanel.HEIGHT = 428

--panel layout metrics
OptionsPanel.LEFT = 16
OptionsPanel.RIGHT = OptionsPanel.WIDTH - 16
OptionsPanel.CONTENT_WIDTH = OptionsPanel.RIGHT - OptionsPanel.LEFT
OptionsPanel.COLUMN_2 = 226
OptionsPanel.CONTENT_TOP = 64
OptionsPanel.CHECK_HEIGHT = 26
OptionsPanel.CHECK_SIZE = 26 --InterfaceOptionsCheckButtonTemplate, the label starts right of it
OptionsPanel.SLIDER_HEIGHT = 40
OptionsPanel.SECTION_GAP = 10

function OptionsPanel:New(name, parent, title, subtitle, icon)
	local f = self:Bind(CreateFrame('Frame', name))
	f.name = title
	f.parent = parent

	local text = f:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
	text:SetPoint('TOPLEFT', 16, -16)
	if icon then
		text:SetFormattedText('|T%s:%d|t %s', icon, 32, title)
	else
		text:SetText(title)
	end
	f.titleText = text

	local subtext = f:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
	subtext:SetHeight(14)
	subtext:SetPoint('TOPLEFT', text, 'BOTTOMLEFT', 0, -6)
	subtext:SetPoint('RIGHT', f, -16, 0)
	subtext:SetJustifyH('LEFT')
	subtext:SetJustifyV('TOP')
	subtext:SetText(subtitle)
	subtext:SetTextColor(unpack(Bagnon.Style.colors.muted))
	f.subtitleText = subtext

	InterfaceOptions_AddCategory(f, 'Bagnon')

	return f
end


--[[ Layout Helpers ]]--

--remembers the box a widget occupies, so the panel can be checked for anything spilling out of it
function OptionsPanel:TrackBox(widget, x, y, width, height)
	self.boxes = self.boxes or {}
	table.insert(self.boxes, {widget = widget, x = x, y = y, width = width or 0, height = height or 0})
end

--returns a description of every tracked widget that extends past the panel, or nil if none do
function OptionsPanel:GetLayoutOverflow()
	local overflow
	for _, box in ipairs(self.boxes or {}) do
		local right, bottom = box.x + box.width, box.y + box.height
		if box.x < 0 or box.y < 0 or right > self.WIDTH or bottom > self.HEIGHT then
			overflow = overflow or {}
			local name = box.widget.GetName and box.widget:GetName() or tostring(box.widget)
			table.insert(overflow, string.format('%s (%d,%d)-(%d,%d)', name or '?', box.x, box.y, right, bottom))
		end
	end
	return overflow
end

--a gold section title with a divider line underneath.  <width> defaults to the full content width
function OptionsPanel:CreateSection(text, x, y, width)
	width = width or (self.RIGHT - x)

	local header = self:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	header:SetPoint('TOPLEFT', self, 'TOPLEFT', x, -y)
	header:SetJustifyH('LEFT')
	header:SetText(text)

	local line = Bagnon.Style:CreateDivider(self, 'ARTWORK')
	line:SetPoint('TOPLEFT', header, 'BOTTOMLEFT', 0, -3)
	line:SetWidth(width)

	self:TrackBox(header, x, y, width, 20)
	return header, y + 22
end

--places a widget at absolute panel coordinates.  Widgets whose drawn size differs from their
--frame size (a check button's label, a dropdown's margins) report it through layoutWidth/Height
function OptionsPanel:Place(widget, x, y)
	widget:ClearAllPoints()
	widget:SetPoint('TOPLEFT', self, 'TOPLEFT', x, -y)
	self:TrackBox(widget, x, y, widget.layoutWidth or widget:GetWidth(), widget.layoutHeight or widget:GetHeight())
	return widget
end

--places a widget so that its right edge sits at <right>
function OptionsPanel:PlaceRight(widget, right, y)
	return self:Place(widget, right - (widget.layoutWidth or widget:GetWidth() or 0), y)
end

--muted helper text
function OptionsPanel:CreateNote(text, x, y, width)
	width = width or (self.RIGHT - x)

	local note = self:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
	note:SetPoint('TOPLEFT', self, 'TOPLEFT', x, -y)
	note:SetWidth(width)
	note:SetJustifyH('LEFT')
	note:SetTextColor(unpack(Bagnon.Style.colors.muted))
	note:SetText(text)

	self:TrackBox(note, x, y, width, 24)
	return note
end
