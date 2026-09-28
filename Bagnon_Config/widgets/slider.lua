--[[
	slider.lua
		A bagnon options slider
--]]

local Bagnon = LibStub('AceAddon-3.0'):GetAddon('Bagnon')
local OptionsSlider = Bagnon.Classy:New('Slider')
Bagnon.OptionsSlider = OptionsSlider


--[[ Constructor ]]--

function OptionsSlider:New(name, parent, low, high, step, tooltip)
	local f = self:Bind(CreateFrame('Slider', parent:GetName() .. name, parent, 'OptionsSliderTemplate'))
	f:SetMinMaxValues(low, high)
	f:SetValueStep(step)
	f:EnableMouseWheel(true)
	f.step = step

	local label = _G[f:GetName() .. 'Text']
	label:SetText(name)
	label:SetFontObject('GameFontNormalSmall')
	label:ClearAllPoints()
	label:SetPoint('BOTTOMLEFT', f, 'TOPLEFT', 0, 2)

	--min/max labels under the ends of the track
	local lowText, highText = _G[f:GetName() .. 'Low'], _G[f:GetName() .. 'High']
	lowText:SetFontObject('GameFontDisableSmall')
	highText:SetFontObject('GameFontDisableSmall')
	f.lowText, f.highText = lowText, highText

	--the track plus the min/max labels under it; the title sits above the frame
	f.layoutHeight = 30

	local valText = f:CreateFontString(nil, 'BACKGROUND', 'GameFontHighlightSmall')
	valText:SetJustifyH('RIGHT')
	valText:SetPoint('BOTTOMRIGHT', f, 'TOPRIGHT', 0, 2)
	f.valText = valText

	f:SetScript('OnShow', f.OnShow)
	f:SetScript('OnValueChanged', f.OnValueChanged)
	f:SetScript('OnMouseWheel', f.OnMouseWheel)

	if tooltip then
		Bagnon.OptionsTooltip:Attach(f, name, tooltip)
	end

	return f
end


--[[ Frame Events ]]--

function OptionsSlider:OnShow()
	self:UpdateValue()
end

function OptionsSlider:OnValueChanged(value)
	--sliders can report values between steps while dragging; snap so saved values stay clean
	value = self:Snap(value)
	if self.updating then return end

	self:SetSavedValue(value)
	self:UpdateText(self:GetSavedValue())
end

function OptionsSlider:OnMouseWheel(direction)
	local minVal, maxVal = self:GetMinMaxValues()
	local value = self:GetValue() + self.step * direction
	self:SetValue(math.max(minVal, math.min(maxVal, value)))
end


--[[ Update Methods ]]--

function OptionsSlider:Snap(value)
	local minVal = self:GetMinMaxValues()
	return minVal + math.floor((value - minVal) / self.step + 0.5) * self.step
end

function OptionsSlider:SetSavedValue(value)
	assert(false, 'Hey, you forgot to set SetSavedValue for ' .. self:GetName())
end

function OptionsSlider:GetSavedValue()
	assert(false, 'Hey, you forgot to set GetSavedValue for ' .. self:GetName())
end

function OptionsSlider:UpdateValue()
	local value = self:GetSavedValue()

	--don't write the value back while syncing the control to the saved setting
	self.updating = true
	self:SetValue(value)
	self.updating = nil

	self:UpdateText(value)
	--narrow sliders with wordy values (frame layers) would print the ends over each other
	if self.hideRange then
		self.lowText:SetText('')
		self.highText:SetText('')
	else
		self.lowText:SetText(self:FormatValue(select(1, self:GetMinMaxValues())))
		self.highText:SetText(self:FormatValue(select(2, self:GetMinMaxValues())))
	end
end

function OptionsSlider:FormatValue(value)
	if self.GetFormattedText then
		return self:GetFormattedText(value)
	end
	return tostring(value)
end

function OptionsSlider:UpdateText(value)
	self.valText:SetText(self:FormatValue(value))
end
