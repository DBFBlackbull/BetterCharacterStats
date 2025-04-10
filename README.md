# BetterCharacterStats - a World of Warcraft (1.12.1) AddOn

![preview](https://raw.githubusercontent.com/yutsuku/BetterCharacterStats/gh-pages/images/BetterCharacterStats.png)

Installation:

Put "BetterCharacterStats" folder into ".../World of Warcraft/Interface/AddOns/".
Create AddOns folder if necessary

After Installation directory tree should look like the following

	World of Warcraft
	  `- Interface
		 `- AddOns
			`- BetterCharacterStats
			   |- README.md
			   |- BetterCharacterStats.lua
			   |- BetterCharacterStats.toc
			   |- BetterCharacterStats.xml
			   |- helper.lua
			   `- Localization.lua

Features:
- Displays character statistics in one place (just like the character tab in Burning Crusade).

Known Issues:
- May be lacking things related to spell hit/spell crit.

Thanks to:
- All people who keeps reporting to me that some things are missing or are broken.

## Changelog
- 1.11
  - Original Fork from yutsuku/BetterCharacterStats
- 1.12
  - Reads Melee and Spell hit from Nature's Guidance talent
- 1.12.1
  - Fixed melee and ranged attack power tooltip
- 1.12.2
  - Added Flask of Supreme Power
  - Added Firepower Elixir
  - Added Shadow power Elixir
  - Added Frost power Elixir
  - Added Blessing of Blackfathom
  - Better styling for spell power and power for each school
  - Removed dedicated tab for spell for each school
- 1.12.3
  - No longer adds melee hit to ranged hit
  - Correctly calculates miss chance factoring in weapon skill
  - Calculates miss for at level and bosses
  - Calculates hit chance suppression for bosses
  - Show all information for main hand, off hand, and ranged
- 1.12.4
  - Added Glancing blow for boss monsters to melee statistics
- 1.12.5
  - Correctly calculates crit chance factoring in weapon skill
  - Calculate crit suppression for bosses
  - Calculate crit cap for at level and bosses
  - Corrected Weapon skill calculation for Druids in Bear, Car, Aquatic, and Travel form.