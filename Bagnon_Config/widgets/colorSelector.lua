--[[
	colorSelector.lua
		A bagnon color selector
--]]

local Bagnon = LibStub('AceAddon-3.0'):GetAddon('Bagnon')
local ColorSelector = Bagnon.Classy:New('Button')
Bagnon.OptionsColorSelector = ColorSelector


--[[ Constructor ]]--

--the label wraps at <labelWidth>; by default it takes whatever width the text needs
function ColorSelector:New(name, parent, hasOpacity, tooltip, labelWidth)
	local f = self:Bind(CreateFrame('Button', parent:GetName() .. name, parent))
	f.hasOpacity = hasOpacity
	f:SetWidth(20)
	f:SetHeight(20)

	if hasOpacity then
		f.swatchFunc = function()
			local r, g, b = ColorPickerFrame:GetColorRGB()
			local a = 1 - OpacitySliderFrame:GetValue()
			f:SetColor(r, g, b, a)
		end

		f.opacityFunc = f.swatchFunc

		f.cancelFunc = function(prev)
			prev = prev or ColorPickerFrame.previousValues
			if prev then
				f:SetColor(prev.r, prev.g, prev.b, 1 - (prev.opacity or 0))
			end
		end
	else
		f.swatchFunc = function()
			f:SetColor(ColorPickerFrame:GetColorRGB())
		end
		f.cancelFunc = function()
			f:SetColor(ColorPicker_GetPreviousValues())
		end
	end

	--1px border around the swatch
	f:SetBackdrop(Bagnon.Style.flatBackdrop)
	f:SetBackdropColor(0, 0, 0, 1)
	f:SetBackdropBorderColor(unpack(Bagnon.Style.colors.buttonBorder))

	local swatch = f:CreateTexture(nil, 'OVERLAY')
	swatch:SetTexture(Bagnon.Style.TEXTURE_FLAT)
	swatch:SetPoint('TOPLEFT', 2, -2)
	swatch:SetPoint('BOTTOMRIGHT', -2, 2)
	f.swatch = swatch

	local text = f:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	text:SetPoint('LEFT', f, 'RIGHT', 6, 0)
	text:SetJustifyH('LEFT')
	text:SetText(name)

	--clamp the label so a long (or translated) name wraps instead of spilling past whatever
	--column the selector was placed in; unclamped, this was the one widget in the options
	--panels that could push its box outside the panel
	labelWidth = labelWidth or text:GetStringWidth()
	text:SetWidth(labelWidth)
	f.text = text

	--include the label in the clickable area
	f:SetHitRectInsets(0, -(math.min(text:GetStringWidth(), labelWidth) + 6), 0, 0)
	f.layoutWidth = 20 + 6 + labelWidth

	f:SetScript('OnClick', f.OnClick)
	f:SetScript('OnEnter', f.OnEnter)
	f:SetScript('OnLeave', f.OnLeave)
	f:SetScript('OnShow', f.OnShow)

	if tooltip then
		Bagnon.OptionsTooltip:Attach(f, name, tooltip)
	end

	return f
end


--[[ Frame Events ]]--

function ColorSelector:OnClick()
	if ColorPickerFrame:IsShown() then
		ColorPickerFrame:Hide()
	else
		self.r, self.g, self.b, self.opacity = self:GetColor()
		self.opacity = 1 - (self.opacity or 1) --the color picker stores transparency, not opacity

		OpenColorPicker(self)
		ColorPickerFrame:SetFrameStrata('TOOLTIP')
		ColorPickerFrame:Raise()
	end
end

function ColorSelector:OnShow()
	self:UpdateSwatch(self:GetColor())
end

function ColorSelector:OnEnter()
	local color = Bagnon.Style.colors.accent
	self:SetBackdropBorderColor(color[1], color[2], color[3], 1)
end

function ColorSelector:OnLeave()
	self:SetBackdropBorderColor(unpack(Bagnon.Style.colors.buttonBorder))
end


--[[ Update Methods ]]--

function ColorSelector:UpdateSwatch(r, g, b, a)
	self.swatch:SetVertexColor(r or 1, g or 1, b or 1, (self.hasOpacity and a) or 1)
end

function ColorSelector:SetColor(r, g, b, a)
	self:UpdateSwatch(r, g, b, a)
	self:OnSetColor(r, g, b, a)
end

function ColorSelector:OnSetColor(r, g, b, a)
	assert(false, 'Hey, you forgot to implement OnSetColor for ' .. self:GetName())
end

function ColorSelector:GetColor(r, g, b, a)
	assert(false, 'Hey, you forgot to implement GetColor for ' .. self:GetName())
end

function ColorSelector:UpdateColor()
	self:UpdateSwatch(self:GetColor())
end
