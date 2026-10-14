local me = ZygorGuidesViewer
if not me then return end

local L = ZygorGuidesViewer.L

local Astrolabe

function me:getXY(id)
	self:Debug("getXY "..id)
	return (id % 10001)/10000, math.floor(id / 10001)/10000
end

function me:AutodetectWaypointAddon()
	self.autodetectingwaypointaddon = true
	self:Print(L["waypointaddon_detecting"])
	if Cartographer_Notes and Cartographer_Waypoints then
		self:SetWaypointAddon("cart2")
	elseif TomTom then
		self:SetWaypointAddon("tomtom")
	elseif self.Pointer.ready then
		self:SetWaypointAddon("internal")
	else
		self:Print(L["waypointaddon_notdetected"])
	end
end

function me:GetWaypointAddon()
	return self.db.profile.waypointaddon
end

function me:SetWaypointAddon(info,value)
	if not value then value=info end
	value=value:gsub("[0-9]-_","")
	self:Debug("Setting waypoint: "..value)
	if value~="none" and not self:IsWaypointAddonReady(value) then
		local msg = {
			["cart2"]="Cartographer2 not found.",
			["cart3"]="Cartographer3 not found.",
			["tomtom"]="TomTom not found.",
			["metamap"]="MetaMap not found.",
			["internal"]="Internal waypointer not available."
		}
		self:Print(msg[value])
		return
	end
	if (value~=self.db.profile.waypointaddon) then
		self:UnsetWaypointAddon()
	end
	self.db.profile.waypointaddon = value
	self.iconsregistered = false
	self.iconregistryretries = 0
	self:Print(L["waypointaddon_set"]:format(self.optionsmap.args.waypoints.values[value]))

	self.SetWaypoint = self.SetWaypointFunctions[value]

	self:SetWaypoint()
--[[
	if (self.db.profile.waypointaddon=="none") then
		self.optionsmap.args.minicons.disabled = true
	else
		self.optionsmap.args.minicons.disabled = false
	end
	LibStub("AceConfigRegistry-3.0"):NotifyChange("ZygorGuidesViewer")
]]--
end

me.SetWaypointFunctions = {
	['tomtom'] = function (self,goalnumORx,y,title)
		self:Debug("placing TomTom waypoint")

		self:ClearTomTomWaypoints()

		if y then
			self:CreateTomTomWaypointXY(goalnumORx,y,title)
		else
			self:CreateTomTomWaypoints(goalnumORx)
		end
	end,
	['cart2'] = function (self,goalnumORx,y,title)
		self:Debug("Setting waypoint")
		--self:Debug(self.CurrentStep.mapnote)
	--[[		
		if self.oldnote then
			Cartographer_Notes:DeleteNote(self.oldzone,self.oldnote)
		end
	--]]
		self:ClearCartographerWaypoints()

		if y then
			self:CreateCartographerWaypointXY(goalnumORx,y,title)
		else
			self:CreateCartographerWaypoints(goalnumORx)
		end

		--[[
		local queue = Cartographer_Waypoints.Queue
		for i,v in ipairs(queue) do
			if v and v.Db=="ZygorGuides" then
				table.remove(queue,i)
			end
		end
		--]]

		--local note = Cartographer_Notes:SetNote(zone,x/100,y/100,"Circle","ZygorGuidesViewer",'manual',true,'title',)
	--		if mapnote and mapzone and Cartographer_Notes.externalDBs then
	--			Cartographer_Waypoints:SetNoteAsWaypoint(mapzone,mapnote)
	--		end
	--		self.oldzone = zone
	end,
	['internal'] = function (self,goalnumORx,y,title)
		self.Pointer:ClearWaypoints()
		if not y then
			local goals={}
			local points={}
			if goalnumORx then goals={self.CurrentStep.goals[goalnumORx]} else for i=1,#self.CurrentStep.goals do if self.CurrentStep.goals[i].x then table.insert(goals,self.CurrentStep.goals[i]) end end end
			for k,goal in ipairs(goals) do
				if not goal.force_noway then
					local way = self.Pointer:SetWaypoint (goal.map,goal.x,goal.y,title or self.CurrentStep:GetTitle() or (goal.map and goal.x and ("%s %d,%d"):format(goal.map,goal.x,goal.y)) or L['waypoint_step']:format(self.CurrentStepNum))
					if way then
						table.insert(points,way)
					else
						self:Print("Unable to create waypoint: "..tostring(goal.map).." "..tostring(goal.x).." "..tostring(goal.y))
					end
				end
			end
			if points[1] then
				self.Pointer:ShowArrow (points[1])
			end
		else
			self.Pointer:SetWaypoint (nil,goalnumORx,y,title)
		end
	end,
	['none'] = function (self)
		self:Debug("No waypointing addon connected.")
	end
}

function me:SetWaypoint(...)
	if not self:IsWaypointAddonReady() then
		self:Print("Waypoint addon '"..self.db.profile.waypointaddon.."' failed.")
		return
	end
	self.SetWaypointFunctions[self.db.profile.waypointaddon](self,...)
end

function me:UnsetWaypointAddon()
	if not self.db.profile.waypointaddon or self.db.profile.waypointaddon=="none" then return end

	self:Print("Unsetting waypoint addon: "..tostring(self.db.profile.waypointaddon))
	
	if not self:IsWaypointAddonEnabled() then
		self:Debug("Not enabled, out.")
		return
	end --nothing to do here, move along
	local value = self.db.profile.waypointaddon
	if (value=="cart2") then
		self:Print("Disconnecting Cartographer2...")
		self:ClearCartographerWaypoints()
		if Cartographer_Notes.externalDBs["ZygorGuidesViewer"] then Cartographer_Notes:UnregisterNotesDatabase("ZygorGuidesViewer") end
	elseif value=="cart3" then
		if Cartographer3 and Cartographer3.db then
			self:Print("Cartographer3 disconnected.")
		else
			self:Print("Cartographer3 not connected.")
		end
	elseif value=="tomtom" then
		if TomTom and TomTom.defaults then
			StaticPopupDialogs["TOMTOM_REMOVE_ALL_CONFIRM"]:OnAccept()
			TomTomCrazyArrow:Hide()
			self:Print("TomTom disconnected.")
		else
			self:Print("TomTom not connected.")
		end
	elseif value=="metamap" then
		self:Print("MetaMap not connected.")
	elseif value=="internal" then
		self.Pointer:ClearWaypoints()
		self:Print("Internal waypointer disconnected.")
	elseif value=="none" then
	else
		self:Debug("UnsetWaypointAddon: WTF?")
	end
end



function me:IsWaypointAddonReady(addon)
	if not addon then addon = self.db.profile.waypointaddon end
	if addon=="cart2" then
		return (Cartographer_Notes and Cartographer_Notes:IsActive() and Cartographer_Notes.externalDBs) and true or false
	elseif addon=="cart3" then
		return (Cartographer3 and Cartographer3.db)
	elseif addon=="tomtom" then
		return (TomTom and TomTom.defaults)
	elseif addon=="metamap" then
		return false
	elseif addon=="internal" then
		return self.Pointer.ready
	else
		return true
	end
end

function me:IsWaypointAddonEnabled(addon)
	if not addon then addon = self.db.profile.waypointaddon end
	return self.db.profile.waypointaddon==addon and self:IsWaypointAddonReady(addon) and self.iconsregistered
end

function me:RegisterNotes()
	if not self.CurrentStep then return end
	-- use for pre-registering. Cartographer needs that, while TomTom does not.
	
	-- retrying 3 times
	if self.iconsregistered then return end
	if not self.iconregistryretries then self.iconregistryretries=0 end
	if self.iconregistryretries==3 then
		self:Print(L["waypointaddon_fail"]:format(self.optionsmap.args.waypoints.values[self.db.profile.waypointaddon]))
		if not self.autodetectingwaypointaddon then
			self:AutodetectWaypointAddon()
		end

	end
	if self.iconregistryretries>3 then return end
	self.iconregistryretries = self.iconregistryretries + 1

	if not self:IsWaypointAddonReady() then return end

	self:Print(L["waypointaddon_connecting"]:format(self.optionsmap.args.waypoints.values[self.db.profile.waypointaddon]))

	if self.db.profile.waypointaddon=="tomtom" then
		--[[
		if not self.db.profile.filternotes then
			self:Print("Creating all waypoints for TomTom. This may take a while.")
			local contid,zoneid
			for zone in pairs(self.MapNotes) do
				local zoneTr = BZL[zone]
				contid,zoneid = self:GetMapZoneNumbers(zoneTr)
				self:Debug("contid="..ns(contid).." zoneid="..ns(zoneid).." for "..ns(zoneTr))
				if contid and zoneid and (type(self.MapNotes[zone])=="table") then
					if (TomTom:GetMapFile(contid,zoneid)) then
						for note,mapnote in pairs(self.MapNotes[zone]) do
							x,y = self:getXY(note)
							--self:Debug("x="..ns(x).." y="..ns(y))
							if x and y then
								--self:Debug(GetCurrentMapContinent().." "..ns(note).." "..ns(zone).." x"..ns(x).." y"..tostring(y))
								self.TomTomWaypoints[#self.TomTomWaypoints+1] = TomTom:AddZWaypoint(
									contid,zoneid,x*100,y*100,
									self.MapNotes[zone][note].title, --desc
									false, --persistent
									true, true, --minimap,world
									nil,true, --callbacks,silent
									(zone==self.CurrentStep.mapzone and note==self.CurrentStep.mapnote) --arrow
								)
							end
						end
					else
						self:Print("No map data for continent id "..ns(contid)..", zone id "..ns(zoneid)..", zone "..ns(zone)..", please report.")
					end
				end
			end
		end
		--]]
	elseif self.db.profile.waypointaddon=="cart2" then
		--[[
		self:Debug("registering database "..#self.MapNotes)
		Cartographer_Notes:RegisterNotesDatabase('ZygorGuides', self.MapNotes, self)
		self:Debug("registered database")

		self:Debug("registering icons")
		if not self.iconsregistered then
			for k,v in pairs(self.icons) do
				Cartographer_Notes:RegisterIcon(k, v)
			end
		end
		--]]
	elseif self.db.profile.waypointaddon=="internal" then
	end

	self:Print(L["waypointaddon_connected"]:format(self.optionsmap.args.waypoints.values[self.db.profile.waypointaddon]))
	self:Debug("registered icons")
	self.iconsregistered = true
	self.iconregistryretries = 0

	self:SetWaypoint()
end





-- icon handlers:

function me:GetNoteScaling(zone,id,data)
	return self.db.profile.iconScale
end

function me:IsNoteHidden(zone,id,data)
	return self.db.profile.filternotes and (not self.CurrentStep or not self.CurrentStep.mapnote or (id~=self.CurrentStep.mapnote) or (zone~=self.CurrentStep.mapzone))
end

function me:IsMiniNoteHidden(zone,id,data)
	return not self.db.profile.minicons or (self.db.profile.filternotes and ((id~=self.CurrentStep.mapnote) or (zone~=self.CurrentStep.mapzone)))
end

function me:GetNoteTransparency(zone,id,data)
	return self.db.profile.iconAlpha
end

function me:GetNoteIcon(zone,id,data)
--	return (not self.db.profile.filternotes and self.CurrentStep and (id==self.CurrentStep.mapnote) and (zone==self.CurrentStep.mapzone)) and "hilite" or data.icon
	return (self.CurrentStep and (id==self.CurrentStep.mapnote) and (zone==self.CurrentStep.mapzone)) and (data.icon=="Square" and "hilitesquare" or "hilite") or data.icon
end



-------------------------- Cartographer stuff

function me:ClearCartographerWaypoints()
	if Cartographer_Waypoints then
		for i,v in ipairs(Cartographer_Waypoints.Queue) do
			v:Cancel()
			Cartographer_Waypoints.Queue[i]=nil
		end
	end
	if Cartographer_Notes and Cartographer_Notes.externalDBs["ZygorGuidesViewer"] then
		Cartographer_Notes:UnregisterNotesDatabase("ZygorGuidesViewer")
	end
end

function me:CreateCartographerWaypoints(goalnum)
	local x,y,zone

	local db = {version=3}

	local waypoints = {}

	-- set mapnotes for all the coordinates found in step lines
	-- REVERSE direction to create proper waypoint queue
	for i=#self.CurrentStep.goals,1,-1 do
		local g = self.CurrentStep.goals[i]
		if g.x and not g.force_noway then
			zone = g.map
			if zone then
				if self.BZR[zone] then zone = self.BZR[zone] end
				local note = Cartographer_Notes.getID(g.x/100,g.y/100)
				if not db[zone] then db[zone]={} end
				db[zone][note]={icon="Circle",title=g.title or self.CurrentStep.title or g.autotitle or self.CurrentStep:GetTitle() or L['waypoint_step']:format(self.CurrentStepNum)}

				if (i==goalnum) or not goalnum then
					table.insert(waypoints,{zone=zone,note=note})
				end
			end
		end
	end

	Cartographer_Notes:RegisterNotesDatabase("ZygorGuidesViewer",db)

	for i,way in ipairs(waypoints) do
		Cartographer_Waypoints:SetNoteAsWaypoint(way.zone,way.note)
	end

	Cartographer_Notes:MINIMAP_UPDATE_ZOOM()
end

function me:CreateCartographerWaypointXY(x,y,title)
	local zone = select(GetCurrentMapZone(), GetMapZones(GetCurrentMapContinent())) -- likely fails in Scarlet Enclave
	Cartographer_Waypoints:AddWaypoint(NotePoint:new(zone, x, y, title or "Waypoint"))
end


function me:UpdateCartographerExport()
	if ((self.db.profile.waypointaddon~="cart2") and (self.db.profile.waypointaddon~="cart3")) or (not self.iconsregistered) then return end

	Cartographer_Notes:MINIMAP_UPDATE_ZOOM()
	Cartographer_Notes:UpdateMinimapIcons()
	Cartographer_Notes:RefreshMap()
end



-------------------------- TomTom stuff


function me:ClearTomTomWaypoints()
	--self:Debug("Clearing TomTom waypoints:")
	for i,p in ipairs(self.TomTomWaypoints) do
		--self:Debug(p)
		TomTom:RemoveWaypoint(p)
	end
	self.TomTomWaypoints = {}
end

function me:CreateTomTomWaypoints(goalnum)
	--if not Astrolabe.ContinentList[101] then Astrolabe.ContinentList[101] = {[1]="ScarletEnclave"} end
	
	TomTom.profile.persistence.cleardistance = 0
--	if self.CurrentStep.mapnote then

	local x,y,zone

	for i=#self.CurrentStep.goals,1,-1 do
		local goal = self.CurrentStep.goals[i]
		if goal.x and not goal.force_noway then
			local contid,zoneid
			contid,zoneid = self:GetMapZoneNumbers(goal.map)  -- localized already on load
			--self:Print("contid:"..(contid or 'nil').." zoneid:"..(zoneid or 'nil'))
			local way = TomTom:AddZWaypoint(
				contid, zoneid,
				goal.x, goal.y,
				goal.title or self.CurrentStep.title or goal.autotitle or self.CurrentStep:GetTitle() or "Step "..self.CurrentStepNum,
				false, --persistent
				true, --minimap
				true, --world
				nil, --custom_callbacks
				true, --silent
				(i==goalnum or not goalnum) --arrow
			)
			--self:Debug("added to TomTom as:"..(way or 'nil'))
			if way then table.insert(self.TomTomWaypoints, way) end
		end

	end

end

function me:CreateTomTomWaypointXY(x,y,title)
	local contid,zoneid = self:GetMapZoneNumbers(GetRealZoneText())
	self:Debug(x..' '..y)
	local way = TomTom:AddZWaypoint(
		contid, zoneid,
		x, y,
		title or self.CurrentStep.title or "Step "..self.CurrentStepNum,
		false, --persistent
		true, --minimap
		true, --world
		nil, --custom_callbacks
		true, --silent
		true --arrow
	)
	if way then table.insert(self.TomTomWaypoints, way) end
end

local MapZoneCache={}
local cached
function me:GetMapZoneNumbers(zonename)
	if zonename==self.BZL["Plaguelands: The Scarlet Enclave"] then return 5,1 end
	cached = MapZoneCache[zonename]
	if cached then return unpack(cached) end
	for cont in pairs{GetMapContinents()} do
		for zone,name in pairs{GetMapZones(cont)} do
			if name==zonename then
				MapZoneCache[zonename]={cont,zone}
				return cont,zone
			end
		end
	end
	return 0
end

-- only for TomTom support, Astrolabe bundled
function me:GetMapZoneFile(zonename)
	Astrolabe = DongleStub("Astrolabe-0.4")
	for cont in pairs{GetMapContinents()} do
		for zone,name in pairs{GetMapZones(cont)} do
			if name==zonename then
				return Astrolabe.ContinentList[cont][zone]
			end
		end
	end
	return ""
end

--EVIL STUFF. Hacking the ORIGINAL GetMapContinents(). This is bad, bad, bad - but Blizzard broke the rules by creating an off-world zone first... ;P
--[[
local continentlist = { GetMapContinents() }
table.insert(continentlist,ZygorGuidesViewer.BZL["Plaguelands: The Scarlet Enclave"])
function GetMapContinents()
	return unpack(continentlist)
end
local _GetMapZones = GetMapZones
function GetMapZones(cont)
	if cont<5 then
		return _GetMapZones(cont)
	else
		return ZygorGuidesViewer.BZL["Plaguelands: The Scarlet Enclave"]
	end
end
--]]