# OneWoW Suite Changelog

## Fixes
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

# Catalog
- Quest list includes quests added in the latest retail update.
- Catalog loads only the expansion you are standing in, so tabs open faster and use less memory.
  - Other expansions load when you pick them in a filter, choose All, or search Item Search with two or more letters.
  - Zones "In This Zone" still lists every dungeon, raid, and Delve on your map, whatever its expansion.
  - Opening a vendor or instance from a link or waypoint finds it in any expansion.
- Clearing filters or leaving "In This Zone" on Zones, Vendors, and Quests switches to your current expansion.
- Item Search no longer hitches when building drop results or checking which alts know a recipe.
- Vendor lists sort and filter faster while typing.

## Fixes
- Quest givers no longer list the same quest twice after quest data refreshes.
- The Adventure Guide keeps its difficulty and loot filter after Catalog reads its loot.

---

# Notes
- Finding a vendor from a waypoint searches every expansion.

---

*No user-facing changes this release for AltTracker, Trackers, QoL, Direct Deposit, Shopping List, Mail, Bags, or DevTool.*

---

- **Last Updated**: Oct 16, 2026
