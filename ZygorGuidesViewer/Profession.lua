local me = ZygorGuidesViewer
local ZGV = me
if not ZGV then return end

me.skills = {}

local LS=ZygorGuidesViewer_L("Skills")

local skillSpells = {
	['Alchemy']=2259,
	['Blacksmithing']=2018,
	['Inscription']=45357,
	['Jewelcrafting']=25229,
	['Leatherworking']=2108,
	['Tailoring']=3908,
	['Enchanting']=7411,
	['Engineering']=4036,

	['Herbalism']=13614,
	['Mining']=2575,
	['Skinning']=8613,

	['Cooking']=2550,
	['First Aid']=3273,
	['Fishing']=7620,
}

tinsert(me.startups,function(self)
	self:AddEvent("SKILL_LINES_CHANGED","CacheSkills")
	self:AddEvent("TRADE_SKILL_UPDATE","CacheSkills")
	self:AddEvent("CHAT_MSG_SKILL","CacheSkills")
	--self:AddEvent("CHAT_MSG_COMBAT_FACTION_CHANGE","CHAT_MSG_COMBAT_FACTION_CHANGE_Faction")

	self.skills[""]={
		active=false,
		level=0,
	}

	if GetLocale()~="enUS" then
		ZGV.SkillsLocalized={}
		for skill,num in pairs(skillSpells) do
			ZGV.SkillsLocalized[skill]=GetSpellInfo(num)
		end
	end
end)

function me:CacheSkills()
	for i=1,70 do
		local skillName, header, isExpanded, skillRank, numTempPoints, skillModifier, skillMaxRank, isAbandonable, stepCost, rankCost, minLevel, skillCostType, skillDescription = GetSkillLineInfo(i)

		if not header and skillName then
			local pro = self.skills[skillName]
			if not pro then
				pro={
				}
				self.skills[skillName]=pro
			end
			pro.level=skillRank
			pro.max=skillMaxRank
			pro.active=true
		end
	end
end

function me:GetSkill(name)
	if self.SkillsLocalized and self.SkillsLocalized[name] then name=self.SkillsLocalized[name] end
	return self.skills[name] or self.skills[""]
end
