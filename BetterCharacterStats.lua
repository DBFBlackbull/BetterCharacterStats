BCS = BCS or {}
BCSConfig = BCSConfig or {}

local L, IndexLeft, IndexRight
L = BCS.L

BCS.PLAYERSTAT_DROPDOWN_OPTIONS = {
	"PLAYERSTAT_BASE_STATS",
	"PLAYERSTAT_MELEE_COMBAT",
	"PLAYERSTAT_RANGED_COMBAT",
	"PLAYERSTAT_SPELL_COMBAT",
	"PLAYERSTAT_DEFENSES",
}

BCS.SPELLHIT = {
	-- soon(tm)
}

BCS.PaperDollFrame = PaperDollFrame

BCS.Debug = false
BCS.DebugStack = {}

function BCS:AddDoubleLine(leftText, rightText)
	GameTooltip:AddDoubleLine(leftText, BCS:ColorText(HIGHLIGHT_FONT_COLOR_CODE, rightText))
end

function BCS:DebugTrace(start, limit)
	BCS.Debug = nil
	local length = getn(BCS.DebugStack)
	if not start then start = 1 end
	if start > length then start = length end
	if not limit then limit = start + 30 end
	
	BCS:Print("length: " .. length)
	BCS:Print("start: " .. start)
	BCS:Print("limit: " .. limit)
	
	for i = start, length, 1 do
		BCS:Print("[" .. i .. "] Event: " .. BCS.DebugStack[i].E)
		BCS:Print(format(
			"[%d] `- Arguments: %s, %s, %s, %s, %s",
			i,
			BCS.DebugStack[i].arg1,
			BCS.DebugStack[i].arg2,
			BCS.DebugStack[i].arg3,
			BCS.DebugStack[i].arg4,
			BCS.DebugStack[i].arg5
		))
		if i >= limit then i = length end
	end
	
end

function BCS:Print(message)
	ChatFrame2:AddMessage("[BCS] " .. message, 0.63, 0.86, 1.0)
end

function BCS:OnLoad()
	CharacterAttributesFrame:Hide()
	PaperDollFrame:UnregisterEvent('UNIT_DAMAGE')
	PaperDollFrame:UnregisterEvent('PLAYER_DAMAGE_DONE_MODS')
	PaperDollFrame:UnregisterEvent('UNIT_ATTACK_SPEED')
	PaperDollFrame:UnregisterEvent('UNIT_RANGEDDAMAGE')
	PaperDollFrame:UnregisterEvent('UNIT_ATTACK')
	PaperDollFrame:UnregisterEvent('UNIT_STATS')
	PaperDollFrame:UnregisterEvent('UNIT_ATTACK_POWER')
	PaperDollFrame:UnregisterEvent('UNIT_RANGED_ATTACK_POWER')
	
	self.Frame = BCSFrame
	self.needUpdate = nil

	self.Frame:RegisterEvent("ADDON_LOADED")
	self.Frame:RegisterEvent("UNIT_INVENTORY_CHANGED") -- fires when equipment changes
	self.Frame:RegisterEvent("CHARACTER_POINTS_CHANGED") -- fires when learning talent
	self.Frame:RegisterEvent("PLAYER_AURAS_CHANGED") -- buffs/warrior stances
	self.Frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	self.Frame:RegisterEvent("PLAYER_LEVEL_UP")

	local _, unitClass = UnitClass("player")
	self.player = {
		name = UnitName("player"),
		class = unitClass,
		level = 0,
		levelDefense = 0,
		bossDefense = 0
	}
end

function BCS:OnEvent()
	if event == "PLAYER_AURAS_CHANGED" or event == "CHARACTER_POINTS_CHANGED" then
		if BCS.PaperDollFrame:IsVisible() then
			return BCS:UpdateStats()
		end

		BCS.needUpdate = true
		return
	end

	if event == "UNIT_INVENTORY_CHANGED" and arg1 == "player" then
		if BCS.PaperDollFrame:IsVisible() then
			return BCS:UpdateStats()
		end

		BCS.needUpdate = true
		return
	end

	if event == "ADDON_LOADED" and arg1 == "BetterCharacterStats" then
		IndexLeft = BCSConfig["DropdownLeft"] or BCS.PLAYERSTAT_DROPDOWN_OPTIONS[1]
		IndexRight = BCSConfig["DropdownRight"] or BCS.PLAYERSTAT_DROPDOWN_OPTIONS[2]

		UIDropDownMenu_SetSelectedValue(PlayerStatFrameLeftDropDown, IndexLeft)
		UIDropDownMenu_SetSelectedValue(PlayerStatFrameRightDropDown, IndexRight)
		return
	end

	if event == "PLAYER_ENTERING_WORLD" then
		BCS.player.level = UnitLevel("player")
		BCS.player.levelDefense = BCS.player.level * 5
		BCS.player.bossDefense = (BCS.player.level + 3) * 5
		return
	end

	if event == "PLAYER_LEVEL_UP" then
		BCS.player.level = arg1
		BCS.player.levelDefense = BCS.player.level * 5
		BCS.player.bossDefense =  (BCS.player.level + 3) * 5
	end
end

function BCS:OnShow()
	if BCS.needUpdate then
		BCS.needUpdate = nil
		BCS:UpdateStats()
	end
end

-- debugging / profiling
--local avgV = {}
--local avg = 0
function BCS:UpdateStats()
	--[[if BCS.Debug then
		local e = event or "nil"
		BCS:Print("Update due to " .. e)
	end
	local beginTime = debugprofilestop()]]
	
	BCS:UpdatePaperdollStats("PlayerStatFrameLeft", IndexLeft)
	BCS:UpdatePaperdollStats("PlayerStatFrameRight", IndexRight)

	--[[local timeUsed = debugprofilestop()-beginTime
	table.insert(avgV, timeUsed)
	avg = 0
	
	for i,v in ipairs(avgV) do
		avg = avg + v
	end
	avg = avg / getn(avgV)
	
	BCS:Print(format("Average: %d (%d results), Exact: %d", avg, getn(avgV), timeUsed))]]
end

function BCS:SetStat(statFrame, statIndex)
	local label = getglobal(statFrame:GetName().."Label")
	local text = getglobal(statFrame:GetName().."StatText")
	local stat
	local effectiveStat
	local posBuff
	local negBuff
	local statIndexTable = {
		"STRENGTH",
		"AGILITY",
		"STAMINA",
		"INTELLECT",
		"SPIRIT",
	}
	
	statFrame:SetScript("OnEnter", function()
		PaperDollStatTooltip("player", statIndexTable[statIndex])
	end)
	
	statFrame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	
	label:SetText(TEXT(getglobal("SPELL_STAT"..(statIndex-1).."_NAME"))..":")
	stat, effectiveStat, posBuff, negBuff = UnitStat("player", statIndex)
	
	-- Set the tooltip text
	local tooltipText = HIGHLIGHT_FONT_COLOR_CODE..getglobal("SPELL_STAT"..(statIndex-1).."_NAME").." "

	if ( ( posBuff == 0 ) and ( negBuff == 0 ) ) then
		text:SetText(effectiveStat)
		statFrame.tooltip = tooltipText..effectiveStat..FONT_COLOR_CODE_CLOSE
	else 
		tooltipText = tooltipText..effectiveStat
		if ( posBuff > 0 or negBuff < 0 ) then
			tooltipText = tooltipText.." ("..(stat - posBuff - negBuff)..FONT_COLOR_CODE_CLOSE
		end
		if ( posBuff > 0 ) then
			tooltipText = tooltipText..FONT_COLOR_CODE_CLOSE..GREEN_FONT_COLOR_CODE.."+"..posBuff..FONT_COLOR_CODE_CLOSE
		end
		if ( negBuff < 0 ) then
			tooltipText = tooltipText..RED_FONT_COLOR_CODE.." "..negBuff..FONT_COLOR_CODE_CLOSE
		end
		if ( posBuff > 0 or negBuff < 0 ) then
			tooltipText = tooltipText..HIGHLIGHT_FONT_COLOR_CODE..")"..FONT_COLOR_CODE_CLOSE
		end
		statFrame.tooltip = tooltipText

		-- If there are any negative buffs then show the main number in red even if there are
		-- positive buffs. Otherwise show in green.
		if ( negBuff < 0 ) then
			text:SetText(RED_FONT_COLOR_CODE..effectiveStat..FONT_COLOR_CODE_CLOSE)
		else
			text:SetText(GREEN_FONT_COLOR_CODE..effectiveStat..FONT_COLOR_CODE_CLOSE)
		end
	end
end

function BCS:SetArmor(statFrame)

	local base, effectiveArmor, armor, posBuff, negBuff = UnitArmor("player")
	local totalBufs = posBuff + negBuff
	local frame = statFrame
	local label = getglobal(frame:GetName() .. "Label")
	local text = getglobal(frame:GetName() .. "StatText")

	PaperDollFormatStat(ARMOR, base, posBuff, negBuff, frame, text)
	label:SetText(TEXT(ARMOR_COLON))
	
	local armorReduction = effectiveArmor/((85 * BCS.player.level) + 400)
	armorReduction = 100 * (armorReduction/(armorReduction + 1))
	
	frame.tooltipSubtext = format(ARMOR_TOOLTIP, BCS.player.level, armorReduction)
	
	frame:SetScript("OnEnter", function()
		GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
		GameTooltip:SetText(this.tooltip)
		GameTooltip:AddLine(this.tooltipSubtext, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1)
		GameTooltip:Show()
	end)
	frame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	
end

function BCS:SetDamage(statFrame)
	local label = getglobal(statFrame:GetName() .. "Label")
	label:SetText(TEXT(DAMAGE_COLON))
	local damageText = getglobal(statFrame:GetName() .. "StatText")
	local damageFrame = statFrame
	
	damageFrame:SetScript("OnEnter", CharacterDamageFrame_OnEnter)
	damageFrame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	local speed, offhandSpeed = UnitAttackSpeed("player")
	
	local minDamage
	local maxDamage
	local minOffHandDamage
	local maxOffHandDamage 
	local physicalBonusPos
	local physicalBonusNeg
	local percent
	minDamage, maxDamage, minOffHandDamage, maxOffHandDamage, physicalBonusPos, physicalBonusNeg, percent = UnitDamage("player")
	local displayMin = max(floor(minDamage),1)
	local displayMax = max(ceil(maxDamage),1)

	minDamage = (minDamage / percent) - physicalBonusPos - physicalBonusNeg
	maxDamage = (maxDamage / percent) - physicalBonusPos - physicalBonusNeg

	local baseDamage = (minDamage + maxDamage) * 0.5
	local fullDamage = (baseDamage + physicalBonusPos + physicalBonusNeg) * percent
	local totalBonus = (fullDamage - baseDamage)
	local damagePerSecond = (max(fullDamage,1) / speed)
	local damageTooltip = max(floor(minDamage),1).." - "..max(ceil(maxDamage),1)
	
	local colorPos = "|cff20ff20"
	local colorNeg = "|cffff2020"
	if ( totalBonus == 0 ) then
		if ( ( displayMin < 100 ) and ( displayMax < 100 ) ) then 
			damageText:SetText(displayMin.." - "..displayMax)	
		else
			damageText:SetText(displayMin.."-"..displayMax)
		end
	else
		
		local color
		if ( totalBonus > 0 ) then
			color = colorPos
		else
			color = colorNeg
		end
		if ( ( displayMin < 100 ) and ( displayMax < 100 ) ) then 
			damageText:SetText(color..displayMin.." - "..displayMax.."|r")
		else
			damageText:SetText(color..displayMin.."-"..displayMax.."|r")
		end
		if ( physicalBonusPos > 0 ) then
			damageTooltip = damageTooltip..colorPos.." +"..physicalBonusPos.."|r"
		end
		if ( physicalBonusNeg < 0 ) then
			damageTooltip = damageTooltip..colorNeg.." "..physicalBonusNeg.."|r"
		end
		if ( percent > 1 ) then
			damageTooltip = damageTooltip..colorPos.." x"..floor(percent*100+0.5).."%|r"
		elseif ( percent < 1 ) then
			damageTooltip = damageTooltip..colorNeg.." x"..floor(percent*100+0.5).."%|r"
		end
		
	end
	damageFrame.damage = damageTooltip
	damageFrame.attackSpeed = speed
	damageFrame.dps = damagePerSecond
	
	-- If there's an offhand speed then add the offhand info to the tooltip
	if ( offhandSpeed ) then
		minOffHandDamage = (minOffHandDamage / percent) - physicalBonusPos - physicalBonusNeg
		maxOffHandDamage = (maxOffHandDamage / percent) - physicalBonusPos - physicalBonusNeg

		local offhandBaseDamage = (minOffHandDamage + maxOffHandDamage) * 0.5
		local offhandFullDamage = (offhandBaseDamage + physicalBonusPos + physicalBonusNeg) * percent
		local offhandDamagePerSecond = (max(offhandFullDamage,1) / offhandSpeed)
		local offhandDamageTooltip = max(floor(minOffHandDamage),1).." - "..max(ceil(maxOffHandDamage),1)
		if ( physicalBonusPos > 0 ) then
			offhandDamageTooltip = offhandDamageTooltip..colorPos.." +"..physicalBonusPos.."|r"
		end
		if ( physicalBonusNeg < 0 ) then
			offhandDamageTooltip = offhandDamageTooltip..colorNeg.." "..physicalBonusNeg.."|r"
		end
		if ( percent > 1 ) then
			offhandDamageTooltip = offhandDamageTooltip..colorPos.." x"..floor(percent*100+0.5).."%|r"
		elseif ( percent < 1 ) then
			offhandDamageTooltip = offhandDamageTooltip..colorNeg.." x"..floor(percent*100+0.5).."%|r"
		end
		damageFrame.offhandDamage = offhandDamageTooltip
		damageFrame.offhandAttackSpeed = offhandSpeed
		damageFrame.offhandDps = offhandDamagePerSecond
	else
		damageFrame.offhandAttackSpeed = nil
	end
	
end

function BCS:SetAttackSpeed(statFrame)
	local speed, offhandSpeed = UnitAttackSpeed("player")
	speed = format("%.2f", speed)
	if ( offhandSpeed ) then
		offhandSpeed = format("%.2f", offhandSpeed)
	end
	local text	
	if ( offhandSpeed ) then
		text = speed.." / "..offhandSpeed
	else
		text = speed
	end
	
	local label = getglobal(statFrame:GetName() .. "Label")
	local value = getglobal(statFrame:GetName() .. "StatText")
	
	label:SetText(TEXT(SPEED)..":")
	value:SetText(text)

	--[[statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, ATTACK_SPEED).." "..text..FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = format(CR_HASTE_RATING_TOOLTIP, GetCombatRating(CR_HASTE_MELEE), GetCombatRatingBonus(CR_HASTE_MELEE));]]
	
	statFrame:Show()
end

function BCS:SetAttackPower(statFrame)
	local base, posBuff, negBuff = UnitAttackPower("player")

	local frame = statFrame 
	local text = getglobal(statFrame:GetName() .. "StatText")
	local label = getglobal(statFrame:GetName() .. "Label")
	
	label:SetText(TEXT(ATTACK_POWER_COLON))

	PaperDollFormatStat(MELEE_ATTACK_POWER, base, posBuff, negBuff, frame, text)
	frame.tooltipSubtext = format(L.MELEE_ATTACK_POWER_TOOLTIP, max(0,base + posBuff + negBuff)/ATTACK_POWER_MAGIC_NUMBER);
	frame:SetScript("OnEnter", function()
		GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
		GameTooltip:SetText(this.tooltip)
		GameTooltip:AddLine(this.tooltipSubtext, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1)
		GameTooltip:Show()
	end)
	frame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
end

function BCS:SetSpellPower(statFrame)
	local frame = statFrame 
	local text = getglobal(statFrame:GetName() .. "StatText")
	local label = getglobal(statFrame:GetName() .. "Label")
	
	local power, schools = BCS:GetSpellPower();

	label:SetText(L.SPELL_POWER_COLON)
	text:SetText(power)

	frame.tooltip = format(L["SPELL_POWER_TOOLTIP_HEADER"], power)
	frame:SetScript("OnEnter", function()
		GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
		GameTooltip:SetText(this.tooltip)
		GameTooltip:AddDoubleLine("Arcane", schools["Arcane"])
		GameTooltip:AddDoubleLine("Fire", schools["Fire"])
		GameTooltip:AddDoubleLine("Frost", schools["Frost"])
		GameTooltip:AddDoubleLine("Holy", schools["Holy"])
		GameTooltip:AddDoubleLine("Nature", schools["Nature"])
		GameTooltip:AddDoubleLine("Shadow", schools["Shadow"])
		GameTooltip:Show()
	end)
	frame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
end

function BCS:SetRating(statFrame, ratingType)
	local frame = statFrame 
	local text = getglobal(statFrame:GetName() .. "StatText")
	local label = getglobal(statFrame:GetName() .. "Label")
	
	label:SetText(L.MELEE_HIT_RATING_COLON)

	local playerLevel = BCS.player.level
	if ratingType == "MELEE" then
		local weaponSkills = BCS:GetWeaponSkills()
		local hitRatings = BCS:GetHitRatings()
		local missChanges = BCS:GetMissChances(weaponSkills, hitRatings)

		local mainHandModifier = weaponSkills.main_hand.temp+weaponSkills.main_hand.modifier
		local hitTotal = hitRatings.melee-hitRatings.debuff
		local hitChanceString = BCS:ModifierColor(mainHandModifier, weaponSkills.main_hand.total)
		if weaponSkills.off_hand then
			hitChanceString = hitChanceString .. " / " .. BCS:ModifierColor(weaponSkills.off_hand.temp+weaponSkills.off_hand.modifier, weaponSkills.off_hand.total)
		end
		hitChanceString = hitChanceString .. " / " .. BCS:ModifierColor(hitRatings.debuff*-1, hitTotal.."%")
		text:SetText(hitChanceString)

		frame:SetScript("OnEnter", function()
			GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
			GameTooltip:SetText(BCS:ColorText(HIGHLIGHT_FONT_COLOR_CODE, "Main Hand"))
			BCS:AddDoubleLine(format("Weapon skill (%s):", weaponSkills.main_hand.type), BCS:ModifierText(mainHandModifier, weaponSkills.main_hand.skill, weaponSkills.main_hand.total))
			BCS:AddDoubleLine("Hit Chance:", BCS:ModifierTextPercent(hitRatings.debuff*-1, hitRatings.melee, hitTotal))
			BCS:AddDoubleLine("Hit Suppression (vs Boss):", missChanges.main_hand.bossSuppression.."%")
			if weaponSkills.off_hand then
				GameTooltip:AddLine(BCS:ColorText(HIGHLIGHT_FONT_COLOR_CODE, "Yellow Attacks"))
				BCS:AddDoubleLine("Miss Chance (vs Boss):", missChanges.main_hand.yellowVsBoss.."%")
				BCS:AddDoubleLine(format("Miss Chance (vs level %d):", playerLevel), missChanges.main_hand.yellowVsLevel.."%")
				GameTooltip:AddLine(BCS:ColorText(HIGHLIGHT_FONT_COLOR_CODE, "Auto attacks"))
			end

			BCS:AddDoubleLine("Miss Chance (vs Boss):", missChanges.main_hand.autoVsBoss.."%")
			BCS:AddDoubleLine(format("Miss Chance (vs level %d):", playerLevel), missChanges.main_hand.autoVsLevel.."%")

			if weaponSkills.off_hand then
				local offHandModifier = weaponSkills.off_hand.temp+weaponSkills.off_hand.modifier

				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(BCS:ColorText(HIGHLIGHT_FONT_COLOR_CODE, "Off Hand"))
				BCS:AddDoubleLine(format("Weapon skill (%s):", weaponSkills.off_hand.type), BCS:ModifierText(offHandModifier, weaponSkills.off_hand.skill, weaponSkills.off_hand.total))
				BCS:AddDoubleLine("Hit Chance:", BCS:ModifierTextPercent(hitRatings.debuff*-1, hitRatings.melee, hitTotal))
				BCS:AddDoubleLine("Hit Suppression (vs Boss):", missChanges.off_hand.bossSuppression.."%")
				BCS:AddDoubleLine("Miss Chance (vs Boss):", missChanges.off_hand.autoVsBoss.."%")
				BCS:AddDoubleLine(format("Miss Chance (vs level %d):", playerLevel), missChanges.off_hand.autoVsLevel.."%")
			end
			GameTooltip:Show()
		end)
		frame:SetScript("OnLeave", function()
			GameTooltip:Hide()
		end)
		return
	end

	if ratingType == "RANGED" then
		local weaponSkills = BCS:GetWeaponSkills()
		if not weaponSkills.ranged then
			text:SetText(NOT_APPLICABLE)
			return
		end
		local hitRatings = BCS:GetHitRatings()
		local missChanges = BCS:GetMissChances(weaponSkills, hitRatings)

		local rangedModifier = weaponSkills.ranged.temp+weaponSkills.ranged.modifier
		local hitTotal = hitRatings.ranged-hitRatings.debuff
		local hitChanceString = format("%s / %s", BCS:ModifierColor(rangedModifier, weaponSkills.ranged.total), BCS:ModifierColor(hitRatings.debuff*-1, hitTotal.."%"))
		text:SetText(hitChanceString)

		frame:SetScript("OnEnter", function()
			GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
			GameTooltip:SetText(BCS:ColorText(HIGHLIGHT_FONT_COLOR_CODE, "Ranged"))
			BCS:AddDoubleLine(format("Weapon skill (%s):", weaponSkills.ranged.type), BCS:ModifierText(rangedModifier, weaponSkills.ranged.skill, weaponSkills.ranged.total))
			BCS:AddDoubleLine("Hit Chance:", BCS:ModifierTextPercent(hitRatings.ranged*-1, hitRatings.ranged, hitTotal))
			BCS:AddDoubleLine("Hit Suppression (vs Boss):", missChanges.ranged.bossSuppression.."%")
			BCS:AddDoubleLine("Miss Chance (vs Boss):", missChanges.ranged.yellowVsBoss.."%")
			BCS:AddDoubleLine(format("Miss Chance (vs level %d):", playerLevel), missChanges.ranged.yellowVsLevel.."%")
			GameTooltip:Show()
		end)
		frame:SetScript("OnLeave", function()
			GameTooltip:Hide()
		end)
	end
	if ratingType == "SPELL" then
		local spell_hit, spell_hit_fire, spell_hit_frost, spell_hit_arcane, spell_hit_shadow = BCS:GetSpellHitRating()
		--[[if BCS.SPELLHIT[BCS.playerClass] then
			if spell_hit < BCS.SPELLHIT[BCS.playerClass][1] then
				spell_hit = colorNeg .. spell_hit .. "%|r"
			elseif spell_hit >= BCS.SPELLHIT[BCS.playerClass][2] then
				spell_hit = colorPos .. spell_hit .. "%|r"
			else
				spell_hit = spell_hit .. "%"
			end
		else
			spell_hit = spell_hit .. "%"
		end]]
		
		if spell_hit_fire > 0 or spell_hit_frost > 0 or spell_hit_arcane > 0 or spell_hit_shadow > 0 then
			-- got spell hit from talents
			local spell_hit_other, spell_hit_other_type
			
			spell_hit_other = 0 
			spell_hit_other_type = ""
			
			if spell_hit_fire > spell_hit_other then
				spell_hit_other = spell_hit_fire
				spell_hit_other_type = L.SPELL_SCHOOL_FIRE
			end
			if spell_hit_frost > spell_hit_other then
				spell_hit_other = spell_hit_frost
				spell_hit_other_type = L.SPELL_SCHOOL_FROST
			end
			if spell_hit_arcane > spell_hit_other then
				spell_hit_other = spell_hit_arcane
				spell_hit_other_type = L.SPELL_SCHOOL_ARCANE
			end
			if spell_hit_shadow > spell_hit_other then
				spell_hit_other = spell_hit_shadow
				spell_hit_other_type = L.SPELL_SCHOOL_SHADOW
			end
			
			frame.tooltip = format(L.SPELL_HIT_SECONDARY_TOOLTIP, spell_hit+spell_hit_other, spell_hit, spell_hit_other, spell_hit_other_type)
			text:SetText(spell_hit+spell_hit_other.."%")
		else
			frame.tooltip = L.SPELL_HIT_TOOLTIP
			text:SetText(spell_hit.."%")
		end
		
		-- class specific tooltip
		--if L[BCS.player.class .. "_SPELL_HIT_TOOLTIP"] then
		--	frame.tooltipSubtext = L[BCS.playerClass .. "_SPELL_HIT_TOOLTIP"]
		--end

		if frame.tooltip then
			frame:SetScript("OnEnter", function()
				GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
				GameTooltip:SetText(this.tooltip)
				GameTooltip:AddLine(this.tooltipSubtext, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1)
				GameTooltip:Show()
			end)
			frame:SetScript("OnLeave", function()
				GameTooltip:Hide()
			end)
		end
	end
end

function BCS:SetMeleeCritChance(statFrame)
	local frame = statFrame 
	local text = getglobal(statFrame:GetName() .. "StatText")
	local label = getglobal(statFrame:GetName() .. "Label")

	local weaponSkills = BCS:GetWeaponSkills()

	label:SetText(L.MELEE_CRIT_COLON)
	local critChances = BCS:GetCritChances(weaponSkills)
	local colonValue = format("%.2f%%", critChances.main_hand)

	if critChances.off_hand then
		colonValue = format("%s / %.2f%%", colonValue, critChances.off_hand)
	end
	text:SetText(colonValue)
	-- TODO check off hand crit chance

	local hitRatings = BCS:GetHitRatings()
	local missChanges = BCS:GetMissChances(weaponSkills, hitRatings)
	local targetDodgeChanges = BCS:GetTargetDodgeChances(weaponSkills)
	local targetParryChanges = BCS:GetTargetParryChanges(weaponSkills)
	local glancingBlows = BCS:GetGlancingBlows(weaponSkills)
	local targetBlockChanges = BCS:GetTargetBlockChances(weaponSkills)
	local critSuppressions = BCS:GetBossCritSuppressions(weaponSkills)

	frame:SetScript("OnEnter", function()
		GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
		GameTooltip:SetText(BCS:ColorText(HIGHLIGHT_FONT_COLOR_CODE, "Main Hand"))
		BCS:AddDoubleLine(format("Crit Chance (vs level %d):", BCS.player.level), format("%.2f%%", critChances.main_hand))
		BCS:AddDoubleLine("Crit Suppression (vs Boss):", format("%.2f%%", critSuppressions.main_hand))
		BCS:AddDoubleLine("Crit Chance (vs Boss):", format("%.2f%%", critChances.main_hand - critSuppressions.main_hand))

		if weaponSkills.off_hand then
			GameTooltip:AddLine(BCS:ColorText(HIGHLIGHT_FONT_COLOR_CODE, "Yellow Attacks"))
			local mainHandCritCapBehind = 100
					- missChanges.main_hand.yellowVsBoss
					- targetDodgeChanges.main_hand.boss
					- glancingBlows.main_hand.boss.chance

			local mainHandCritCapFront = mainHandCritCapBehind
					- targetParryChanges.main_hand.boss
					- targetBlockChanges.main_hand.boss

			BCS:AddDoubleLine("Crit Cap (vs Boss Behind):", format("%.2f%%",mainHandCritCapBehind))
			BCS:AddDoubleLine("Crit Cap (vs Boss Front):", format("%.2f%%",mainHandCritCapFront))
			GameTooltip:AddLine(BCS:ColorText(HIGHLIGHT_FONT_COLOR_CODE, "Auto attacks"))
		end
		local mainHandCritCapBehind = 100
				- missChanges.main_hand.autoVsBoss
				- targetDodgeChanges.main_hand.boss
				- glancingBlows.main_hand.boss.chance

		local mainHandCritCapFront = mainHandCritCapBehind
				- targetParryChanges.main_hand.boss
				- targetBlockChanges.main_hand.boss

		BCS:AddDoubleLine("Crit Cap (vs Boss Behind):", format("%.2f%%",mainHandCritCapBehind))
		BCS:AddDoubleLine("Crit Cap (vs Boss Front):", format("%.2f%%",mainHandCritCapFront))

		if weaponSkills.off_hand then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(BCS:ColorText(HIGHLIGHT_FONT_COLOR_CODE, "Off Hand"))
			BCS:AddDoubleLine(format("Crit Chance (vs level %d):", BCS.player.level), format("%.2f%%", critChances.off_hand))
			BCS:AddDoubleLine("Crit Suppression (vs Boss):", format("%.2f%%", critSuppressions.off_hand))
			BCS:AddDoubleLine("Crit Chance (vs Boss):", format("%.2f%%", critChances.off_hand - critSuppressions.off_hand))

			local offHandCritCapBehind = 100
					- missChanges.off_hand.autoVsBoss
					- targetDodgeChanges.off_hand.boss
					- glancingBlows.off_hand.boss.chance

			local offHandCritCapFront = offHandCritCapBehind
					- targetParryChanges.off_hand.boss
					- targetBlockChanges.off_hand.boss

			BCS:AddDoubleLine("Crit Cap (vs Boss Behind):", format("%.2f%%", offHandCritCapBehind))
			BCS:AddDoubleLine("Crit Cap (vs Boss Front):", format("%.2f%%", offHandCritCapFront))
		end

		GameTooltip:Show()
	end)
	frame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
end

function BCS:SetGlancingBlow(statFrame)
	local frame = statFrame
	local text = getglobal(statFrame:GetName() .. "StatText")
	local label = getglobal(statFrame:GetName() .. "Label")

	local weaponSkills = BCS:GetWeaponSkills()
	local glancingBlows = BCS:GetGlancingBlows(weaponSkills)
	local colonValue = format("%d%%", glancingBlows.main_hand.boss.penalty)

	if glancingBlows.off_hand then
		colonValue = format("%s / %d%%", colonValue, glancingBlows.off_hand.boss.penalty)
	end

	label:SetText(L.MELEE_GLANCING_BLOW_COLON)
	text:SetText(colonValue)

	frame:SetScript("OnEnter", function()
		GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
		GameTooltip:SetText(BCS:ColorText(HIGHLIGHT_FONT_COLOR_CODE, L.GLANCING_BLOW_TOOLTIP_HEADER))
		GameTooltip:AddLine(L.GLANCING_BLOW_TOOLTIP, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1)
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(BCS:ColorText(HIGHLIGHT_FONT_COLOR_CODE, "Main Hand"))
		local mainHandModifier = weaponSkills.main_hand.modifier+weaponSkills.main_hand.temp
		BCS:AddDoubleLine(format("Weapon skill (%s):", weaponSkills.main_hand.type), BCS:ModifierText(mainHandModifier, weaponSkills.main_hand.skill, weaponSkills.main_hand.total))
		BCS:AddDoubleLine("Glancing Blow Chance (vs Boss):", format("%.1f%%",glancingBlows.main_hand.boss.chance))
		BCS:AddDoubleLine("Glancing Blow Penalty (vs Boss):", format("%.1f%%",glancingBlows.main_hand.boss.penalty))
		if weaponSkills.off_hand then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(BCS:ColorText(HIGHLIGHT_FONT_COLOR_CODE, "Off Hand"))
			local offHandModifier = weaponSkills.off_hand.modifier+weaponSkills.off_hand.temp
			BCS:AddDoubleLine(format("Weapon skill (%s):", weaponSkills.off_hand.type), BCS:ModifierText(offHandModifier, weaponSkills.off_hand.skill, weaponSkills.off_hand.total))
			BCS:AddDoubleLine("Glancing Blow Chance (vs Boss):", format("%.1f%%",glancingBlows.off_hand.boss.chance))
			BCS:AddDoubleLine("Glancing Blow Penalty (vs Boss):", format("%.1f%%",glancingBlows.off_hand.boss.penalty))
		end
		GameTooltip:Show()
	end)
	frame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
end


function BCS:SetSpellCritChance(statFrame)
	local text = getglobal(statFrame:GetName() .. "StatText")
	local label = getglobal(statFrame:GetName() .. "Label")
	
	label:SetText(L.SPELL_CRIT_COLON)
	text:SetText(format("%.2f%%", BCS:GetSpellCritChance()))
end

function BCS:SetRangedCritChance(statFrame)
	local text = getglobal(statFrame:GetName() .. "StatText")
	local label = getglobal(statFrame:GetName() .. "Label")
	
	label:SetText(L.RANGED_CRIT_COLON)
	local weaponSkills = BCS:GetWeaponSkills()
	if not weaponSkills.ranged then
		text:SetText(NOT_APPLICABLE)
		return
	end

	local critChances = BCS:GetCritChances(weaponSkills)
	text:SetText(format("%.2f%%", critChances.ranged))
end

function BCS:SetHealing(statFrame)
	local frame = statFrame 
	local text = getglobal(statFrame:GetName() .. "StatText")
	local label = getglobal(statFrame:GetName() .. "Label")
	
	local power,_,dmg = BCS:GetSpellPower()
	local heal = BCS:GetHealingPower()
	
	local spellPower = power-dmg
	local healingPower = spellPower + heal;
	
	label:SetText(L.HEAL_POWER_COLON)
	text:SetText(healingPower)
	
	frame.tooltip = format(L.SPELL_HEALING_POWER_TOOLTIP_HEADER, healingPower, spellPower, heal)
	frame.tooltipSubtext = L.SPELL_HEALING_POWER_TOOLTIP;
	frame:SetScript("OnEnter", function()
		GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
		GameTooltip:SetText(this.tooltip)
		GameTooltip:AddLine(this.tooltipSubtext)
		GameTooltip:Show()
	end)
	frame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
end

function BCS:SetManaRegen(statFrame)
	local frame = statFrame 
	local text = getglobal(statFrame:GetName() .. "StatText")
	local label = getglobal(statFrame:GetName() .. "Label")
	
	local base, casting, mp5 = BCS:GetManaRegen()
	
	label:SetText(L.MANA_REGEN_COLON)
	text:SetText(format("%d", base+mp5))
	
	frame.tooltip = format(L.SPELL_MANA_REGEN_TOOLTIP, (base+mp5), base, mp5)
	
	frame:SetScript("OnEnter", function()
		GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
		GameTooltip:SetText(this.tooltip)
		GameTooltip:Show()
	end)
	frame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
end

function BCS:SetDodge(statFrame)
	local frame = statFrame 
	local text = getglobal(statFrame:GetName() .. "StatText")
	local label = getglobal(statFrame:GetName() .. "Label")
	
	label:SetText(L.DODGE_COLON)
	text:SetText(format("%.2f%%", GetDodgeChance()))
end

function BCS:SetParry(statFrame)
	local frame = statFrame 
	local text = getglobal(statFrame:GetName() .. "StatText")
	local label = getglobal(statFrame:GetName() .. "Label")
	
	label:SetText(L.PARRY_COLON)
	text:SetText(format("%.2f%%", GetParryChance()))
end

function BCS:SetBlock(statFrame)
	local frame = statFrame 
	local text = getglobal(statFrame:GetName() .. "StatText")
	local label = getglobal(statFrame:GetName() .. "Label")
	
	label:SetText(L.BLOCK_COLON)
	text:SetText(format("%.2f%%", GetBlockChance()))
end

function BCS:SetDefense(statFrame)
	local base, modifier = UnitDefense("player")

	local frame = statFrame
	local label = getglobal(statFrame:GetName() .. "Label")
	local text = getglobal(statFrame:GetName() .. "StatText")
	
	label:SetText(TEXT(DEFENSE_COLON))
	
	local posBuff = 0
	local negBuff = 0
	if ( modifier > 0 ) then
		posBuff = modifier
	elseif ( modifier < 0 ) then
		negBuff = modifier
	end
	PaperDollFormatStat(DEFENSE_COLON, base, posBuff, negBuff, frame, text)
end

function BCS:SetRangedDamage(statFrame)
	local label = getglobal(statFrame:GetName() .. "Label")
	local damageText = getglobal(statFrame:GetName() .. "StatText")
	local damageFrame = statFrame
	
	label:SetText(TEXT(DAMAGE_COLON))
	
	damageFrame:SetScript("OnEnter", CharacterRangedDamageFrame_OnEnter)
	damageFrame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	-- If no ranged attack then set to n/a
	if ( PaperDollFrame.noRanged ) then
		damageText:SetText(NOT_APPLICABLE)
		damageFrame.damage = nil
		return
	end

	local rangedAttackSpeed, minDamage, maxDamage, physicalBonusPos, physicalBonusNeg, percent = UnitRangedDamage("player")
	local displayMin = max(floor(minDamage),1)
	local displayMax = max(ceil(maxDamage),1)

	minDamage = (minDamage / percent) - physicalBonusPos - physicalBonusNeg
	maxDamage = (maxDamage / percent) - physicalBonusPos - physicalBonusNeg

	local baseDamage = (minDamage + maxDamage) * 0.5
	local fullDamage = (baseDamage + physicalBonusPos + physicalBonusNeg) * percent
	local totalBonus = (fullDamage - baseDamage)
	local damagePerSecond = (max(fullDamage,1) / rangedAttackSpeed)
	local tooltip = max(floor(minDamage),1).." - "..max(ceil(maxDamage),1)

	if ( totalBonus == 0 ) then
		if ( ( displayMin < 100 ) and ( displayMax < 100 ) ) then 
			damageText:SetText(displayMin.." - "..displayMax)
		else
			damageText:SetText(displayMin.."-"..displayMax)
		end
	else
		local colorPos = "|cff20ff20"
		local colorNeg = "|cffff2020"
		local color
		if ( totalBonus > 0 ) then
			color = colorPos
		else
			color = colorNeg
		end
		if ( ( displayMin < 100 ) and ( displayMax < 100 ) ) then 
			damageText:SetText(color..displayMin.." - "..displayMax.."|r")	
		else
			damageText:SetText(color..displayMin.."-"..displayMax.."|r")
		end
		if ( physicalBonusPos > 0 ) then
			tooltip = tooltip..colorPos.." +"..physicalBonusPos.."|r"
		end
		if ( physicalBonusNeg < 0 ) then
			tooltip = tooltip..colorNeg.." "..physicalBonusNeg.."|r"
		end
		if ( percent > 1 ) then
			tooltip = tooltip..colorPos.." x"..floor(percent*100+0.5).."%|r"
		elseif ( percent < 1 ) then
			tooltip = tooltip..colorNeg.." x"..floor(percent*100+0.5).."%|r"
		end
		damageFrame.tooltip = tooltip.." "..format(TEXT(DPS_TEMPLATE), damagePerSecond)
	end
	damageFrame.attackSpeed = rangedAttackSpeed
	damageFrame.damage = tooltip
	damageFrame.dps = damagePerSecond
end

function BCS:SetRangedAttackSpeed(startFrame)
	local label = getglobal(startFrame:GetName() .. "Label")
	local damageText = getglobal(startFrame:GetName() .. "StatText")
	local damageFrame = startFrame
	
	label:SetText(TEXT(SPEED)..":")

	-- If no ranged attack then set to n/a
	if ( PaperDollFrame.noRanged ) then
		damageText:SetText(NOT_APPLICABLE)
		damageFrame.damage = nil
		return
	end

	local rangedAttackSpeed, minDamage, maxDamage, physicalBonusPos, physicalBonusNeg, percent = UnitRangedDamage("player")
	local displayMin = max(floor(minDamage),1)
	local displayMax = max(ceil(maxDamage),1)

	minDamage = (minDamage / percent) - physicalBonusPos - physicalBonusNeg
	maxDamage = (maxDamage / percent) - physicalBonusPos - physicalBonusNeg

	local baseDamage = (minDamage + maxDamage) * 0.5
	local fullDamage = (baseDamage + physicalBonusPos + physicalBonusNeg) * percent
	local totalBonus = (fullDamage - baseDamage)
	local damagePerSecond = (max(fullDamage,1) / rangedAttackSpeed)
	local tooltip = max(floor(minDamage),1).." - "..max(ceil(maxDamage),1)

	if ( totalBonus == 0 ) then
		if ( ( displayMin < 100 ) and ( displayMax < 100 ) ) then 
			damageText:SetText(displayMin.." - "..displayMax)	
		else
			damageText:SetText(displayMin.."-"..displayMax)
		end
	else
		local colorPos = "|cff20ff20"
		local colorNeg = "|cffff2020"
		local color
		if ( totalBonus > 0 ) then
			color = colorPos
		else
			color = colorNeg
		end
		if ( ( displayMin < 100 ) and ( displayMax < 100 ) ) then 
			damageText:SetText(color..displayMin.." - "..displayMax.."|r")	
		else
			damageText:SetText(color..displayMin.."-"..displayMax.."|r")
		end
		if ( physicalBonusPos > 0 ) then
			tooltip = tooltip..colorPos.." +"..physicalBonusPos.."|r"
		end
		if ( physicalBonusNeg < 0 ) then
			tooltip = tooltip..colorNeg.." "..physicalBonusNeg.."|r"
		end
		if ( percent > 1 ) then
			tooltip = tooltip..colorPos.." x"..floor(percent*100+0.5).."%|r"
		elseif ( percent < 1 ) then
			tooltip = tooltip..colorNeg.." x"..floor(percent*100+0.5).."%|r"
		end
		damageFrame.tooltip = tooltip.." "..format(TEXT(DPS_TEMPLATE), damagePerSecond)
	end
	
	damageText:SetText(format("%.2f", rangedAttackSpeed))
	
	damageFrame.attackSpeed = rangedAttackSpeed
	damageFrame.damage = tooltip
	damageFrame.dps = damagePerSecond
end

function BCS:SetRangedAttackPower(statFrame)
	local frame = statFrame 
	local text = getglobal(statFrame:GetName() .. "StatText")
	local label = getglobal(statFrame:GetName() .. "Label")
	
	label:SetText(TEXT(ATTACK_POWER_COLON))
	
	-- If no ranged attack then set to n/a
	if ( PaperDollFrame.noRanged ) then
		text:SetText(NOT_APPLICABLE)
		frame.tooltip = nil
		return
	end
	if ( HasWandEquipped() ) then
		text:SetText("--")
		frame.tooltip = nil
		return
	end

	local base, posBuff, negBuff = UnitRangedAttackPower("player")
	PaperDollFormatStat(RANGED_ATTACK_POWER, base, posBuff, negBuff, frame, text)
	frame.tooltipSubtext = format(L.RANGED_ATTACK_POWER_TOOLTIP, max(0,base + posBuff + negBuff)/ATTACK_POWER_MAGIC_NUMBER);
	frame:SetScript("OnEnter", function()
		GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
		GameTooltip:SetText(this.tooltip)
		GameTooltip:AddLine(this.tooltipSubtext, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1)
		GameTooltip:Show()
	end)
	frame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
end

function BCS:UpdatePaperdollStats(prefix, index)
	local stat1 = getglobal(prefix..1)
	local stat2 = getglobal(prefix..2)
	local stat3 = getglobal(prefix..3)
	local stat4 = getglobal(prefix..4)
	local stat5 = getglobal(prefix..5)
	local stat6 = getglobal(prefix..6)

	stat1:SetScript("OnEnter", nil)
	stat2:SetScript("OnEnter", nil)
	stat3:SetScript("OnEnter", nil)
	stat4:SetScript("OnEnter", nil)
	stat4:SetScript("OnEnter", nil)
	stat5:SetScript("OnEnter", nil)
	stat6:SetScript("OnEnter", nil)
	
	stat1.tooltip = nil
	stat2.tooltip = nil
	stat3.tooltip = nil
	stat4.tooltip = nil
	stat4.tooltip = nil
	stat5.tooltip = nil
	stat6.tooltip = nil

	stat4:Show()
	stat5:Show()
	stat6:Show()

	if ( index == "PLAYERSTAT_BASE_STATS" ) then
		BCS:SetStat(stat1, 1)
		BCS:SetStat(stat2, 2)
		BCS:SetStat(stat3, 3)
		BCS:SetStat(stat4, 4)
		BCS:SetStat(stat5, 5)
		BCS:SetArmor(stat6)
	elseif ( index == "PLAYERSTAT_MELEE_COMBAT" ) then
		BCS:SetDamage(stat1)
		BCS:SetAttackSpeed(stat2)
		BCS:SetAttackPower(stat3)
		BCS:SetRating(stat4, "MELEE")
		BCS:SetMeleeCritChance(stat5)
		BCS:SetGlancingBlow(stat6)
	elseif ( index == "PLAYERSTAT_RANGED_COMBAT" ) then
		BCS:SetRangedDamage(stat1)
		BCS:SetRangedAttackSpeed(stat2)
		BCS:SetRangedAttackPower(stat3)
		BCS:SetRating(stat4, "RANGED")
		BCS:SetRangedCritChance(stat5)
		stat6:Hide()
	elseif ( index == "PLAYERSTAT_SPELL_COMBAT" ) then
		BCS:SetSpellPower(stat1)
		BCS:SetHealing(stat2)
		BCS:SetRating(stat3, "SPELL")
		BCS:SetSpellCritChance(stat4)
		BCS:SetManaRegen(stat5)
		stat6:Hide()
	elseif ( index == "PLAYERSTAT_DEFENSES" ) then
		BCS:SetArmor(stat1)
		BCS:SetDefense(stat2)
		BCS:SetDodge(stat3)
		BCS:SetParry(stat4)
		BCS:SetBlock(stat5)
		stat6:Hide()
	end
end

local function PlayerStatFrameLeftDropDown_OnClick()
	UIDropDownMenu_SetSelectedValue(getglobal(this.owner), this.value)
	IndexLeft = this.value
	BCSConfig["DropdownLeft"] = IndexLeft
	BCS:UpdatePaperdollStats("PlayerStatFrameLeft", this.value)
end

local function PlayerStatFrameRightDropDown_OnClick()
	UIDropDownMenu_SetSelectedValue(getglobal(this.owner), this.value)
	IndexRight = this.value
	BCSConfig["DropdownRight"] = IndexRight
	BCS:UpdatePaperdollStats("PlayerStatFrameRight", this.value)
end

local function PlayerStatFrameLeftDropDown_Initialize()
	local info = {}
	local checked = nil
	for i=1, getn(BCS.PLAYERSTAT_DROPDOWN_OPTIONS) do
		info.text = BCS.L[BCS.PLAYERSTAT_DROPDOWN_OPTIONS[i]]
		info.func = PlayerStatFrameLeftDropDown_OnClick
		info.value = BCS.PLAYERSTAT_DROPDOWN_OPTIONS[i]
		info.checked = checked
		info.owner = UIDROPDOWNMENU_OPEN_MENU
		UIDropDownMenu_AddButton(info)
	end
end

local function PlayerStatFrameRightDropDown_Initialize()
	local info = {}
	local checked = nil
	for i=1, getn(BCS.PLAYERSTAT_DROPDOWN_OPTIONS) do
		info.text = BCS.L[BCS.PLAYERSTAT_DROPDOWN_OPTIONS[i]]
		info.func = PlayerStatFrameRightDropDown_OnClick
		info.value = BCS.PLAYERSTAT_DROPDOWN_OPTIONS[i]
		info.checked = checked
		info.owner = UIDROPDOWNMENU_OPEN_MENU
		UIDropDownMenu_AddButton(info)
	end
end

function PlayerStatFrameLeftDropDown_OnLoad()
	RaiseFrameLevel(this)
	RaiseFrameLevel(getglobal(this:GetName() .. "Button"))
	UIDropDownMenu_Initialize(this, PlayerStatFrameLeftDropDown_Initialize)
	UIDropDownMenu_SetWidth(99, this)
	UIDropDownMenu_JustifyText("LEFT")
end

function PlayerStatFrameRightDropDown_OnLoad()
	RaiseFrameLevel(this)
	RaiseFrameLevel(getglobal(this:GetName() .. "Button"))
	UIDropDownMenu_Initialize(this, PlayerStatFrameRightDropDown_Initialize)
	UIDropDownMenu_SetWidth(99, this)
	UIDropDownMenu_JustifyText("LEFT")
end