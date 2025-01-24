BCS = BCS or {}

BCS["L"] = {

	["([%d.]+)%% chance to crit"] = "([%d.]+)%% chance to crit",

	["^Set: Improves your chance to hit by (%d)%%."] = "^Set: Improves your chance to hit by (%d)%%.",
	["^Set: Improves your chance to get a critical strike with spells by (%d)%%."] = "^Set: Improves your chance to get a critical strike with spells by (%d)%%.",
	["^Set: Improves your chance to hit with spells by (%d)%%."] = "^Set: Improves your chance to hit with spells by (%d)%%.",
	["^Set: Increases damage and healing done by magical spells and effects by up to (%d+)%."] = "^Set: Increases damage and healing done by magical spells and effects by up to (%d+)%.",
	["^Set: Increases healing done by spells and effects by up to (%d+)%."] = "^Set: Increases healing done by spells and effects by up to (%d+)%.",
	
	["Equip: Improves your chance to hit by (%d)%%."] = "Equip: Improves your chance to hit by (%d)%%.",
	["Equip: Improves your chance to get a critical strike with spells by (%d)%%."] = "Equip: Improves your chance to get a critical strike with spells by (%d)%%.",
	["Equip: Improves your chance to hit with spells by (%d)%%."] = "Equip: Improves your chance to hit with spells by (%d)%%.",
	
	["Increases your chance to hit with melee weapons by (%d)%%."] = "Increases your chance to hit with melee weapons by (%d)%%.",
	["Increases your critical strike chance with ranged weapons by (%d)%%."] = "Increases your critical strike chance with ranged weapons by (%d)%%.",
	["Increases hit chance by (%d)%% and increases the chance movement impairing effects will be resisted by an additional %d+%%."] = "Increases hit chance by (%d)%% and increases the chance movement impairing effects will be resisted by an additional %d+%%.",
	["Increases your critical strike chance with all attacks by (%d)%%."] = "Increases your critical strike chance with all attacks by (%d)%%.",
	["Increases spell damage and healing by up to (%d+)%% of your total Spirit."] = "Increases spell damage and healing by up to (%d+)%% of your total Spirit.",
	["Reduces the chance that the opponent can resist your Frost and Fire spells by (%d)%%."] = "Reduces the chance that the opponent can resist your Frost and Fire spells by (%d)%%.",
	["Reduces the chance that the opponent can resist your Arcane spells by (%d+)%%."] = "Reduces the chance that the opponent can resist your Arcane spells by (%d+)%%.",
	["Reduces your target's chance to resist your Shadow spells by (%d+)%%."] = "Reduces your target's chance to resist your Shadow spells by (%d+)%%.",
	["Increases your chance to hit with melee attacks and spells by (%d)%%."] = "Increases your chance to hit with melee attacks and spells by (%d)%%.",
	
	["Equip: Increases damage done by Arcane spells and effects by up to (%d+)."] = "Equip: Increases damage done by Arcane spells and effects by up to (%d+).",
	["Equip: Increases damage done by Fire spells and effects by up to (%d+)."] = "Equip: Increases damage done by Fire spells and effects by up to (%d+).",
	["Equip: Increases damage done by Frost spells and effects by up to (%d+)."] = "Equip: Increases damage done by Frost spells and effects by up to (%d+).",
	["Equip: Increases damage done by Holy spells and effects by up to (%d+)."] = "Equip: Increases damage done by Holy spells and effects by up to (%d+).",
	["Equip: Increases damage done by Nature spells and effects by up to (%d+)."] = "Equip: Increases damage done by Nature spells and effects by up to (%d+).",
	["Equip: Increases damage done by Shadow spells and effects by up to (%d+)."] = "Equip: Increases damage done by Shadow spells and effects by up to (%d+).",

	["Spell Damage %+(%d+)"] = "Spell Damage %+(%d+)",
	["Arcane Damage %+(%d+)"] = "Arcane Damage %+(%d+)",
	["Fire Damage %+(%d+)"] = "Fire Damage %+(%d+)",
	["Frost Damage %+(%d+)"] = "Frost Damage %+(%d+)",
	["Holy Damage %+(%d+)"] = "Holy Damage %+(%d+)",
	["Nature Damage %+(%d+)"] = "Nature Damage %+(%d+)",
	["Shadow Damage %+(%d+)"] = "Shadow Damage %+(%d+)",
	["Healing Spells %+(%d+)"] = "Healing Spells %+(%d+)",
	
	["Equip: Restores (%d+) mana per 5 sec."] = "Equip: Restores (%d+) mana per 5 sec.",
	["+(%d)%% Hit"] = "+(%d)%% Hit",
	
	-- Random Bonuses // https://wow.gamepedia.com/index.php?title=SuffixId&oldid=204406
	["^%+(%d+) Damage and Healing Spells"] = "^%+(%d+) Damage and Healing Spells",
	["^%+(%d+) Arcane Spell Damage"] = "^%+(%d+) Arcane Spell Damage",
	["^%+(%d+) Fire Spell Damage"] = "^%+(%d+) Fire Spell Damage",
	["^%+(%d+) Frost Spell Damage"] = "^%+(%d+) Frost Spell Damage",
	["^%+(%d+) Holy Spell Damage"] = "^%+(%d+) Holy Spell Damage",
	["^%+(%d+) Nature Spell Damage"] = "^%+(%d+) Nature Spell Damage",
	["^%+(%d+) Shadow Spell Damage"] = "^%+(%d+) Shadow Spell Damage",
	["^%+(%d+) mana every 5 sec."] = "^%+(%d+) mana every 5 sec.",
	
	-- snowflakes ZG enchants
	["/Hit %+(%d+)"] = "/Hit %+(%d+)",
	["/Spell Hit %+(%d+)"] = "/Spell Hit %+(%d+)",
	["^Mana Regen %+(%d+)"] = "^Mana Regen %+(%d+)",
	["^%+(%d+) Healing Spells"] = "^%+(%d+) Healing Spells",
	["^%+(%d+) Spell Damage and Healing"] = "^%+(%d+) Spell Damage and Healing",
	
	["Equip: Increases damage and healing done by magical spells and effects by up to (%d+)."] = "Equip: Increases damage and healing done by magical spells and effects by up to (%d+).",
	["Equip: Increases healing done by spells and effects by up to (%d+)."] = "Equip: Increases healing done by spells and effects by up to (%d+).",
	
	-- auras
	["Spell damage increased by up to (%d+)."] =													"Spell damage increased by up to (%d+).", -- Flask of supreme power
	["Magical damage dealt is increased by up to (%d+)."] = 										"Magical damage dealt is increased by up to (%d+).", -- Very Berry cream
	["Magical damage dealt by spells and abilities is increased by up to (%d+)."] = 				"Magical damage dealt by spells and abilities is increased by up to (%d+).", -- Arcane elixir
	["Arcane damage dealt by spells and abilities is increased by up to (%d+)."] = 					"Arcane damage dealt by spells and abilities is increased by up to (%d+).",
	["Fire damage dealt by spells and abilities is increased by up to (%d+)."] = 					"Fire damage dealt by spells and abilities is increased by up to (%d+).", -- Firepower elixir
	["Frost damage dealt by spells and abilities is increased by up to (%d+)."] = 					"Frost damage dealt by spells and abilities is increased by up to (%d+).", -- Frost power elixir
	["Holy damage dealt by spells and abilities is increased by up to (%d+)."] = 					"Holy damage dealt by spells and abilities is increased by up to (%d+).",
	["Nature damage dealt by spells and abilities is increased by up to (%d+)."] = 					"Nature damage dealt by spells and abilities is increased by up to (%d+).",
	["Shadow damage dealt by spells and abilities is increased by up to (%d+)."] = 					"Shadow damage dealt by spells and abilities is increased by up to (%d+).", -- Shadow power elixir
	["Healing done by magical spells is increased by up to (%d+)."] = 								"Healing done by magical spells is increased by up to (%d+).",

	["Increases frost damage done by (%d+)"] = "Increases frost damage done by (%d+)", -- Blessing of Blackfathom

	["Chance to hit increased by (%d)%%."] = 														"Chance to hit increased by (%d)%%.",
	["Chance to hit reduced by (%d+)%%."] = 														"Chance to hit reduced by (%d+)%%.",
	["Chance to hit decreased by (%d+)%% and %d+ Nature damage every %d+ sec."] = 					"Chance to hit decreased by (%d+)%% and %d+ Nature damage every %d+ sec.",
	["Lowered chance to hit."] = 																	"Lowered chance to hit.", -- 5917	Fumble (25%)
	["Increases hitpoints by 300. 15%% haste to melee attacks. 10 mana regen every 5 seconds."] = 	"Increases hitpoints by 300. 15%% haste to melee attacks. 10 mana regen every 5 seconds.",
	["Improves your chance to hit by (%d+)%%."] = 													"Improves your chance to hit by (%d+)%%.",
	["Chance for a critical hit with a spell increased by (%d+)%%."] = 								"Chance for a critical hit with a spell increased by (%d+)%%.",
	["While active, target's critical hit chance with spells and attacks increases by 10%%."] = 	"While active, target's critical hit chance with spells and attacks increases by 10%%.",
	["Increases attack power by %d+ and chance to hit by (%d+)%%."] = 								"Increases attack power by %d+ and chance to hit by (%d+)%%.",
	["Holy spell critical hit chance increased by (%d+)%%."] = 										"Holy spell critical hit chance increased by (%d+)%%.",
	["Destruction spell critical hit chance increased by (%d+)%%."] = 								"Destruction spell critical hit chance increased by (%d+)%%.",
	["Arcane spell critical hit chance increased by (%d+)%%.\r\nArcane spell critical hit damage increased by (%d+)%%."] = "Arcane spell critical hit chance increased by (%d+)%%.\r\nArcane spell critical hit damage increased by (%d+)%%.",
	["Spell hit chance increased by (%d+)%%."] = 													"Spell hit chance increased by (%d+)%%.",
	
	["Increases chance for a melee, ranged, or spell critical by (%d+)%% and all attributes by %d+."] = "Increases chance for a melee, ranged, or spell critical by (%d+)%% and all attributes by %d+.",
	["Melee critical-hit chance reduced by (%d+)%%.\r\nSpell critical-hit chance reduced by (%d+)%%."] = "Melee critical-hit chance reduced by (%d+)%%.\r\nSpell critical-hit chance reduced by (%d+)%%.",
	["Increases critical chance of spells by 10%%, melee and ranged by 5%% and grants 140 attack power. 120 minute duration."] = "Increases critical chance of spells by 10%%, melee and ranged by 5%% and grants 140 attack power. 120 minute duration.",
	["Holy spell critical hit chance increased by (%d+)%%."] = "Holy spell critical hit chance increased by (%d+)%%.",
	["Destruction spell critical hit chance increased by (%d+)%%."] = "Destruction spell critical hit chance increased by (%d+)%%.",
	["Critical strike chance with spells and melee attacks increased by (%d+)%%."] = "Critical strike chance with spells and melee attacks increased by (%d+)%%.",

	["MELEE_ATTACK_POWER_TOOLTIP"] = "Increase damage with melee weapons by\r\n %.1f damage per second.",
	["RANGED_ATTACK_POWER_TOOLTIP"] = "Increase damage with ranged weapons by\r\n %.1f damage per second.",

	["MELEE_HIT_TOOLTIP"] = [[|cffffffffHit|r
	Result of an attack made with 
	melee or ranged weapons.]],

	["MAIN_HAND_HIT_TOOLTIP_HEADER"] = "Hit %d / %d%%",
	["PHYSICAL_HIT_TOOLTIP"] = [[Reduces the chance your attacks miss
	%.1f%% chance to miss vs level %d
	%.1f%% chance to miss vs boss
	%.1f%% hit suppression vs boss]],

	["MAIN_HAND_HIT_TOOLTIP_HEADER"] = "Main Hand Hit %d / %d%%",
	["PHYSICAL_HIT_TOOLTIP"] = [[Reduces the chance your attacks miss
	%.1f%% chance to miss vs level %d
	%.1f%% chance to miss vs boss
	%.1f%% hit suppression vs boss]],

	["DUAL_WIELD_HIT_TOOLTIP"] = [[Reduces the chance your attacks miss
	%.1f%% chance to miss with Main hand vs level %d
	%.1f%% chance to miss with Off hand vs level %d
	%.1f%% chance to miss with Main hand vs boss
	%.1f%% chance to miss witg Off hand vs boss
	%.1f%% Main hand hit suppression vs boss
	%.1f%% Off hand hit suppression vs boss]],


	["GLANCING_BLOW_TOOLTIP_HEADER"] = [[|cffffffffGlancing Blow Penalty %.1f%%|r]],
	["GLANCING_BLOW_TOOLTIP"] = [[Auto attacks against Boss level monsters have
	%d%% chance to glance, dealing reduced damage.
	Glancing blow penalty: %.1f%%]],

	["SPELL_HIT_TOOLTIP"] = [[|cffffffffHit|r
	Result of an attack made with 
	spells.]],
	
	["SPELL_HIT_SECONDARY_TOOLTIP"] = [[|cffffffffHit %d%% (%d%%|cff20ff20+%d%% %s|r|cffffffff)|r
	Result of an attack made with 
	spells.]],
	
	["SPELL_POWER_TOOLTIP_HEADER"] = [[|cffffffffSpell Power %d|r]],
	
	["SPELL_HEALING_POWER_TOOLTIP_HEADER"] = [[|cffffffffHealing Power %d (%d|cff20ff20+%d|r|cffffffff)|r]],
	["SPELL_HEALING_POWER_TOOLTIP"] = "Increases healing done by spells and effects.",
	
	["SPELL_MANA_REGEN_TOOLTIP"] = [[|cffffffffMana regen %d (%d|cff20ff20+%d|r|cffffffff)|r
	Regenerating points of mana every 5 seconds.]],
	
	["ROGUE_MELEE_HIT_TOOLTIP"] = [[
+5% hit to always hit enemy players.
+8% hit to always hit with your special abilities against a raid boss.
+24.6% hit to always hit a raid boss.]],

	PLAYERSTAT_BASE_STATS = "Base Stats",
	PLAYERSTAT_DEFENSES = "Defenses",
	PLAYERSTAT_MELEE_COMBAT = "Melee",
	PLAYERSTAT_RANGED_COMBAT = "Ranged",
	PLAYERSTAT_SPELL_COMBAT = "Spell",
	PLAYERSTAT_SPELL_SCHOOLS = "Schools",
	
	MELEE_HIT_RATING_COLON = "Hit:",
	RANGED_HIT_RATING_COLON = "Hit Chance:",
	SPELL_HIT_RATING_COLON = "Hit Rating:",
	MELEE_CRIT_COLON = "Crit Chance:",
	RANGED_CRIT_COLON = "Crit Chance:",
	SPELL_CRIT_COLON = "Crit Chance:",
	MELEE_GLANCING_BLOW_COLON = "Glancing:",
	MANA_REGEN_COLON = "Mana regen:",
	HEAL_POWER_COLON = "Healing:",
	DODGE_COLON = DODGE .. ":",
	PARRY_COLON = PARRY .. ":",
	BLOCK_COLON = BLOCK .. ":",
	
	SPELL_POWER_COLON = "Power:",
	
	SPELL_SCHOOL_ARCANE = "Arcane",
	SPELL_SCHOOL_FIRE = "Fire",
	SPELL_SCHOOL_FROST = "Frost",
	SPELL_SCHOOL_HOLY = "Holy",
	SPELL_SCHOOL_NATURE = "Nature",
	SPELL_SCHOOL_SHADOW = "Shadow",
	
}