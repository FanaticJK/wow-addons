--[[
	tooltip.lua
		Shared tooltip behavior for option widgets.
		Widgets call Bagnon.OptionsTooltip:Attach(widget, title, description).
--]]

local Bagnon = LibStub('AceAddon-3.0'):GetAddon('Bagnon')
local OptionsTooltip = {}
Bagnon.OptionsTooltip = OptionsTooltip

local function widget_OnEnter(self)
	if not self.tooltipTitle then return end

	GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
	Bagnon.Style:SetTooltip(GameTooltip, self.tooltipTitle, self.optionsTooltipText)
	if self.tooltipWarning then
		GameTooltip:AddLine(self.tooltipWarning, 1, 0.3, 0.25, true)
		GameTooltip:Show()
	end
end

local function widget_OnLeave(self)
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
end

--hooks rather than replaces scripts, so widget specific OnEnter handlers keep working
function OptionsTooltip:Attach(widget, title, description)
	widget.tooltipTitle = title
	widget.optionsTooltipText = description

	if not widget.hasOptionsTooltip then
		widget.hasOptionsTooltip = true
		widget:HookScript('OnEnter', widget_OnEnter)
		widget:HookScript('OnLeave', widget_OnLeave)
	end
end

--an extra red line, eg explaining why a control is disabled
function OptionsTooltip:SetWarning(widget, warning)
	widget.tooltipWarning = warning
end
