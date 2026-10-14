if not ZygorGuidesViewer then return end

function TableKeys (tab)
	local t={}
	for k,v in pairs(tab) do table.insert(t,k) end
	return t
end

table.zygor_join = function (tab1,tab2)
	for k,v in pairs(tab2) do tab1[k]=v end
end

function MOVE(frame)
	if not frame then
		frame = GetMouseFocus()
		print("Moving: "..(frame:GetName() or tostring(frame)))
	end
	if frame.origonupdate then
		frame:StopMovingOrSizing()
		frame:SetScript("OnUpdate",frame.origonupdate)
		frame.origonupdate = nil
	else
		frame:SetMovable(1)
		frame:StartMoving()
		frame.origonupdate = frame:GetScript("OnUpdate")
		frame:SetScript("OnUpdate",function(self,...) if self.origonupdate then self.origonupdate(self,...) end print(self:GetPoint(1)) end)
	end
end

function RotatePair(x,y,ox,oy,a,asp)
	y=y/asp
	oy=oy/asp
	return ox + (x-ox)*math.cos(a) - (y-oy)*math.sin(a),
	      (oy + (y-oy)*math.cos(a) + (x-ox)*math.sin(a))*asp
end

function RotateTex(self, angle)
	local s,c
	s = sin(angle-225)
	c = cos(angle-225)
	self:SetTexCoord(0.5-s*0.7, 0.5+c*0.7,
			 0.5+c*0.7, 0.5+s*0.7,
			 0.5-c*0.7, 0.5-s*0.7,
			 0.5+s*0.7, 0.5-c*0.7)
end

function AnimRotOnUpdate(self,step)
	if not self:GetParent():GetParent().angle then self:GetParent():GetParent().angle=0 end
	self.step=step
	RotateTex(self:GetParent():GetParent(),self:GetParent():GetParent().angle+self:GetSmoothProgress()*self.step)
end

function AnimRotOnUpdate2(self)
	local tex = self.tex
	if not tex.angle then tex.angle=0 end
	tex.curangle = tex.angle+self:GetSmoothProgress()*(tex.targetangle-tex.angle)
	RotateTex(tex,tex.curangle)
end

function CreateTextureWithCoords(parent,texture,l,r,u,d,blend)
	local tex = parent:CreateTexture(nil)
	tex:SetTexture(texture)
	tex:SetTexCoord(l,r,u,d)
	tex:SetAllPoints()
	if blend then tex:SetBlendMode(blend) end
	return tex
end

