## Current

- **Status**: Draft

- Dropdown menus, the minimap button menu, profile dialogs, and item lists reuse what they built the first time, so opening them over a long session no longer adds memory or slows the game.
- Changing the theme, font, font size, or language updates the OneWoW window in place instead of closing and rebuilding it, and switching back and forth no longer adds memory.
- Open dialogs and panels docked to game windows switch to a new theme right away.
- Bag overlays and searches update faster when you loot, sort, or move items, because item details are no longer looked up again on every bag change.
- Browsing the Auction House, vendors, or Catalog for a long session no longer keeps growing memory for item tooltips and searches.

#### Fixes
- The AFK screen's session time shows how long you have been logged in, instead of how long your computer has been on.
- Quest dialogs no longer report an error when Catalog is turned off.
- Deleted preset overlays stay deleted after a reload.
- The Overlays settings Preview stays in its own column instead of sliding under the settings after you click through a few overlays.
- Overlays on the default guild bank match the items in the tab you are viewing.
- Mail and Auction House overlays appear on items the game had not loaded yet, instead of staying blank.
- Bag items without durability no longer count as broken in overlays and searches.
- Talking to vendors and NPCs inside instances no longer risks errors from hidden names.
- The new-version check sends fewer messages: once per session, when you join a guild, or when your group grows, instead of after every loading screen.
- A new-version message blocked in a dungeon or raid is sent once afterward, instead of repeating to every channel.
- The update popup and Home notice only appear after two different players report a newer version, and impossible version numbers are ignored.
- One feature failing on a game event no longer stops other OneWoW features from reacting to it.

---

### Catalog
- Quest list includes quests added in the latest retail update.
- Catalog loads only the expansion you are standing in, so tabs open faster and use less memory.
  - Other expansions load when you pick them in a filter, choose All, or search Item Search with two or more letters.
  - Zones "In This Zone" still lists every dungeon, raid, and Delve on your map, whatever its expansion.
  - Opening a vendor or instance from a link or waypoint finds it in any expansion.
- Clearing filters or leaving "In This Zone" on Zones, Vendors, and Quests switches to your current expansion.
- Item Search no longer hitches when building drop results or checking which alts know a recipe.
- Vendor lists sort and filter faster while typing.

#### Fixes
- Quest givers no longer list the same quest twice after quest data refreshes.
- The Adventure Guide keeps its difficulty and loot filter after Catalog reads its loot.

---

### Notes
- Finding a vendor from a waypoint searches every expansion.

---

*No user-facing changes this release for AltTracker, Trackers, QoL, Direct Deposit, Shopping List, Mail, Bags, or DevTool.*

---

- **Last Updated**: Oct 16, 2026

## R6.2609.1519

Released Sep 16, 2026. Per-expansion Catalog packs with Collectibles, Housing, and NPCs, ESC and AFK Character and Zone cards, Shopping List Farming, and OneWay Pins.

[Read full release notes](Release-Notes-R6.2609.1519)

## R6.2609.0106

Released Sep 1, 2026. Pin Packs, hub search, Mail WoW UI / One UI, Trackers hide-when-done and Midnight rares, Catalog location data, slash command updates, and Crafting Orders compact view.

[Read full release notes](Release-Notes-R6.2609.0106)

## R6.2608.2902

Released Aug 29, 2026. Home version check, hub Back and Forward, list sorting and row stripe, OneWay Pins, Crafting Orders, Portals consumable, and DEVMODE Copy All.

[Read full release notes](Release-Notes-R6.2608.2902)

## R6.2608.2707

Released Aug 27, 2026. Catalog tradeskills and quests through Midnight 12.1, Crafting Orders One UI, Shopping List bag overlay, and Bags shopping-list search.

[Read full release notes](Release-Notes-R6.2608.2707)

## R6.2608.2507

Released Aug 25, 2026. Tracker editor and list polish, Catalog quest, Journal, and vendor work, plus Home website and waypoint fixes.

[Read full release notes](Release-Notes-R6.2608.2507)

## R6.2608.1804

Released Aug 18, 2026. Midnight Season 2 across Portals, Journal, AltTracker Progress, and Trackers, plus Icon Browser search, Bags replacement toggles, and Mail language/font fixes.

[Read full release notes](Release-Notes-R6.2608.1804)

## R6.2608.1105

Released Aug 11, 2026. Home attention filtering, suite On/Off settings chrome, Portals and Catalog Tradeskills/Quests polish, plus Mail shipment and AH receipt fixes.

[Read full release notes](Release-Notes-R6.2608.1105)

## R6.2608.0406

Released Aug 4, 2026. Home hub cards and What’s New, slash cleanup path, Mail AH invoice breakdown, Catalog Journal/Vendors work, AltTracker auctions, and Notes list polish.

[Read full release notes](Release-Notes-R6.2608.0406)

## Related

* [Home](Home)
* [Slash commands](Slash-Commands)
* [Getting started](Getting-Started)

### Sources

* [CHANGELOG.md](https://github.com/kellewic/OneWoW_Suite/blob/main/CHANGELOG.md)
* In-game: Home → What’s New (highlights only)
