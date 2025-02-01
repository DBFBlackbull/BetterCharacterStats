BCS = BCS or {}

local BCS_Tooltip = getglobal("BetterCharacterStatsTooltip") or CreateFrame("GameTooltip", "BetterCharacterStatsTooltip", nil, "GameTooltipTemplate")
local BCS_Prefix = "BetterCharacterStatsTooltip"
BCS_Tooltip:SetOwner(WorldFrame, "ANCHOR_NONE")

local L = BCS["L"]

local strfind = strfind
local tonumber = tonumber
local tinsert = tinsert

local AURA_BUFF = "HELPFUL"
local AURA_DEBUFF = "HARMFUL"

local function tContains(table, item)
	local index = 1
	while table[index] do
		if ( item == table[index] ) then
			return 1
		end
		index = index + 1
	end
	return nil
end

function BCS:GetPlayerAura(searchText, auraType)
	if not auraType then
		-- buffs
		-- http://blue.cardplace.com/cache/wow-dungeons/624230.htm
		-- 32 buffs max
		for i=0, 31 do
			local index = GetPlayerBuff(i, 'HELPFUL')
			if index > -1 then
				BCS_Tooltip:SetPlayerBuff(index)
				local MAX_LINES = BCS_Tooltip:NumLines()
					
				for line=1, MAX_LINES do
					local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
					if left:GetText() then
						local value = {strfind(left:GetText(), searchText)}
						if value[1] then
							return unpack(value)
						end
					end
				end
			end
		end
	elseif auraType == 'HARMFUL' then
		for i=0, 6 do
			local index = GetPlayerBuff(i, auraType)
			if index > -1 then
				BCS_Tooltip:SetPlayerBuff(index)
				local MAX_LINES = BCS_Tooltip:NumLines()
					
				for line=1, MAX_LINES do
					local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
					if left:GetText() then
						local value = {strfind(left:GetText(), searchText)}
						if value[1] then
							return unpack(value)
						end
					end
				end
			end
		end
	end
end

local Cache_GetHitRating_Tab, Cache_GetHitRating_Talent
function BCS:GetHitRating()
	local melee_hit = 0
	local ranged_hit = 0
	local hit_debuff = 0;

	local Hit_Set_Bonus = {}

	BCS:IterateInventory(function(lineText, metaData)
		local _,_, value = strfind(lineText, L["Equip: Improves your chance to hit by (%d)%%."])
		if value then
			melee_hit = melee_hit + tonumber(value)
			ranged_hit = ranged_hit + tonumber(value)
		end

		_,_, value = strfind(lineText, L["/Hit %+(%d+)"])
		if value then
			melee_hit = melee_hit + tonumber(value)
			ranged_hit = ranged_hit + tonumber(value)
		end

		local _,_, value = strfind(lineText, L["+(%d)%% Hit"]) -- Ranged hit from scope
		if value and metaData.slot == 18 then
			ranged_hit = ranged_hit + tonumber(value)
		end

		_,_, value = strfind(lineText, "(.+) %(%d/%d%)")
		if value then
			metaData.setName = value
		end

		_,_, value = strfind(lineText, L["^Set: Improves your chance to hit by (%d)%%."])
		if value and metaData.setName and not tContains(Hit_Set_Bonus, metaData.setName) then
			tinsert(Hit_Set_Bonus, metaData.setName)
			melee_hit = melee_hit + tonumber(value)
			ranged_hit = ranged_hit + tonumber(value)
		end
	end)

	BCS:IterateAuras(AURA_BUFF, function(lineText)
		local _, _, hitFromAura = strfind(lineText, L["Chance to hit increased by (%d)%%."])
		if hitFromAura then
			melee_hit = melee_hit + tonumber(hitFromAura)
			ranged_hit = ranged_hit + tonumber(hitFromAura)
		end

		_, _, hitFromAura = strfind(lineText, L["Improves your chance to hit by (%d+)%%."])
		if hitFromAura then
			melee_hit = melee_hit + tonumber(hitFromAura)
			ranged_hit = ranged_hit + tonumber(hitFromAura)
		end

		_, _, hitFromAura = strfind(lineText, L["Increases attack power by %d+ and chance to hit by (%d+)%%."])
		if hitFromAura then
			melee_hit = melee_hit + tonumber(hitFromAura)
			ranged_hit = ranged_hit + tonumber(hitFromAura)
		end
	end)

	BCS:IterateAuras(AURA_DEBUFF, function(lineText)
		local _, _, hitFromAura = strfind(lineText, L["Chance to hit reduced by (%d+)%%."])
		if hitFromAura then
			hit_debuff = hit_debuff + tonumber(hitFromAura)
		end

		_, _, hitFromAura = strfind(lineText, L["Chance to hit decreased by (%d+)%% and %d+ Nature damage every %d+ sec."])
		if hitFromAura then
			hit_debuff = hit_debuff + tonumber(hitFromAura)
		end

		hitFromAura = strfind(lineText, L["Lowered chance to hit."])
		if hitFromAura then
			hit_debuff = hit_debuff + 25
		end
	end)

	local MAX_TABS = GetNumTalentTabs()
	-- speedup
	if Cache_GetHitRating_Tab and Cache_GetHitRating_Talent then
		BCS_Tooltip:SetTalent(Cache_GetHitRating_Tab, Cache_GetHitRating_Talent)
		local MAX_LINES = BCS_Tooltip:NumLines()
		
		for line=1, MAX_LINES do
			local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
			if left:GetText() then
				-- Rogues, Paladins
				-- Precision
				local _,_, value = strfind(left:GetText(), L["Increases your chance to hit with melee weapons by (%d)%%."])
				local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(Cache_GetHitRating_Tab, Cache_GetHitRating_Talent)
				if value and rank > 0 then
					melee_hit = melee_hit + tonumber(value)
					line = MAX_LINES
				end

				-- Shamans
				-- Nature's Guidance
				local _,_, value = strfind(left:GetText(), L["Increases your chance to hit with melee attacks and spells by (%d)%%."])
				local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(Cache_GetHitRating_Tab, Cache_GetHitRating_Talent)
				if value and rank > 0 then
					melee_hit = melee_hit + tonumber(value)
					line = MAX_LINES
				end

				-- Hunters
				-- Surefooted
				local _,_, value = strfind(left:GetText(), L["Increases hit chance by (%d)%% and increases the chance movement impairing effects will be resisted by an additional %d+%%."])
				local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(Cache_GetHitRating_Tab, Cache_GetHitRating_Talent)
				if value and rank > 0 then
					melee_hit = melee_hit + tonumber(value)
					ranged_hit = ranged_hit + tonumber(value)
					line = MAX_LINES
				end
			end
		end

		return melee_hit, ranged_hit, hit_debuff
	end
	
	for tab=1, MAX_TABS do
		local MAX_TALENTS = GetNumTalents(tab)
		
		for talent=1, MAX_TALENTS do
			BCS_Tooltip:SetTalent(tab, talent);
			local MAX_LINES = BCS_Tooltip:NumLines()
			
			for line=1, MAX_LINES do
				local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
				if left:GetText() then
					-- Rogues, Paladins
					-- Precision
					local _,_, value = strfind(left:GetText(), L["Increases your chance to hit with melee weapons by (%d)%%."])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						melee_hit = melee_hit + tonumber(value)

						Cache_GetHitRating_Tab = tab
						Cache_GetHitRating_Talent = talent
						
						line = MAX_LINES
						talent = MAX_TALENTS
						tab = MAX_TABS
					end

					-- Shamans
					-- Nature's Guidance
					local _,_, value = strfind(left:GetText(), L["Increases your chance to hit with melee attacks and spells by (%d)%%."])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						melee_hit = melee_hit + tonumber(value)

						Cache_GetHitRating_Tab = tab
						Cache_GetHitRating_Talent = talent

						line = MAX_LINES
						talent = MAX_TALENTS
						tab = MAX_TABS
					end
					
					-- Hunters
					-- Surefooted
					local _,_, value = strfind(left:GetText(), L["Increases hit chance by (%d)%% and increases the chance movement impairing effects will be resisted by an additional %d+%%."])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						melee_hit = melee_hit + tonumber(value)
						ranged_hit = ranged_hit + tonumber(value)
						
						Cache_GetHitRating_Tab = tab
						Cache_GetHitRating_Talent = talent
						
						line = MAX_LINES
						talent = MAX_TALENTS
						tab = MAX_TABS
					end
				end	
			end
			
		end
	end

	return melee_hit, ranged_hit, hit_debuff
end

function BCS:GetItemIDFromLink(itemLink)
	if not itemLink then
		return
	end

	local foundID, _ , itemID = string.find(itemLink, "item:(%d+)")
	if not foundID then
		return
	end

	return tonumber(itemID)
end

function BCS:GetWeaponSkill()
	local main_hand_skill = 0
	local main_hand_type
	local off_hand_skill
	local off_hand_type
	local ranged_skill = 0
	local ranged_type

	local mainHandLink = GetInventoryItemLink("player", 16)
	if mainHandLink then
		local itemID = BCS:GetItemIDFromLink(mainHandLink)
		_, _, _, _, _, main_hand_type, subtype = GetItemInfo(itemID)
		main_hand_type = string.gsub(main_hand_type,"^One%-Handed%s*", "")
	end

	if not main_hand_type then
		main_hand_type = "Unarmed"
	end

	local offHandLink = GetInventoryItemLink("player", 17)
	if offHandLink then
		local itemID = BCS:GetItemIDFromLink(offHandLink)
		_, _, _, _, _, off_hand_type = GetItemInfo(itemID)
		off_hand_type = string.gsub(off_hand_type,"^One%-Handed%s*", "")
	end

	local rangedLink = GetInventoryItemLink("player", 18)
	if rangedLink then
		local itemID = BCS:GetItemIDFromLink(rangedLink)
		_, _, _, _, _, ranged_type = GetItemInfo(itemID)
	end

	local MAX_SKILLS = GetNumSkillLines()
	for skill=0, MAX_SKILLS do
		local skillName, _, _, skillRank, numTempPoints, skillModifier  = GetSkillLineInfo(skill)
		BCS:Print(skillName or "nil")
		if skillName and skillName == main_hand_type then
			BCS:Print(skillName)
			main_hand_skill = skillRank + numTempPoints + skillModifier
		end

		if skillName and skillName == off_hand_type then
			off_hand_skill = skillRank + numTempPoints + skillModifier
		end

		if skillName and skillName == ranged_type then
			ranged_type = skillRank + numTempPoints + skillModifier
		end
	end

	return main_hand_skill, off_hand_skill, ranged_skill
end

function BCS:GetGlancingBlow(targetDefense, attackerSkill, attackerLevel)
	local skillDiff = targetDefense - attackerSkill
	local glanceChance = 10 + (targetDefense - math.min(attackerLevel*5, attackerSkill)) * 2

	local glanceLowEnd = 1.3 - 0.05*skillDiff
	local glanceHighEnd = 1.2 - 0.03*skillDiff

	glanceLowEnd = math.min(glanceLowEnd, 0.91)
	glanceHighEnd= math.min(glanceHighEnd, 0.99)
	glanceHighEnd= math.max(glanceHighEnd, 0.2)

	local glancePenalty = (1 - (glanceHighEnd + glanceLowEnd) / 2) * 100
	return glanceChance, glancePenalty
end

function BCS:GetMissChance(targetDefense, attackerSkill)
	local targetMiss = 0
	local hitSuppression = 0

	local skillDiff = targetDefense - attackerSkill
	if skillDiff > 10 then
		targetMiss = 5 + skillDiff * 0.2
		hitSuppression = (skillDiff - 10) * 0.2
	end

	if skillDiff <= 10 then
		targetMiss = 5 + skillDiff * 0.1
	end

	return targetMiss, hitSuppression
end

function BCS:GetSpellHitRating()
	local hit = 0
	local hit_fire = 0
	local hit_frost = 0
	local hit_arcane = 0
	local hit_shadow = 0
	local hit_Set_Bonus = {}
	
	-- scan gear
	BCS:IterateInventory(function(lineText, metaData)
		local _,_, value = strfind(lineText, L["Equip: Improves your chance to hit with spells by (%d)%%."])
		if value then
			hit = hit + tonumber(value)
		end

		local _,_, value = strfind(lineText, L["/Spell Hit %+(%d+)"])
		if value then
			hit = hit + tonumber(value)
		end

		local _,_, value = strfind(lineText, "(.+) %(%d/%d%)")
		if value then
			metaData.setName = value
		end

		local _, _, value = strfind(lineText, L["^Set: Improves your chance to hit with spells by (%d)%%."])
		if value and metaData.setName and not tContains(hit_Set_Bonus, metaData.setName) then
			tinsert(hit_Set_Bonus, metaData.setName)
			hit = hit + tonumber(value)
		end
	end)

	-- scan talents
	local MAX_TABS = GetNumTalentTabs()
	
	for tab=1, MAX_TABS do
		local MAX_TALENTS = GetNumTalents(tab)
		
		for talent=1, MAX_TALENTS do
			BCS_Tooltip:SetTalent(tab, talent)
			local MAX_LINES = BCS_Tooltip:NumLines()
			
			for line=1, MAX_LINES do
				local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
				if left:GetText() then
					-- Mage
					-- Elemental Precision
					local _,_, value = strfind(left:GetText(), L["Reduces the chance that the opponent can resist your Frost and Fire spells by (%d)%%."])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						hit_fire = hit_fire + tonumber(value)
						hit_frost = hit_frost + tonumber(value)
						line = MAX_LINES
					end
					
					-- Arcane Focus
					local _,_, value = strfind(left:GetText(), L["Reduces the chance that the opponent can resist your Arcane spells by (%d+)%%."])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						hit_arcane = hit_arcane + tonumber(value)
						line = MAX_LINES
					end
					
					-- Priest
					-- Shadow Focus
					local _,_, value = strfind(left:GetText(), L["Reduces your target's chance to resist your Shadow spells by (%d+)%%."])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						hit_shadow = hit_shadow + tonumber(value)
						line = MAX_LINES
					end

					-- Shaman
					-- Nature's Guidance
					local _,_, value = strfind(left:GetText(), L["Increases your chance to hit with melee attacks and spells by (%d)%%."])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						hit = hit + tonumber(value)
						line = MAX_LINES
					end
				end	
			end
			
		end
	end
	
	-- buffs
	local _, _, hitFromAura = BCS:GetPlayerAura(L["Spell hit chance increased by (%d+)%%."])
	if hitFromAura then
		hit = hit + tonumber(hitFromAura)
	end
	
	return hit, hit_fire, hit_frost, hit_arcane, hit_shadow
end

local Cache_GetCritChance_SpellID, Cache_GetCritChance_BookType, Cache_GetCritChance_Line
local Cache_GetCritChance_Tab, Cache_GetCritChance_Talent
function BCS:GetCritChance()
	local crit = 0
	local _, class = UnitClass('player')
	
	if class == 'HUNTER' then
	
		local MAX_TABS = GetNumTalentTabs()
		-- speedup
		if Cache_GetCritChance_Tab and Cache_GetCritChance_Talent then
			BCS_Tooltip:SetTalent(Cache_GetCritChance_Tab, Cache_GetCritChance_Talent)
			local MAX_LINES = BCS_Tooltip:NumLines()
			
			for line=1, MAX_LINES do
				local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
				if left:GetText() then
					local _,_, value = strfind(left:GetText(), L["Increases your critical strike chance with all attacks by (%d)%%."])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(Cache_GetCritChance_Tab, Cache_GetCritChance_Talent)
					if value and rank > 0 then
						crit = crit + tonumber(value)
						line = MAX_LINES
					end
				end
			end
		else
			for tab=1, MAX_TABS do
				local MAX_TALENTS = GetNumTalents(tab)
				for talent=1, MAX_TALENTS do
					BCS_Tooltip:SetTalent(tab, talent);
					local MAX_LINES = BCS_Tooltip:NumLines()
					
					for line=1, MAX_LINES do
						local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
						if left:GetText() then
							local _,_, value = strfind(left:GetText(), L["Increases your critical strike chance with all attacks by (%d)%%."])
							local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
							if value and rank > 0 then
								crit = crit + tonumber(value)
								
								Cache_GetCritChance_Tab = tab
								Cache_GetCritChance_Talent = talent
								
								line = MAX_LINES
								talent = MAX_TALENTS
								tab = MAX_TABS
							end
						end	
					end
					
				end
			end
		end
		
	end
	
	-- speedup
	if Cache_GetCritChance_SpellID and Cache_GetCritChance_BookType and Cache_GetCritChance_Line then
	
		BCS_Tooltip:SetSpell(Cache_GetCritChance_SpellID, Cache_GetCritChance_BookType)
		local left = getglobal(BCS_Prefix .. "TextLeft" .. Cache_GetCritChance_Line)
		if left:GetText() then
			local _,_, value = strfind(left:GetText(), L["([%d.]+)%% chance to crit"])
			if value then
				crit = crit + tonumber(value)
			end
		end
		
		return crit
	end
	
	local MAX_TABS = GetNumSpellTabs()
	
	for tab=1, MAX_TABS do
		local name, texture, offset, numSpells = GetSpellTabInfo(tab)
		
		for spell=1, numSpells do
			local currentPage = ceil(spell/SPELLS_PER_PAGE)
			local SpellID = spell + offset + ( SPELLS_PER_PAGE * (currentPage - 1))

			BCS_Tooltip:SetSpell(SpellID, BOOKTYPE_SPELL)
			local MAX_LINES = BCS_Tooltip:NumLines()
			
			for line=1, MAX_LINES do
				local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
				if left:GetText() then
					local _,_, value = strfind(left:GetText(), L["([%d.]+)%% chance to crit"])
					if value then
						crit = crit + tonumber(value)
						
						Cache_GetCritChance_SpellID = SpellID
						Cache_GetCritChance_BookType = BOOKTYPE_SPELL
						Cache_GetCritChance_Line = line
						
						line = MAX_LINES
						spell = numSpells
						tab = MAX_TABS
					end
				end
			end
			
		end
	end
	
	return crit
end

local Cache_GetRangedCritChance_Tab, Cache_GetRangedCritChance_Talent, Cache_GetRangedCritChance_Line
function BCS:GetRangedCritChance()
	local crit = BCS:GetCritChance()
	
	if Cache_GetRangedCritChance_Tab and Cache_GetRangedCritChance_Talent and Cache_GetRangedCritChance_Line then
		BCS_Tooltip:SetTalent(Cache_GetRangedCritChance_Tab, Cache_GetRangedCritChance_Talent)
		local left = getglobal(BCS_Prefix .. "TextLeft" .. Cache_GetRangedCritChance_Line)
		
		if left:GetText() then
			local _,_, value = strfind(left:GetText(), L["Increases your critical strike chance with ranged weapons by (%d)%%."])
			local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(Cache_GetRangedCritChance_Tab, Cache_GetRangedCritChance_Talent)
			if value and rank > 0 then
				crit = crit + tonumber(value)
			end
		end
	
		return crit
	end
	
	local MAX_TABS = GetNumTalentTabs()
	
	for tab=1, MAX_TABS do
		local MAX_TALENTS = GetNumTalents(tab)
		
		for talent=1, MAX_TALENTS do
			BCS_Tooltip:SetTalent(tab, talent);
			local MAX_LINES = BCS_Tooltip:NumLines()
			
			for line=1, MAX_LINES do
				local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
				if left:GetText() then
					local _,_, value = strfind(left:GetText(), L["Increases your critical strike chance with ranged weapons by (%d)%%."])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						crit = crit + tonumber(value)
						
						line = MAX_LINES
						talent = MAX_TALENTS
						tab = MAX_TABS
					end
				end
			end
			
		end
	end
	
	return crit
end

function BCS:GetSpellCritChance()
	-- school crit: most likely never
	local Crit_Set_Bonus = {}
	local spellCrit = 0;
	local _, intelect = UnitStat("player", 4)
	local _, class = UnitClass("player")
	
	-- values from theorycraft / http://wow.allakhazam.com/forum.html?forum=21&mid=1157230638252681707
	if class == "MAGE" then
		spellCrit = 0.2 + (intelect / 59.5)
	elseif class == "WARLOCK" then
		spellCrit = 1.7 + (intelect / 60.6)
	elseif class == "PRIEST" then
		spellCrit = 0.8 + (intelect / 59.56)
	elseif class == "DRUID" then
		spellCrit = 1.8 + (intelect / 60)
	elseif class == "SHAMAN" then
		spellCrit = 1.8 + (intelect / 59.2)
	elseif class == "PALADIN" then
		spellCrit = intelect / 29.5
	end

	BCS:IterateInventory(function (lineText, metaData)
		local _,_, value = strfind(lineText, L["Equip: Improves your chance to get a critical strike with spells by (%d)%%."])
		if value then
			spellCrit = spellCrit + tonumber(value)
		end

		_,_, value = strfind(lineText, "(.+) %(%d/%d%)")
		if value then
			metaData.setName = value
		end

		_, _, value = strfind(lineText, L["^Set: Improves your chance to get a critical strike with spells by (%d)%%."])
		if value and metaData.setName and not tContains(Crit_Set_Bonus, metaData.setName) then
			tinsert(Crit_Set_Bonus, metaData.setName)
			spellCrit = spellCrit + tonumber(value)
		end
	end)

	-- buffs
	BCS:IterateAuras(AURA_BUFF, function(lineText)
		local _, _, critFromAura = strfind(lineText, L["Chance for a critical hit with a spell increased by (%d+)%%."])
		if critFromAura then
			spellCrit = spellCrit + tonumber(critFromAura)
		end

		_, _, critFromAura = strfind(lineText, L["While active, target's critical hit chance with spells and attacks increases by 10%%."])
		if critFromAura then
			spellCrit = spellCrit + 10
		end

		_, _, critFromAura = strfind(lineText, L["Increases chance for a melee, ranged, or spell critical by (%d+)%% and all attributes by %d+."])
		if critFromAura then
			spellCrit = spellCrit + tonumber(critFromAura)
		end

		critFromAura = strfind(lineText, L["Increases critical chance of spells by 10%%, melee and ranged by 5%% and grants 140 attack power. 120 minute duration."])
		if critFromAura then
			spellCrit = spellCrit + 10
		end

		_, _, critFromAura = strfind(lineText, L["Critical strike chance with spells and melee attacks increased by (%d+)%%."])
		if critFromAura then
			spellCrit = spellCrit + tonumber(critFromAura)
		end
	end)

	BCS:IterateAuras(AURA_DEBUFF, function(lineText)
		local _, _, _, critFromAura = strfind(lineText, L["Melee critical-hit chance reduced by (%d+)%%.\r\nSpell critical-hit chance reduced by (%d+)%%."], 'HARMFUL')
		if critFromAura then
			spellCrit = spellCrit - tonumber(critFromAura)
		end
	end)

	return spellCrit
end

function BCS:GetSpellPower()
	local spellPower = 0;
	local damagePower = 0;

	local SpellPower_Set_Bonus = {}
	local SpellPower_Schools = {
		["Arcane"] = 0,
		["Fire"] = 0,
		["Frost"] = 0,
		["Holy"] = 0,
		["Nature"] = 0,
		["Shadow"] = 0,
	}

	-- scan gear
	BCS:IterateInventory(function(lineText, metaData)
		local _,_, value = strfind(lineText, L["Equip: Increases damage and healing done by magical spells and effects by up to (%d+)."])
		if value then
			spellPower = spellPower + tonumber(value)
		end

		_,_, value = strfind(lineText, L["Spell Damage %+(%d+)"])
		if value then
			spellPower = spellPower + tonumber(value)
		end

		_,_, value = strfind(lineText, L["^%+(%d+) Spell Damage and Healing"])
		if value then
			spellPower = spellPower + tonumber(value)
		end

		_,_, value = strfind(lineText, L["^%+(%d+) Damage and Healing Spells"])
		if value then
			spellPower = spellPower + tonumber(value)
		end

		_,_, value = strfind(lineText, "(.+) %(%d/%d%)")
		if value then
			metaData.setName = value
		end

		_, _, value = strfind(lineText, L["^Set: Increases damage and healing done by magical spells and effects by up to (%d+)%."])
		if value and metaData.setName and not tContains(SpellPower_Set_Bonus, metaData.setName) then
			tinsert(SpellPower_Set_Bonus, metaData.setName)
			spellPower = spellPower + tonumber(value)
		end

		-- Check specific school damage
		for school, schoolPower in pairs(SpellPower_Schools) do
			local _,_, value = strfind(lineText, L["Equip: Increases damage done by "..school.." spells and effects by up to (%d+)."])
			if value then
				SpellPower_Schools[school] = schoolPower + tonumber(value)
			end

			if L[school.." Damage %+(%d+)"] then
				_,_, value = strfind(lineText, L[school.." Damage %+(%d+)"])
				if value then
					SpellPower_Schools[school] = schoolPower + tonumber(value)
				end
			end

			if L["^%+(%d+) "..school.." Spell Damage"] then
				_,_, value = strfind(lineText, L["^%+(%d+) "..school.." Spell Damage"])
				if value then
					SpellPower_Schools[school] = schoolPower + tonumber(value)
				end
			end
		end
	end)

	-- scan talents
	local MAX_TABS = GetNumTalentTabs()
	for tab=1, MAX_TABS do
		local MAX_TALENTS = GetNumTalents(tab)

		for talent=1, MAX_TALENTS do
			BCS_Tooltip:SetTalent(tab, talent)
			local MAX_LINES = BCS_Tooltip:NumLines()

			for line=1, MAX_LINES do
				local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
				if left:GetText() then
					-- Priest
					-- Spiritual Guidance
					local _,_, value = strfind(left:GetText(), L["Increases spell damage and healing by up to (%d+)%% of your total Spirit."])
					local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tab, talent)
					if value and rank > 0 then
						local stat, effectiveStat = UnitStat("player", 5)
						spellPower = spellPower + floor(((tonumber(value) / 100) * effectiveStat))

						-- nothing more is currenlty supported, break out of the loops
						line = MAX_LINES
						talent = MAX_TALENTS
						tab = MAX_TABS
					end
				end
			end

		end
	end

	BCS:IterateAuras(nil, function(lineText)
		-- Very Berry Cream
		local _, _, spellPowerFromAura = strfind(lineText, L["Magical damage dealt is increased by up to (%d+)."])
		if spellPowerFromAura then
			spellPower = spellPower + tonumber(spellPowerFromAura)
			damagePower = damagePower + tonumber(spellPowerFromAura)
		end

		-- (Greater) Arcane Elixir
		_, _, spellPowerFromAura = strfind(lineText, L["Magical damage dealt by spells and abilities is increased by up to (%d+)."])
		if spellPowerFromAura then
			spellPower = spellPower + tonumber(spellPowerFromAura)
			damagePower = damagePower + tonumber(spellPowerFromAura)
		end

		-- Flask of Supreme power
		_, _, spellPowerFromAura = strfind(lineText, L["Spell damage increased by up to (%d+)."])
		if spellPowerFromAura then
			spellPower = spellPower + tonumber(spellPowerFromAura)
			damagePower = damagePower + tonumber(spellPowerFromAura)
		end

		-- Fire, Frost, Shadow power Elixir
		for school, schoolPower in pairs(SpellPower_Schools) do
			local _, _, schoolPowerFromAura = strfind(lineText, L[school.." damage dealt by spells and abilities is increased by up to (%d+)."])
			if schoolPowerFromAura then
				SpellPower_Schools[school] = schoolPower + tonumber(schoolPowerFromAura)
			end
		end

		-- Blessing of Blackfathom debuff
		local _, _, schoolPowerFromAura = strfind(lineText, L["Increases frost damage done by (%d+)"])
		if schoolPowerFromAura then
			SpellPower_Schools["Frost"] = SpellPower_Schools["Frost"] + tonumber(schoolPowerFromAura)
		end
	end)

	return spellPower, SpellPower_Schools, damagePower
end

function BCS:GetHealingPower()
	local healPower = 0;
	local healPower_Set_Bonus = {}

	BCS:IterateInventory(function(lineText, metaData)
		local _,_, value = strfind(lineText, L["Equip: Increases healing done by spells and effects by up to (%d+)."])
		if value then
			healPower = healPower + tonumber(value)
		end
		_,_, value = strfind(lineText, L["Healing Spells %+(%d+)"])
		if value then
			healPower = healPower + tonumber(value)
		end
		_,_, value = strfind(lineText, L["^%+(%d+) Healing Spells"])
		if value then
			healPower = healPower + tonumber(value)
		end

		_,_, value = strfind(lineText, "(.+) %(%d/%d%)")
		if value then
			metaData.setName = value
		end
		_, _, value = strfind(lineText, L["^Set: Increases healing done by spells and effects by up to (%d+)%."])
		if value and metaData.setName and not tContains(healPower_Set_Bonus, metaData.setName) then
			tinsert(healPower_Set_Bonus, metaData.setName)
			healPower = healPower + tonumber(value)
		end
	end)

	-- buffs
	local _, _, healPowerFromAura = BCS:GetPlayerAura(L["Healing done by magical spells is increased by up to (%d+)."])
	if healPowerFromAura then
		healPower = healPower + tonumber(healPowerFromAura)
	end
	
	return healPower
end

--[[
-- server\src\game\Object\Player.cpp
float Player::OCTRegenMPPerSpirit()
{
    float addvalue = 0.0;

    float Spirit = GetStat(STAT_SPIRIT);
    uint8 Class = getClass();

    switch (Class)
    {
        case CLASS_DRUID:   addvalue = (Spirit / 5 + 15);   break;
        case CLASS_HUNTER:  addvalue = (Spirit / 5 + 15);   break;
        case CLASS_MAGE:    addvalue = (Spirit / 4 + 12.5); break;
        case CLASS_PALADIN: addvalue = (Spirit / 5 + 15);   break;
        case CLASS_PRIEST:  addvalue = (Spirit / 4 + 12.5); break;
        case CLASS_SHAMAN:  addvalue = (Spirit / 5 + 17);   break;
        case CLASS_WARLOCK: addvalue = (Spirit / 5 + 15);   break;
    }

    addvalue /= 2.0f;   // the above addvalue are given per tick which occurs every 2 seconds, hence this divide by 2

    return addvalue;
}

void Player::UpdateManaRegen()
{
    // Mana regen from spirit
    float power_regen = OCTRegenMPPerSpirit();
    // Apply PCT bonus from SPELL_AURA_MOD_POWER_REGEN_PERCENT aura on spirit base regen
    power_regen *= GetTotalAuraMultiplierByMiscValue(SPELL_AURA_MOD_POWER_REGEN_PERCENT, POWER_MANA);

    // Mana regen from SPELL_AURA_MOD_POWER_REGEN aura
    float power_regen_mp5 = GetTotalAuraModifierByMiscValue(SPELL_AURA_MOD_POWER_REGEN, POWER_MANA) / 5.0f;

    // Set regen rate in cast state apply only on spirit based regen
    int32 modManaRegenInterrupt = GetTotalAuraModifier(SPELL_AURA_MOD_MANA_REGEN_INTERRUPT);
    if (modManaRegenInterrupt > 100)
        { modManaRegenInterrupt = 100; }

    m_modManaRegenInterrupt = power_regen_mp5 + power_regen * modManaRegenInterrupt / 100.0f;

    m_modManaRegen = power_regen_mp5 + power_regen;
}
]]

local function GetRegenMPPerSpirit()
	local addvalue = 0
	
	local stat, Spirit, posBuff, negBuff = UnitStat("player", 5)
	local lClass, class = UnitClass("player")
	
	if class == "DRUID" then
		addvalue = (Spirit / 5 + 15)
	elseif class == "HUNTER" then
		addvalue = (Spirit / 5 + 15)
	elseif class == "MAGE" then
		addvalue = (Spirit / 4 + 12.5)
	elseif class == "PALADIN" then
		addvalue = (Spirit / 5 + 15)
	elseif class == "PRIEST" then
		addvalue = (Spirit / 4 + 12.5)
	elseif class == "SHAMAN" then
		addvalue = (Spirit / 5 + 17)
	elseif class == "WARLOCK" then
		addvalue = (Spirit / 5 + 15)
	else
		return addvalue
	end
	return addvalue
end

function BCS:GetManaRegen()
	-- to-maybe-do: apply buffs/talents
	local base, casting
	local power_regen = GetRegenMPPerSpirit()
	
	casting = power_regen / 100
	base = power_regen
	
	local mp5 = 0;

	BCS:IterateInventory(function(lineText, metaData)
		local _,_, value = strfind(lineText, L["^Mana Regen %+(%d+)"])
		if value then
			mp5 = mp5 + tonumber(value)
		end
		_,_, value = strfind(lineText, L["Equip: Restores (%d+) mana per 5 sec."])
		if value then
			mp5 = mp5 + tonumber(value)
		end
		_,_, value = strfind(lineText, L["^%+(%d+) mana every 5 sec."])
		if value then
			mp5 = mp5 + tonumber(value)
		end
	end)
	
	-- buffs
	local _, _, mp5FromAura = BCS:GetPlayerAura(L["Increases hitpoints by 300. 15%% haste to melee attacks. 10 mana regen every 5 seconds."])
	if mp5FromAura then
		mp5 = mp5 + 10
	end
	
	return base, casting, mp5
end

local MAX_INVENTORY_SLOTS = 19
function BCS:IterateInventory(callbackFunc)
	for slot=0, MAX_INVENTORY_SLOTS do
		local hasItem = BCS_Tooltip:SetInventoryItem("player", slot)
		if hasItem then
			local MAX_LINES = BCS_Tooltip:NumLines()
			local metaData = {
				slot = slot,
				setName = nil,
			}

			for line=1, MAX_LINES do
				local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
				local lineText = left:GetText()
				if lineText then
					callbackFunc(lineText, metaData)
				end
			end
		end
	end
end

function BCS:IterateAuras(buffFilter, callbackFunc)
	if not buffFilter then
		buffFilter = "HELPFUL|HARMFUL"
	end

	for i=0, 200 do
		local index = GetPlayerBuff(i, buffFilter)
		if index == 0 then -- test if this is correct
			return
		end

		BCS_Tooltip:SetPlayerBuff(index)
		local MAX_LINES = BCS_Tooltip:NumLines()

		for line=1, MAX_LINES do
			local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
			local lineText = left:GetText()
			if lineText then
				callbackFunc(lineText)
			end
		end
	end
end
