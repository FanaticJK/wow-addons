assert (ZygorGuidesViewer,"Zygor Guides Viewer not loaded properly!")

local ZGV=ZygorGuidesViewer
local Pointer = {}
ZGV.Pointer = Pointer

local _G,assert,table,string,tinsert,tonumber,tostring,type,ipairs,pairs,setmetatable,math = _G,assert,table,string,tinsert,tonumber,tostring,type,ipairs,pairs,setmetatable,math

Pointer.Debug = ZGV.Debug

Pointer.Waypoints = {}


local scarlet_cont = 5
local scarlet_zone = 1


local Astrolabe = DongleStub("Astrolabe-0.4-Zygor")

local unusedMarkers = {}


local eta_throttle=0
local last_distance=0
local speed=0
local last_speed=0

local initialdist=nil

local lastminimapdist=99999
local minimapcontrol_suspension=0
local minimap_lastset = 0

function Pointer:Startup()
	self:CreateArrowFrame()

	ZGV.db.profile.arrowsmooth = true

	--[[
	self.EventFrame = CreateFrame("FRAME")
	self.EventFrame:Show()
	self.EventFrame:SetScript("OnEvent",PointerEventFrame_OnEvent)
	self.EventFrame:RegisterEvent("WORLD_MAP_UPDATE")
	--]]

	local overlay = CreateFrame("FRAME",nil,WorldMapDetailFrame)
	self.OverlayFrame = overlay
	overlay:SetAllPoints(true)
	overlay:SetWidth(1002)
	overlay:SetHeight(668)
	overlay:SetFrameStrata("DIALOG")

	--WorldMapFrame.PlayerCoord = WorldMapFrame:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall")
	--WorldMapFrame.CursorCoord = WorldMapFrame:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall")
	
	--WorldMapFrame.PlayerCoord:SetText("Player")
	--WorldMapFrame.CursorCoord:SetText("Cursor")

	--ZGV.ScheduleRepeatingTimer(self,"FixMapLevel", 1.0)

	Pointer.ready = true

	self:HandleCamRegistration()
end

local is_moving=false
function Pointer:HandleCamRegistration()
	local LibCamera = LibStub:GetLibrary("LibCamera-1.0")
	if not LibCamera then ZGV.db.profile.arrowcam = false return end
	if ZGV.db.profile.arrowcam then
		local CallbackHandler = LibStub:GetLibrary("CallbackHandler-1.0")
		if not CallbackHandler then ZGV.db.profile.arrowcam = false end
		if not self.callbacks then
			self.callbacks = CallbackHandler:New(self)
		end
		LibCamera.RegisterCallback(self,"LibCamera_Update")
		--[[
		hooksecurefunc("TurnOrActionStart",function() is_moving=true print("toastart") end)
		hooksecurefunc("TurnOrActionStop",function() is_moving=false print("toastop") end)
		hooksecurefunc("CameraOrSelectOrMoveStart",function() is_moving=true print("cosomstart") end)
		hooksecurefunc("CameraOrSelectOrMoveStop",function() is_moving=false print("cosomstop") end)
		hooksecurefunc("MoveForwardStart",function() is_moving=true print("mfstart") end)
		hooksecurefunc("MoveForwardStop",function() is_moving=false print("mfstop") end)
		hooksecurefunc("MoveAndSteerStart",function() is_moving=true print("masstart") end)
		hooksecurefunc("MoveAndSteerStop",function() is_moving=false print("masstop") end)
		--]]
	else
		LibCamera.UnregisterCallback(self,"LibCamera_Update")
	end
end

local cam_yaw=0
function Pointer:LibCamera_Update(target,p,y,d)
	cam_yaw=y
	--print (p.." "..y.." "..d)
end



--[[
local numlevels=0
local oldlevel=1
function Pointer.FixMapLevel()
	local x,y = GetPlayerMapPosition("player")
	if x<=0 and y<=0 then
		-- perhaps wrong floor indeed.
		numlevels = GetNumDungeonMapLevels()
		if numlevels>1 then
			oldlevel = GetCurrentMapDungeonLevel()
			for lev=1,numlevels do
				if lev~=oldlevel and GetPlayerMapPosition("player")>0 then
					GetCurrentMapDungeonLevel()
			end
		end
end
--]]

-- Calling conventions:
--  cont,zone,x,y,[title]
--  zonename(localized),x,y,[title]
--  x,y,[title]
function Pointer:SetWaypoint (c,z,x,y,title)
	ZGV:Debug("Internal SetWaypoint: "..tostring(c).." "..tostring(z).." "..tostring(x).." "..tostring(y).." "..tostring(title))
	if not c and z and x then
		c,z,x,y,title = z,x,y,title,nil
	end
	if type(c)=="string" then
		x,y,title = z,x,y
		c,z = ZGV:GetMapZoneNumbers(c)
	end
	if type(x)=="string" then
		x,y,title = c,z,x
		c,z = GetCurrentMapContinentAndZone()
	end
	ZGV:Debug("Internal SetWaypoint: "..tostring(c).." "..tostring(z).." "..tostring(x).." "..tostring(y).." "..tostring(title))

	--[[
	if c==-1 and z==0 and GetMapInfo()=="ScarletEnclave" then
		c,z = scarlet_cont,scarlet_zone
	end
	--]]

	if not c or not z or c < 1 or not x or not y then
		--ZGV:Print("Invalid zone, or what?")
		return
	end

	if x>1 or y>1 then
		x=x/100
		y=y/100
	end

	local desc
	if not desc then desc="" end

	local waypoint = self:GetMarker()
	table.zygor_join(waypoint,{ c=c,z=z,x=x,y=y,t=title })
	-- TODO: add callbacks for distance detection

	waypoint.minimapFrame.waypoint = waypoint
	waypoint.worldmapFrame.waypoint = waypoint

	waypoint.minimapFrame:EnableMouse(true)
	waypoint.worldmapFrame:EnableMouse(true)

	Astrolabe:PlaceIconOnWorldMap(self.OverlayFrame, waypoint.worldmapFrame, c, z, x, y)
	Astrolabe:PlaceIconOnMinimap(waypoint.minimapFrame, c, z, x, y)
	Pointer.MinimapButton_OnUpdate(waypoint.minimapFrame,1000)

	last_distance=0
	speed=0

	self:ShowArrow(waypoint)


	table.insert(self.Waypoints,waypoint)

	return waypoint
end

function Pointer:ClearWaypoints ()
	for w,way in pairs(self.Waypoints) do
		self:RemoveWaypoint(way)
	end
	table.wipe(self.Waypoints)
	self:HideArrow()
end

function Pointer:RemoveWaypoint(waypoint)
	Astrolabe:RemoveIconFromMinimap(waypoint.minimapFrame)
	waypoint.minimapFrame:Hide()
	waypoint.minimapFrame.waypoint=nil
	waypoint.worldmapFrame:Hide()
	waypoint.worldmapFrame.waypoint=nil

	table.insert(unusedMarkers, waypoint)
end

function Pointer:HideArrow()
	self.ArrowFrame.waypoint = nil
	self:ResetMinimapZoom() -- to perhaps reset the zoom
	--self.ArrowFrame:Hide()
end

function Pointer:ShowArrow(waypoint)
	self.ArrowFrame.waypoint = waypoint
	initialdist = nil
	lastminimapdist=99999

	--self.ArrowFrame.temporarilyhidden = true
	--self.ArrowFrame:Show()
end

function Pointer:GetWaypointBearings(way)
	--local dx,dy = 
	if type(way)=="number" then way=self.Waypoints[way] end

end


function Pointer:GetMarker()
	local marker = table.remove(unusedMarkers)
	if marker then return marker end

	-- create a new marker
	marker = {}

	marker.minimapFrame = CreateFrame("Button", nil, Minimap, "ZygorGuidesViewerPointerMinimapMarker")
	marker.worldmapFrame = CreateFrame("Button", nil, self.OverlayFrame, "ZygorGuidesViewerPointerWorldMapMarker")

	return marker
end

-----------------------------------------------------------------------
--[[
do
	local lastx,lasty
	local x,y,zone
	function Pointer:GetPlayerPosition()
		local x,y = GetPlayerMapPosition("player")
	end
end

function Pointer:GetDistFromPlayer(c,z,x,y)
	local pc,pz,px,py

	local px, py = GetPlayerMapPosition("player")
	px, py, pzone = self:GetCurrentPlayerPosition()
	if pzone then
		pzone = BZL[pzone]
	end

	if px == 0 or py == 0 or not px or not py then
		return nil
	end
	if pzone and BZH[pzone] then
		pzone = BZL[pzone]
	end
	if zone and BZH[zone] then
		zone = BZL[zone]
	end
	if not zone then
		zone = GetRealZoneText()
	end
	if not pzone then
		pzone = zone
	end
	local dist = Tourist:GetYardDistance(zone, x, y, pzone, px, py)
	return dist
end
--]]


-- Code taken from HandyNotes, thanks Xinhuan
---------------------------------------------------------
-- Public functions for plugins to convert between MapFile <-> C,Z
--

--[[
local continentMapFile = {
	[WORLDMAP_COSMIC_ID] = "Cosmic", -- That constant is -1
	[0] = "World",
	[1] = "Kalimdor",
	[2] = "Azeroth",
	[3] = "Expansion01",
	[scarlet_cont] = "ScarletEnclave",
}
local reverseMapFileC = {}
local reverseMapFileZ = {}
for C in pairs(Astrolabe.ContinentList) do
	for Z = 1, #Astrolabe.ContinentList[C] do
		local mapFile = Astrolabe.ContinentList[C][Z]
		reverseMapFileC[mapFile] = C
		reverseMapFileZ[mapFile] = Z
	end
end
for C = -1, 3 do
	local mapFile = continentMapFile[C]
	reverseMapFileC[mapFile] = C
	reverseMapFileZ[mapFile] = 0
end
--]]

--[[
function Pointer:GetMapFile(C, Z)
	if type(C)=="string" then return end
	if not C or not Z then return end
	if Z == 0 then
		return continentMapFile[C]
	elseif C > 0 then
		return Astrolabe.ContinentList[C][Z]
	end
end
function Pointer:GetCZ(mapFile)
	return reverseMapFileC[mapFile], reverseMapFileZ[mapFile]
end
--]]

---------------
function Pointer:CreateArrowFrame()
	self.ArrowFrame = CreateFrame("Frame","ZygorGuidesViewerPointerArrowFrame",UIParent,"ZygorGuidesViewerFloatingArrow")

	local tex = self.ArrowFrame.arrow:GetTexture()
	self.ArrowFrame.arrow:SetTexture(true)
	self.ArrowFrame.arrow:SetTexture(tex,false)
	self.ArrowFrame:Hide()

	self.ArrowFrameCtrl = CreateFrame("Frame",nil,UIParent,nil)
	self.ArrowFrameCtrl:SetScript("OnUpdate",self.ArrowFrameControl_OnUpdate)
	self.ArrowFrameCtrl:Show()

	self:SetupArrowFreeze()
	self:SetScale(ZGV.db.profile.arrowscale)
end

function Pointer:SetupArrowFreeze()
	self.ArrowFrame:EnableMouse(not ZGV.db.profile.arrowfreeze)
	self.ArrowFrame:RegisterForDrag(not ZGV.db.profile.arrowfreeze and "LeftButton")
end

function Pointer:UpdateWaypoints()
	-- worldmap updates only, so far
	for w,way in pairs(self.Waypoints) do
		Astrolabe:PlaceIconOnWorldMap(WorldMapFrame, way.worldmapFrame, way.c, way.z, way.x, way.y )
	end
end

function Pointer:SetScale(scale)
	self.ArrowFrame:SetScale(scale)
	self.ArrowFrame:SetScale(scale)
	self.ArrowFrame:SetScale(scale)
	self.ArrowFrame:SetScale(scale)
end

function Pointer:SetFontSize(size)
	local f=self.ArrowFrame.title:GetFont()
	self.ArrowFrame.title:SetFont(f,size)
	--[[
	self.ArrowFrame.dist:SetFont(f,size)
	self.ArrowFrame.eta:SetFont(f,size)

	self.ArrowFrame.title:SetHeight(size)
	self.ArrowFrame.dist:SetHeight(size)
	self.ArrowFrame.eta:SetHeight(size)
	--]]
end


function GetCurrentMapContinentAndZone()
	local c,z = GetCurrentMapContinent(), GetCurrentMapZone()
	if c==-1 and z==0 and GetMapInfo()=="ScarletEnclave" then c,z=5,1 end
	return c,z
end


function Pointer:MinimapZoomChanged()
	if ZGV.db.profile.minimapzoom then
		--minimapcontrolled = true
	else
		--minimapcontrolled = false
		Minimap:SetZoom(0)
		MinimapZoomOut:Disable()
		MinimapZoomIn:Enable()
	end
end

function Pointer:ResetMinimapZoom()
	Minimap:SetZoom(0)
	MinimapZoomOut:Disable()
	MinimapZoomIn:Enable()
	--minimap_lastset = 0
end

function Pointer.MinimapButton_OnEnter(self,arg)
	if self.waypoint then
		-- Parent to UIParent, unless it's hidden

		--[[
		if UIParent:IsVisible() then
			GameTooltip:SetParent(UIParent)
		else
			GameTooltip:SetParent(self)
		end
		--]]

		GameTooltip:SetOwner(self,"ANCHOR_BOTTOM")
		GameTooltip:SetText(self.waypoint.t)

		GameTooltip:Show()
	end
end

function Pointer.MinimapButton_OnLeave(button)
	GameTooltip:Hide()
end


function Pointer.MinimapButton_OnUpdate(self,elapsed)
	local c = self.minimap_count
	if not c then c=0 end
	c = c + elapsed
	if c < 0.1 then
		self.minimap_count = c
		return
	end
	elapsed = c
	self.minimap_count = 0

	if not ZGV.db.profile.minicons then self.icon:Hide() self.arrow:Hide() return end

	local dist,x,y = Astrolabe:GetDistanceToIcon(self)

	if not dist or IsInInstance() then self.icon:Hide() self.arrow:Hide() return end

	local edge = Astrolabe:IsIconOnEdge(self)

	if edge then
		self.icon:Hide()
		self.arrow:Show()

		local angle = Astrolabe:GetDirectionToIcon(self)
		angle = angle + 2.356194  -- rad(135)

		if GetCVar("rotateMinimap") == "1" then
			angle = angle - GetPlayerFacing()
		end

		local sin,cos = math.sin(angle)*0.71, math.cos(angle) * 0.71
		self.arrow:SetTexCoord(0.5-sin, 0.5+cos, 0.5+cos, 0.5+sin, 0.5-cos, 0.5-sin, 0.5+sin, 0.5-cos)
	else
		self.icon:Show()
		self.arrow:Hide()
	end

	-- are we pointed to?
	local Minimap = Minimap

	-- minimap autozoom
	if Pointer.ArrowFrame.waypoint==self.waypoint and ZGV.db.profile.minimapzoom then
		local getzoom = Minimap:GetZoom()
		if getzoom~=minimap_lastset then
			-- user playing with minimap; suspend our activities for a while
			minimapcontrol_suspension = 5.0
			minimap_lastset = getzoom
		end

		if minimapcontrol_suspension>0 then
			minimapcontrol_suspension = minimapcontrol_suspension - elapsed
		else
			local dist = dist*2
			if dist~=lastminimapdist then
				local mapsizes = MinimapSize[Astrolabe.minimapOutside and 'outdoor' or 'indoor']

				minimap_lastset=0
				for i=1,Minimap:GetZoomLevels()-1 do
					if dist<mapsizes[i]*0.7 then minimap_lastset=i end
				end
				-- sanitise buttons
				if(minimap_lastset == (Minimap:GetZoomLevels() - 1)) then MinimapZoomIn:Disable() else MinimapZoomIn:Enable() end
				if(minimap_lastset == 0) then MinimapZoomOut:Disable() else MinimapZoomOut:Enable() end

				Minimap:SetZoom(minimap_lastset) 
				
			end
			lastminimapdist=dist
		end
	end
end

function Pointer.MinimapButton_OnClick(self,button)
	ZGV.Pointer:ShowArrow(self.waypoint)
end

function Pointer.MinimapButton_OnEvent(self,event,...)
	if not self.waypoint then self:Hide() return end
	if event == "PLAYER_ENTERING_WORLD" then
		local way = self.waypoint
		if way and ZGV.db.profile.minicons then Astrolabe:PlaceIconOnMinimap(self, way.c, way.z, way.x, way.y) end
	end
end

function Pointer.WorldMapButton_OnEvent(self,event,...)
	if not self.waypoint then self:Hide() return end
	if event == "WORLD_MAP_UPDATE" then
		local x,y = Astrolabe:PlaceIconOnWorldMap(ZGV.Pointer.OverlayFrame, self, self.waypoint.c, self.waypoint.z, self.waypoint.x, self.waypoint.y)
		if (x and y and (0 < x and x <= 1) and (0 < y and y <= 1)) then
			self:Show()
		else
			self:Hide()
		end
	end
end


------------------------------------------- ARROW -----------------


--[[
function Pointer.ArrowFrame_OnEvent(self,event,...)
	if event=="WORLD_MAP_UPDATE" then
		ZGV.Pointer:UpdateWaypoints()
	end
end
--]]


local arrowctrl_throttle=0

local oldangle = 0

function Pointer.ArrowFrameControl_OnUpdate(self,elapsed)
	arrowctrl_throttle = arrowctrl_throttle + elapsed
	if arrowctrl_throttle < 0.05 then return end
	elapsed = arrowctrl_throttle
	arrowctrl_throttle = 0

	Pointer.ArrowFrame_OnUpdate(Pointer.ArrowFrame,elapsed)
end

-- And we have an onupdating frame even if hidden. Yay!

local title,disttxt,etatxt

local speeds={}
local avg=0
local stop=0

local etadisp_throttle=0

function Pointer.ArrowFrame_OnUpdate(self,elapsed)

	--[[
	arrow_throttle = arrow_throttle + elapsed
	if arrow_throttle < 0.05 then return end
	elapsed = arrow_throttle
	arrow_throttle = 0
	--]]

	if not self.waypoint then self:Hide() return end
	if ZGV.db.profile.hidearrowwithguide and not ZGV.Frame:IsVisible() then self:Hide() return end
	if GetCurrentMapContinentAndZone()~=self.waypoint.c then self:Hide() return end

	local dist,x,y = Astrolabe:GetDistanceToIcon(self.waypoint.minimapFrame)

	if not dist or IsInInstance() then self:Hide() return end

	-- okay, we're live. 3, 2, 1, action!

	self:Show()

	local msin,mcos,mabs=math.sin,math.cos,math.abs

	if dist <= 5.0 then
		self.arrow:Hide()
		self.gem:Hide()
		self.gemhl:Hide()
		--self.eta:Hide()
		--self.dist:Hide()

		self.here:Show()
		self.here.zoomy:Play()
		--self.back.turny:Play()
		self.back:SetTexCoord(0,0,0,1,1,0,1,1)

		--[[
		oldangle = oldangle + elapsed * 3
		while oldangle>6.28319 do oldangle = oldangle - 6.28319 end
		local sin,cos = msin(oldangle + 2.356194)*0.71, mcos(oldangle + 2.356194)*0.71
		self.back:SetTexCoord(0.5-sin, 0.5+cos, 0.5+cos, 0.5+sin, 0.5-cos, 0.5-sin, 0.5+sin, 0.5-cos)
		--]]

		--[[
		count = count + 1
		if count >= 55 then
			count = 0
		end

		cell = count
		local column = cell % 9
		local row = floor(cell / 9)

		local xstart = (column * 53) / 512
		local ystart = (row * 70) / 512
		local xend = ((column + 1) * 53) / 512
		local yend = ((row + 1) * 70) / 512
		arrow:SetTexCoord(xstart,xend,ystart,yend)
		--]]
	else
		self.here:Hide()
		self.back.turny:Stop()
		self.here.zoomy:Stop()

		self.arrow:Show()
		self.gem:Show()
		self.gemhl:Show()
		self.title:Show()
		--self.eta:Show()
		--self.dist:Show()


		------------- angle

		local angle = Astrolabe:GetDirectionToIcon(self.waypoint.minimapFrame)
		if not angle then return end
		--local player = ZGV.db.profile.arrowcam and cam_yaw - (is_moving and GetPlayerFacing() or 0) or GetPlayerFacing()
		angle = angle - (ZGV.db.profile.arrowcam and cam_yaw or GetPlayerFacing())

		------------ color
		local ar,ag,ab = 1,0,0
		local br,bg,bb = 0.8,0.7,0
		local cr,cg,cb = 0,1,0

		local perc
		if ZGV.db.profile.arrowcolordir then
			while angle<0 do angle=angle+6.28319 end

			perc = mabs(1-angle*0.3183)  -- 1/pi
		else
			if not initialdist then initialdist=dist end
			if initialdist>500 then initialdist=500 end
			if initialdist<100 then initialdist=100 end
			perc=1-(dist/initialdist)
			if perc<0 then perc=0 end
		end
		local r,g,b = ZGV.gradient3(perc, ar,ag,ab, br,bg,bb, cr,cg,cb, 0.8)
		self.gem:SetVertexColor(r,g,b)


		--angle = angle + 2.356194  -- rad(135)

		if ZGV.db.profile.arrowsmooth then
			local dif = angle-oldangle
			if dif>0.001 or dif<0.001 then
				while dif>3.14159 do dif=dif-6.28319 end
				while dif<-3.14159 do dif=dif+6.28319 end

				angle = angle-dif/(1+elapsed*10)

				--local newdif = newangle-oldangle
				--while newdif>3.14159 do newdif=newdif-6.28319 end
				--while newdif<-3.14159 do newdif=newdif+6.28319 end

				--if newdif*dif>0 then  -- no jittering
				--	angle=newangle
				while angle>6.28319 do angle=angle-6.28319 end
				while angle<0 do angle=angle+6.28319 end
				--end
			end
			oldangle=angle
		end

		
		local sin,cos = msin(angle + 2.356194)*0.85, mcos(angle + 2.356194)*0.85
		self.arrow:SetTexCoord(0.5-sin, 0.5+cos, 0.5+cos, 0.5+sin, 0.5-cos, 0.5-sin, 0.5+sin, 0.5-cos)
		self.gem:SetTexCoord(0.5-sin, 0.5+cos, 0.5+cos, 0.5+sin, 0.5-cos, 0.5-sin, 0.5+sin, 0.5-cos)
		self.gemhl:SetTexCoord(0.5-sin, 0.5+cos, 0.5+cos, 0.5+sin, 0.5-cos, 0.5-sin, 0.5+sin, 0.5-cos)


		------------- background

		angle = angle*8
		sin,cos = msin(angle + 2.356194)*0.71, mcos(angle + 2.356194)*0.71
		self.back:SetTexCoord(0.5-sin, 0.5+cos, 0.5+cos, 0.5+sin, 0.5-cos, 0.5-sin, 0.5+sin, 0.5-cos)



		--[[
		local cell

		local perc = math.abs((math.pi - math.abs(angle)) / math.pi)

		local gr,gg,gb = unpack(TomTom.db.profile.arrow.goodcolor)
		local mr,mg,mb = unpack(TomTom.db.profile.arrow.middlecolor)
		local br,bg,bb = unpack(TomTom.db.profile.arrow.badcolor)
		local r,g,b = ColorGradient(perc, br, bg, bb, mr, mg, mb, gr, gg, gb)		
		arrow:SetVertexColor(r,g,b)

		cell = floor(angle / twopi * 108 + 0.5) % 108
		local column = cell % 9
		local row = floor(cell / 9)

		local xstart = (column * 56) / 512
		local ystart = (row * 42) / 512
		local xend = ((column + 1) * 56) / 512
		local yend = ((row + 1) * 42) / 512
		arrow:SetTexCoord(xstart,xend,ystart,yend)
		--]]
	end

	-- labels

	if self.waypoint.t then
		title=self.waypoint.t
	else
		title=nil
	end

	if ZGV.db.profile.arrowmeters then
		local mdist = dist * 0.9144
		if mdist>1000 then
			disttxt=("%.2f km"):format(mdist/1000)
		else
			disttxt=("%d m"):format(mdist)
		end
	else
		if dist>1760 then
			disttxt=("%.2f mil"):format(dist/1760)
		else
			disttxt=("%d yd"):format(dist)
		end
	end


	
	local limit=10

	eta_throttle = eta_throttle + elapsed
	if eta_throttle >= 0.1 then

		speed = (last_distance-dist) / eta_throttle

		if last_distance == 0 then
			speed = 0
		end

		if speed>0 then
			table.insert(speeds,1,speed)
			if #speeds>limit then table.remove(speeds) end
			stop=0
		else
			stop=stop+1
			if stop>=20 then
				speed=0
				table.wipe(speeds)
			end
		end

		-- Speed meter. Perhaps one day.
		--[[
		ZGV.db.profile.arrowshowspeed = true
		if ZGV.db.profile.arrowshowspeed then
			local spd
			if ZGV.db.profile.arrowmeters then
				spd=("%.02f km/h"):format(speed) --*3.6
			else
				spd=("%.02f mph"):format(speed) --*2.0454
			end
			print(spd)
			self.eta:SetText(spd)
		end
		--]]
		
		last_distance = dist
		eta_throttle = 0
	end

	etadisp_throttle = etadisp_throttle + elapsed
	if etadisp_throttle >= 0.5 then

		avg=speed
		for i=2,#speeds do avg=avg+speeds[i] end
		avg=avg/#speeds

		if #speeds==limit and avg>0 then
			local eta = math.abs(dist / avg)
			etatxt=("%01d:%02d"):format(eta / 60, eta % 60)
		else
			etatxt=nil
		end
		etadisp_throttle = etadisp_throttle - 0.5
	end

	-- spew it out.
	self.title:SetText( (title and "|cffffffff"..title.."|r\n" or "") .. (disttxt and "|cffffcc00"..disttxt.."|r" or "") .. (etatxt and "\n|cffff7700"..etatxt.."|r" or "") )
end
