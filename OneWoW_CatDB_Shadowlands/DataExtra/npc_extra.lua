-- npc_extra.lua
local ADDON_NAME = ...
OneWoW.CatalogData:Defer(ADDON_NAME, 'npc', function()
return {
[167524] = {npcID=167524,expansion=8,roles={"rare"},placeKeys={"zone:1533"},encounterIDs={2430}},
[167525] = {npcID=167525,expansion=8,roles={"rare"},placeKeys={"zone:1536"},encounterIDs={2431}},
[167526] = {npcID=167526,expansion=8,roles={"rare"},placeKeys={"zone:1525"},encounterIDs={2433}},
[167527] = {npcID=167527,expansion=8,roles={"rare"},placeKeys={"zone:1565"},encounterIDs={2432}},
[173994] = {npcID=173994,name="Will of Remornia",expansion=8,displayID=99072,roles={"boss"},placeKeys={"instance:1190"},encounterIDs={2424}},
[178958] = {npcID=178958,expansion=8,roles={"rare"},placeKeys={"zone:1543"},encounterIDs={2456}},
[179169] = {npcID=179169,name="Rarity",expansion=8,displayID=100056,roles={"rare"},placeKeys={"instance:1194"}},
[274062] = {npcID=274062,expansion=8,category="housing",roles={"vendor"},locations={[1525]={x=73.06,y=52.58}},placeKeys={"zone:1525"}},
}
end)
