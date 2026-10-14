local GridFrame = Grid:GetModule("GridFrame")
local GridRoster = Grid:GetModule("GridRoster")
--local L = GridStatusSearings_Locales

local GridStatusSearings = Grid:GetModule("GridStatus"):NewModule("GridStatusSearings")
GridStatusSearings.menuName = "what dis do?"

local _G = _G
local UnitGUID = _G.UnitGUID
local UnitExists = _G.UnitExists

local LOC_SEARING       = "Searing Plasma" -- localize me!

local searing_ids = {
      [61295] = 9999, -- riptide debug
      [73975] = 7468, -- necrotic strike debug
      [109379] = 200000, -- 200k, 10N doubled?
      [109364] = 420000, -- 420k, 25H
      [109363] = 280000, -- 280k, 10H
      [109362] = 300000, -- 300k, 25N
      [105479] = 200000, -- 200k, 10N
}

GridStatusSearings.defaultDB = {
	debug = false,
	alert_searingplasma = {
		text =  LOC_PLAYER,
		enable = true,
		color = { r = 1, g = 1, b = 1, a = 0 },
		statuscolor = { r = 1, g = .5, b = .5, a = 0.3 },
		priority = 50,
		range = false,
	},
	color = { r=1,b=1,g=1,a=1};
}

GridStatusSearings.options = false

function GridStatusSearings:OnInitialize()
	self.super.OnInitialize(self)
  	hooksecurefunc(GridFrame, "InitializeFrame", GridStatusSearings.CreateFrames) 
	hooksecurefunc(GridFrame, "UpdateIndicator", GridStatusSearings.UpdateIndicator)
	local menu_searing = {
	   ["color"] = {
		type = "color",
		name = "Color",
		hasAlpha = true,
		get = function ()
			local color = GridStatusSearings.db.profile.alert_searingplasma.color
			return color.r, color.g, color.b, color.a
		end,
		set = function (_, r, g, b, a)
			local color = GridStatusSearings.db.profile.alert_searingplasma.color
			color.r = r
			color.g = g
			color.b = b
			color.a = a
		end,
	   },
	   ["statuscolor"] = {
		type = "color",
		name = "Status Color",
		hasAlpha = true,
		get = function ()
			local color = GridStatusSearings.db.profile.alert_searingplasma.statuscolor
			return color.r, color.g, color.b, color.a
		end,
		set = function (_, r, g, b, a)
			local color = GridStatusSearings.db.profile.alert_searingplasma.statuscolor
			color.r = r
			color.g = g
			color.b = b
			color.a = a
		end,
	   },
	}
	self:RegisterStatus("alert_searingplasma", "Searing Plasma", menu_searing, true)
end

function GridStatusSearings:OnStatusEnable(status)
	if status == "alert_searingplasma" then
		self:RegisterEvent("UNIT_AURA", "UpdateUnit")
		self:RegisterMessage("Grid_UnitJoined")
		self:UpdateAllUnits()
	end
end

function GridStatusSearings:OnStatusDisable(status)
	if not self.db.profile.alert_searingplasma.enable then
		self:UnregisterEvent("UNIT_AURA")
		self:UnregisterMessage("Grid_UnitJoined")
	end
	if status == "alert_searingplasma" then
		self.core:SendStatusLostAllUnits("alert_searingplasma")
	end
end

function GridStatusSearings:Reset()
	self.super.Reset(self)
	self:UpdateAllUnits()
end

function GridStatusSearings:Grid_UnitJoined(event, guid, unitid)
	self:UpdateUnit(event, unitid)
end

function GridStatusSearings:SetupTooltip()
        if (not self.tooltip) then
            self.tooltip = CreateFrame("GameTooltip","SearingScanningTooltip",nil,"GameTooltipTemplate");
            self.tooltip:SetOwner(UIParent, "ANCHOR_NONE")
--            for i = 1, 5 do
--                self["TooltipTextLeft" .. i] = self.tooltip:CreateFontString()
--                self["TooltipTextRight" .. i] = self.tooltip:CreateFontString()
--               self.tooltip:AddFontStrings(self["TooltipTextLeft" .. i], self["TooltipTextRight" .. i])
--            end
        end
end

function GridStatusSearings:GetAbsorbLeft(unit,index)
	if (not self.tooltip) then self:SetupTooltip(); end
	self.tooltip:SetUnitDebuff(unit,index)
--	self:Debug("Found " .. self.tooltip:NumLines())
--	for i=1,self.tooltip:NumLines(),1 do
--	    self:Debug("Line " .. i)
--	    self:Debug(_G["SearingScanningTooltipTextLeft"..i]:GetText())
--	end
	local _,_,absorb = string.find(_G["SearingScanningTooltipTextLeft2"]:GetText(),"%D(%d+)%D");
	return tonumber(absorb) or 0
end

function GridStatusSearings:FormatNumber(num)
	 if (num < 10000) then return num; end
	 return floor(num/1000) .. "K";
end

function GridStatusSearings:UpdateUnit(event, unitid)
	local guid = UnitGUID(unitid)
	if not GridRoster:IsGUIDInRaid(guid) then return end

	local settings = self.db.profile.alert_searingplasma
	if settings.enable then
	        local index = 0
		while true do
			index = index + 1
			name, _, icon, _, _, duration, expirationTime, _, _, _, spellID, _, _, _, val1,val2,val3  = UnitDebuff(unitid, index)

			if not name then
				break
			end
--function GridStatus:SendStatusGained(guid, status, 
--	   				     priority,
--					     range,
--					     color,
--					     text,
--					     value,
--					     maxValue,
--					     texture,
--					     start,
--					     duration,
--					     stack,
--					     texCoords)
			local absorbMax = searing_ids[spellID]
			if absorbMax then
				local absorb = self:GetAbsorbLeft(unitid, index);
			   	self:Debug("Found " .. name .. " with " .. absorb .. "/" .. absorbMax)
				local color = GridStatusSearings.db.profile.alert_searingplasma.color or {r=1,g=1,b=1,a=1}
				self.core:SendStatusGained(guid, "alert_searingplasma",
								 settings.priority,
								 (settings.range and 40),
								 color,
								 tostring(self:FormatNumber(absorb)),
								 absorb,
								 absorbMax,
								 icon,
								 nil,
								 nil,
								 nil,
								 { left=0.03,right=0.97,top=0.03,bottom=0.97 }
								 )
				return
				
			end
		end
		self.core:SendStatusLost(guid, "alert_searingplasma")
	end
end

function GridStatusSearings:UpdateAllUnits()
	for guid, unitid in GridRoster:IterateRoster() do
		self:UpdateUnit("UpdateAllUnits", unitid)
	end
end

function GridStatusSearings.CreateFrames(gridFrameObj, f)
	local status = CreateFrame("StatusBar",nil,f.IconBG)
	f.status = status
	status:SetOrientation("VERTICAL")
	status:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
	status:SetStatusBarColor(1,1,1,0.3)
	status:SetAllPoints();
	status:SetMinMaxValues(0,10);
	status:SetValue(0)
	status:Hide()
--	status:SetScript("OnUpdate",function(funcFrame) self:UpdateRollTime(funcFrame,oRoll); end)
--	status:Show()
end
function GridStatusSearings:UpdateIndicator(frame,indicator)
	 if (indicator == "icon") then
--	    print("Updating " .. indicator)
	    local status = GridFrame:StatusForIndicator(frame.unit, frame.unitGUID, indicator)	    
--	    if (status) then print("Updating " .. status.text); end
--	    if (status) then
--	       for k,v in pairs(status) do
--	       	   print(k)
--	       end
--	    end
	    if (status and status.maxValue) then --  and status.name == "alert_searingplasma") then
--	       if (status) then print("Updating to " .. status.value); end
	       frame.status:SetMinMaxValues(0,status.maxValue)
	       frame.status:SetValue(status.value)
	       local color = GridStatusSearings.db.profile.alert_searingplasma.statuscolor or {r=1,g=1,b=1,a=.3}
	       frame.status:SetStatusBarColor(color.r,color.g,color.b,color.a)
	       frame.status:Show()
	    else
	       frame.status:Hide()
	    end
	 end
end
