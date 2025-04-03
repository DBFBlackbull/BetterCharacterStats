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

function BCS:ColorText(colorCode, msg)
	return colorCode .. msg .. FONT_COLOR_CODE_CLOSE
end

function BCS:ModifierColor(modifier, msg)
	if modifier > 0 then
		return BCS:ColorText(GREEN_FONT_COLOR_CODE, msg)
	end
	if modifier < 0 then
		return BCS:ColorText(RED_FONT_COLOR_CODE, msg)
	end

	return ""..msg
end

function BCS:ModifierText(modifier, base, total)
	if modifier > 0 then
		return HIGHLIGHT_FONT_COLOR_CODE.."("..base..GREEN_FONT_COLOR_CODE.."+"..modifier..HIGHLIGHT_FONT_COLOR_CODE..") "..total
	end
	if modifier < 0 then
		return HIGHLIGHT_FONT_COLOR_CODE.."("..base..RED_FONT_COLOR_CODE..modifier..HIGHLIGHT_FONT_COLOR_CODE..") "..total
	end

	return ""..base
end

function BCS:ModifierTextPercent(modifier, base, total)
	if modifier > 0 then
		return HIGHLIGHT_FONT_COLOR_CODE.."("..base.."%"..GREEN_FONT_COLOR_CODE.."+"..modifier.."%"..HIGHLIGHT_FONT_COLOR_CODE..") "..total.."%"
	end
	if modifier < 0 then
		return HIGHLIGHT_FONT_COLOR_CODE.."("..base.."%"..RED_FONT_COLOR_CODE..modifier.."%"..HIGHLIGHT_FONT_COLOR_CODE..") "..total.."%"
	end

	return base.."%"
end

local function tContains(table, item)
	local index = 1
	while table[index] do
		if (item == table[index]) then
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
		for i = 0, 31 do
			local index = GetPlayerBuff(i, 'HELPFUL')
			if index > -1 then
				BCS_Tooltip:SetPlayerBuff(index)
				local MAX_LINES = BCS_Tooltip:NumLines()

				for line = 1, MAX_LINES do
					local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
					if left:GetText() then
						local value = { strfind(left:GetText(), searchText) }
						if value[1] then
							return unpack(value)
						end
					end
				end
			end
		end
	elseif auraType == 'HARMFUL' then
		for i = 0, 6 do
			local index = GetPlayerBuff(i, auraType)
			if index > -1 then
				BCS_Tooltip:SetPlayerBuff(index)
				local MAX_LINES = BCS_Tooltip:NumLines()

				for line = 1, MAX_LINES do
					local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
					if left:GetText() then
						local value = { strfind(left:GetText(), searchText) }
						if value[1] then
							return unpack(value)
						end
					end
				end
			end
		end
	end
end

function BCS:GetHitRatings()
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
		-- Dark Desire
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

	if BCS.player.class == "HUNTER" then
		local _, _, _, _, rank = GetTalentInfo(3, 11) -- Survival, Surefooted
		melee_hit = melee_hit + rank
		ranged_hit = ranged_hit + rank
	end

	if BCS.player.class == "ROGUE" then
		local _, _, _, _, rank = GetTalentInfo(2, 6) -- Combat, Precision
		melee_hit = melee_hit + rank
	end

	if BCS.player.class == "PALADIN" then
		local _, _, _, _, rank = GetTalentInfo(2, 3) -- Protection, Precision
		melee_hit = melee_hit + rank
	end

	if BCS.player.class == "SHAMAN" then
		local _, _, _, _, rank = GetTalentInfo(3, 6) -- Restoration, Nature's Guidance
		melee_hit = melee_hit + rank
	end

	return {
		melee = melee_hit,
		ranged = ranged_hit,
		debuff = hit_debuff
	}
end

function BCS:GetItemIDFromLink(itemLink)
	if not itemLink then
		return
	end

	local foundID, _, itemID = string.find(itemLink, "item:(%d+)")
	if not foundID then
		return
	end

	return tonumber(itemID)
end

function BCS:GetWeaponSkillNameForSlot(slotId)
	local itemLink = GetInventoryItemLink("player", slotId)
	if not itemLink then
		return
	end

	local itemID = BCS:GetItemIDFromLink(itemLink)
	local _, _, _, _, _, weaponType = GetItemInfo(itemID)
	weaponType = string.gsub(weaponType, "^One%-Handed%s*", "")
	if weaponType == "Fist Weapons" then
		weaponType = "Unarmed"
	end
	if weaponType == "Fishing Pole" then
		weaponType = "Fishing"
	end

	return weaponType
end

function BCS:GetWeaponSkills()
	local main_hand_type = BCS:GetWeaponSkillNameForSlot(16)
	if not main_hand_type then
		main_hand_type = "Unarmed"
	end

	local off_hand_type = BCS:GetWeaponSkillNameForSlot(17)
	local ranged_type = BCS:GetWeaponSkillNameForSlot(18)

	local table = {}
	local MAX_SKILLS = GetNumSkillLines()
	for skill = 0, MAX_SKILLS do
		local skillName, _, _, skillRank, numTempPoints, skillModifier = GetSkillLineInfo(skill)
		if skillName and skillName == main_hand_type then
			table.main_hand = {
				type = main_hand_type,
				skill = skillRank,
				temp = numTempPoints,
				modifier = skillModifier,
				total = skillRank + numTempPoints + skillModifier
			}
		end

		if skillName and skillName == off_hand_type then
			table.off_hand = {
				type = off_hand_type,
				skill = skillRank,
				temp = numTempPoints,
				modifier = skillModifier,
				total = skillRank + numTempPoints + skillModifier
			}
		end

		if skillName and skillName == ranged_type then
			table.ranged = {
				type = ranged_type,
				skill = skillRank,
				temp = numTempPoints,
				modifier = skillModifier,
				total = skillRank + numTempPoints + skillModifier
			}
		end
	end

	return table
end

function BCS:GetGlancingBlow(targetDefense, attackerSkill, attackerLevel)
	local skillDiff = targetDefense - attackerSkill
	local glanceChance = 10 + (targetDefense - math.min(attackerLevel * 5, attackerSkill)) * 2

	local glanceLowEnd = 1.3 - 0.05 * skillDiff
	local glanceHighEnd = 1.2 - 0.03 * skillDiff

	glanceLowEnd = math.min(glanceLowEnd, 0.91)
	glanceHighEnd = math.min(glanceHighEnd, 0.99)
	glanceHighEnd = math.max(glanceHighEnd, 0.2)

	local glancePenalty = (1 - (glanceHighEnd + glanceLowEnd) / 2) * 100
	return glanceChance, glancePenalty
end

local function getMissChance(targetDefense, attackerSkill)
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

function BCS:GetMissChances(weaponSkills, hitRatings)
	local table = {}

	local dualWieldPenalty = weaponSkills.off_hand and 19 or 0

	local mainHandMiss = getMissChance(BCS.player.level * 5, weaponSkills.main_hand.total)
	local mainHandBossMiss, mainHandSuppression = getMissChance((BCS.player.level + 3) * 5, weaponSkills.main_hand.total)

	table.main_hand = {
		yellowVsLevel = math.max(0, mainHandMiss     + hitRatings.debuff - hitRatings.melee),
		yellowVsBoss  = math.max(0, mainHandBossMiss + hitRatings.debuff - math.max(0, hitRatings.melee - mainHandSuppression)),
		autoVsLevel   = math.max(0, mainHandMiss     + hitRatings.debuff + dualWieldPenalty - hitRatings.melee),
		autoVsBoss    = math.max(0, mainHandBossMiss + hitRatings.debuff + dualWieldPenalty - math.max(0, hitRatings.melee - mainHandSuppression)),
		bossSuppression = mainHandSuppression,
	}

	if weaponSkills.off_hand then
		local offhandMiss = getMissChance(BCS.player.level * 5, weaponSkills.off_hand.total)
		local offHandBossMiss, offHandSuppression = getMissChance((BCS.player.level + 3) * 5, weaponSkills.off_hand.total)

		table.off_hand = {
			autoVsLevel = math.max(0, offhandMiss     + hitRatings.debuff + dualWieldPenalty - hitRatings.melee),
			autoVsBoss  = math.max(0, offHandBossMiss + hitRatings.debuff + dualWieldPenalty - math.max(0, hitRatings.melee - offHandSuppression)),
			bossSuppression = offHandSuppression,
		}
	end

	if weaponSkills.ranged then
		local rangedMiss = getMissChance(BCS.player.level * 5, weaponSkills.ranged.total)
		local rangedBossMiss, rangedSuppression = getMissChance((BCS.player.level + 3) * 5, weaponSkills.ranged.total)

		table.ranged = {
			yellowVsLevel = rangedMiss     + hitRatings.debuff - hitRatings.ranged,
			yellowVsBoss  = rangedBossMiss + hitRatings.debuff - math.max(0, hitRatings.ranged - rangedSuppression),
			bossSuppression = rangedSuppression,
		}
	end

	return table
end

function BCS:GetSpellHitRating()
	local hit = 0
	local hit_fire = 0
	local hit_frost = 0
	local hit_arcane = 0
	local hit_shadow = 0
	local hit_Set_Bonus = {}

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

	if BCS.player.class == "MAGE" then
		local _, _, _, _, rank = GetTalentInfo(1, 2) -- Arcane, Arcane Focus
		hit_arcane = hit_arcane + rank * 2

		local _, _, _, _, rank = GetTalentInfo(3, 3) -- Frost, Elemental Precision
		hit_fire  = hit_fire + rank * 2
		hit_frost = hit_frost + rank * 2
	end

	if BCS.player.class == "PRIEST" then
		local _, _, _, _, rank = GetTalentInfo(3, 5) -- Shadow, Shadow Focus
		hit_shadow = hit_shadow + rank * 2
	end

	if BCS.player.class == "SHAMAN" then
		local _, _, _, _, rank = GetTalentInfo(3, 6) -- Restoration, Nature's Guidance
		hit = hit + rank
	end

	-- buffs
	local _, _, hitFromAura = BCS:GetPlayerAura(L["Spell hit chance increased by (%d+)%%."])
	if hitFromAura then
		hit = hit + tonumber(hitFromAura)
	end

	return hit, hit_fire, hit_frost, hit_arcane, hit_shadow
end

local function getSpellBookCrit()
	local _, _, offset, numSpells = GetSpellTabInfo(1)
	for spell = 1, numSpells do
		local currentPage = ceil(spell / SPELLS_PER_PAGE)
		local SpellID = spell + offset + (SPELLS_PER_PAGE * (currentPage - 1))

		BCS_Tooltip:SetSpell(SpellID, BOOKTYPE_SPELL)
		local MAX_LINES = BCS_Tooltip:NumLines()

		for line = 1, MAX_LINES do
			local left = getglobal(BCS_Prefix .. "TextLeft" .. line)
			if left:GetText() then
				local _, _, value = strfind(left:GetText(), L["([%d.]+)%% chance to crit"])
				if value then
					return tonumber(value)
				end
			end
		end
	end
end

function BCS:GetCritChance()
	local melee_crit = getSpellBookCrit()
	local ranged_crit = melee_crit


	if BCS.player.class == 'HUNTER' then
		local _, _, _, _, rank = GetTalentInfo(2, 4) -- Marksmanship, Lethal Shots
		ranged_crit = ranged_crit + rank
	end

	return melee_crit, ranged_crit
end

local function getCritSuppression(targetDefense, attackerSkill, attackerLevel)
	local baseSkill = math.min(attackerLevel * 5, attackerSkill)
	local diffSkill = baseSkill - targetDefense

	local critSuppression = 0
	if diffSkill < 0 then
		critSuppression = critSuppression + diffSkill * 0.2 -- 3% suppression vs bosses

		if diffSkill <= -15 then
			critSuppression = critSuppression + diffSkill * 0.12 -- 1.8% suppression to auras vs bosses
		end

		if attackerSkill > baseSkill then
			critSuppression = critSuppression + (baseSkill - attackerSkill) * 0.04 -- bonus weapon skill suppression
		end
	end

	return critSuppression * -1
end

function BCS:GetCritSuppressions(weaponSkills)
	local table = {}
	table.main_hand = {

	}
end

local function getTargetDodgeChance(targetDefense, attackerSkill)
	return 5 + (targetDefense - attackerSkill) * 0.1
end

function BCS:GetTargetDodgeChances(weaponSkills)
	local table = {}
	table.main_hand = {
		level = getTargetDodgeChance(BCS.player.level * 5, weaponSkills.main_hand.total),
		boss  = getTargetDodgeChance((BCS.player.level + 3) * 5, weaponSkills.main_hand.total),
	}

	if weaponSkills.off_hand then
		table.off_hand = {
			level = getTargetDodgeChance(BCS.player.level * 5, weaponSkills.off_hand.total),
			boss  = getTargetDodgeChance((BCS.player.level + 3) * 5, weaponSkills.off_hand.total),
		}
	end

	return table
end

local function getTargetBlockChance(targetDefense, attackerSkill)
	return math.min(5, 5 + (targetDefense - attackerSkill) * 0.1)
end

function BCS:GetTargetBlockChances(weaponSkills)
	local table = {}
	table.main_hand = {
		level = getTargetBlockChance(BCS.player.level * 5, weaponSkills.main_hand.total),
		boss  = getTargetBlockChance((BCS.player.level + 3) * 5, weaponSkills.main_hand.total),
	}

	if weaponSkills.off_hand then
		table.off_hand = {
			level = getTargetBlockChance(BCS.player.level * 5, weaponSkills.off_hand.total),
			boss  = getTargetBlockChance((BCS.player.level + 3) * 5, weaponSkills.off_hand.total),
		}
	end

	return table
end


local function getTargetParryChance(targetDefense, attackerSkill)
	local diffSkill = targetDefense - attackerSkill
	local parry = diffSkill * 0.1

	if diffSkill >= 10 then
		parry = parry + 7.5 -- boss parry chance is 14%
	end

	return parry
end

function BCS:GetTargetParryChanges(weaponSkills)
	local table = {}
	table.main_hand = {
		level = getTargetParryChance(BCS.player.level * 5, weaponSkills.main_hand.total),
		boss  = getTargetParryChance((BCS.player.level + 3) * 5, weaponSkills.main_hand.total),
	}

	if weaponSkills.off_hand then
		table.off_hand = {
			level = getTargetParryChance(BCS.player.level * 5, weaponSkills.off_hand.total),
			boss  = getTargetParryChance((BCS.player.level + 3) * 5, weaponSkills.off_hand.total),
		}
	end

	return table
end

function BCS:GetSpellCritChance()
	-- school crit: most likely never
	local Crit_Set_Bonus = {}
	local spellCrit = 0;
	local _, intellect = UnitStat("player", 4)

	-- values from theorycraft / http://wow.allakhazam.com/forum.html?forum=21&mid=1157230638252681707
	if BCS.player.class == "MAGE" then
		spellCrit = 0.2 + (intellect / 59.5)
	elseif BCS.player.class == "WARLOCK" then
		spellCrit = 1.7 + (intellect / 60.6)
	elseif BCS.player.class == "PRIEST" then
		spellCrit = 0.8 + (intellect / 59.56)
	elseif BCS.player.class == "DRUID" then
		spellCrit = 1.8 + (intellect / 60)
	elseif BCS.player.class == "SHAMAN" then
		spellCrit = 1.8 + (intellect / 59.2)
	elseif BCS.player.class == "PALADIN" then
		spellCrit = intellect / 29.5
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
		local _, _, _, critFromAura = strfind(lineText, L["Melee critical-hit chance reduced by (%d+)%%.\r\nSpell critical-hit chance reduced by (%d+)%%."])
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

	if BCS.player.class == "PRIEST" then
		local _, _, _, _, rank = GetTalentInfo(2, 14) -- Holy, Spiritual Guidance
		local _, spirit = UnitStat("player", 5)
		spellPower = spellPower + floor(rank * 0.05 * spirit)
	end

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

	-- Sweet Surprise
	local _, _, healPowerFromAura = BCS:GetPlayerAura(L["Healing done by magical spells is increased by up to (%d+)."])
	if healPowerFromAura then
		healPower = healPower + tonumber(healPowerFromAura)
	end

	return healPower
end

function BCS:GetRegenMPPerSpirit()
	local _, spirit = UnitStat("player", 5)

	if BCS.player.class == "DRUID" then
		return spirit / 5 + 15
	end
	if BCS.player.class == "HUNTER" then
		return spirit / 5 + 15
	end
	if BCS.player.class == "MAGE" then
		return spirit / 4 + 12.5
	end
	if BCS.player.class == "PALADIN" then
		return spirit / 5 + 15
	end
	if BCS.player.class == "PRIEST" then
		return spirit / 4 + 12.5
	end
	if BCS.player.class == "SHAMAN" then
		return spirit / 5 + 17
	end
	if BCS.player.class == "WARLOCK" then
		return spirit / 5 + 15
	end

	return 0
end

function BCS:GetManaRegen()
	local power_regen = BCS:GetRegenMPPerSpirit()

	local base = power_regen
	local casting = power_regen / 100

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

	BCS:IterateAuras(AURA_BUFF, function(lineText)
		local found = strfind(lineText, L["Increases hitpoints by 300. 15%% haste to melee attacks. 10 mana regen every 5 seconds."])
		if found then
			mp5 = mp5 + 10
		end

		local _, _, mp5FromAura = strfind(lineText, L["Restores (%d+) mana every 5 seconds."])
		if mp5FromAura then
			mp5 = mp5 + tonumber(mp5FromAura)
		end

		local _, _, mp2FromAura = strfind(lineText, L["Gain (%d+) mana every 2 seconds."])
		if mp2FromAura then
			mp5 = mp5 + tonumber(mp2FromAura) * 2.5
		end
	end)

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
		if index < 0 then
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
