local me = ZygorGuidesViewer
local ZGV = me
if not ZGV then return end

tinsert(ZGV.startups,function(self)
		-- quest auto turnin/accept
	self:RegisterEvent("GOSSIP_SHOW")
	self:RegisterEvent("QUEST_GREETING")
	self:RegisterEvent("QUEST_DETAIL")
	self:RegisterEvent("QUEST_PROGRESS")
	self:RegisterEvent("QUEST_COMPLETE")
	--hooksecurefunc("QuestRewardCancelButton_OnClick",ZGV_QuestRewardCancelButton_OnClick)
	hooksecurefunc("DeclineQuest",ZGV_DeclineQuest)
end)

function me:QUEST_GREETING()
	if self.tmp_no_autoquest and time()-self.tmp_no_autoquest<10 then
		self.tmp_no_autoquest=nil
		return
	end
	if not self.CurrentStep then return end  -- no guide loaded yet
	if self.db.profile.autoturnin then
		for qnum=1,GetNumActiveQuests() do
			for i,goal in ipairs(self.CurrentStep.goals) do
				if goal.action=="turnin" and goal.quest==GetActiveTitle(qnum) and goal:GetStatus()=="incomplete" then
					self:Print("Activating quest")
					SelectActiveQuest(qnum)
					return
				end
			end
		end
	end
	if self.db.profile.autoaccept then
		for qnum=1,GetNumAvailableQuests() do
			for i,goal in ipairs(self.CurrentStep.goals) do
				if goal.action=="accept" and goal.quest==GetAvailableTitle(qnum) and goal:GetStatus()=="incomplete" then
					self:Print("Opening quest")
					SelectAvailableQuest(qnum)
					return
				end
			end
		end
	end
end

function me:GOSSIP_SHOW()
	if self.tmp_no_autoquest and time()-self.tmp_no_autoquest<10 then
		self.tmp_no_autoquest=nil
		return
	end
	if not self.CurrentStep then return end  -- no guide loaded yet
	if self.db.profile.autoturnin then
		local quests={GetGossipActiveQuests()}
		for qnum=1,GetNumGossipActiveQuests() do
			for i,goal in ipairs(self.CurrentStep.goals) do
				if goal.action=="turnin" and goal.quest==quests[qnum*3-2] and goal:GetStatus()=="incomplete" then
					self:Print("Activating quest")
					SelectGossipActiveQuest(qnum)
					return
				end
			end
		end
	end
	if self.db.profile.autoaccept then
		local quests={GetGossipAvailableQuests()}
		for qnum=1,GetNumGossipAvailableQuests() do
			for i,goal in ipairs(self.CurrentStep.goals) do
				if goal.action=="accept" and goal.quest==quests[qnum*3-2] and goal:GetStatus()=="incomplete" then
					self:Print("Opening quest")
					SelectGossipAvailableQuest(qnum)
					return
				end
			end
		end
	end
end

function me:QUEST_DETAIL()
	if self.tmp_no_autoquest and time()-self.tmp_no_autoquest<10 then
		self.tmp_no_autoquest=nil
		return
	end
	if not self.CurrentStep then return end  -- no guide loaded yet
	if self.db.profile.autoaccept then
		local title = GetTitleText()
		for i,goal in ipairs(self.CurrentStep.goals) do
			if goal.action=="accept" and goal.quest==title and goal:IsCompleteable() and not goal:IsObsolete() then
				self:Print("Accepting quest")
				AcceptQuest()
				return
			end
		end
	end
end

function me:QUEST_PROGRESS()
	if self.tmp_no_autoquest and time()-self.tmp_no_autoquest<10 then
		self.tmp_no_autoquest=nil
		return
	end
	if not self.CurrentStep then return end  -- no guide loaded yet
	if self.db.profile.autoturnin then
		if not IsQuestCompletable() then return end
		local title = GetTitleText()
		for i,goal in ipairs(self.CurrentStep.goals) do
			if goal.quest==title then
				self:Print("Completing quest")
				CompleteQuest()
				return
			end
		end
	end
end

function ZGV_DeclineQuest()
	ZGV.tmp_no_autoquest=time()
end

function me:QUEST_COMPLETE()
	-- 836: seems not necessary anymore; moving to QuestAutoAccept.lua
	--self:Debug('QUEST_COMPLETE: '..tostring(GetTitleText()).." (talker: "..tostring(UnitName("target"))..")")
	--self.completingQuest = GetTitleText()
	--self:RecordData(self.questIndicesByTitle[GetTitleText()], 'finish', QuestFrameNpcNameText:GetText())

	if self.db.profile.autoturnin then
		if not self.CurrentStep then return end  -- no guide loaded yet
		if (GetNumQuestChoices()>0) then return end
		local title = GetTitleText()
		for i,goal in ipairs(self.CurrentStep.goals) do
			if goal.quest==title then
				self:Print("Turning in quest")
				GetQuestReward()
				return
			end
		end
	end
end

