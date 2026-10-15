-- npc_extra.lua
local ADDON_NAME = ...
OneWoW.CatalogData:Defer(ADDON_NAME, 'npc', function()
return {
[132253] = {npcID=132253,expansion=7,roles={"rare"},locations={[862]={x=69,y=31}},placeKeys={"zone:862"},encounterIDs={2141}},
[138964] = {npcID=138964,name="Spawn of Merektha",expansion=7,displayID=86088,roles={"boss"},placeKeys={"instance:1030"},encounterIDs={2143}},
[139049] = {npcID=139049,name="Filthy Slime",expansion=7,displayID=86101,roles={"rare"},placeKeys={"instance:1002"}},
[139372] = {npcID=139372,name="Vengeful Chicken",expansion=7,displayID=86231,roles={"rare"},placeKeys={"instance:1021"}},
[140125] = {npcID=140125,name="Miimii",expansion=7,displayID=86574,roles={"boss"},placeKeys={"instance:1041"},encounterIDs={2172}},
[152671] = {npcID=152671,expansion=7,roles={"rare"},placeKeys={"zone:1355"},encounterIDs={2363}},
}
end)
