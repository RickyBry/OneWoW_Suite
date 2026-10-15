-- npc_extra.lua
local ADDON_NAME = ...
OneWoW.CatalogData:Defer(ADDON_NAME, 'npc', function()
return {
[220999] = {npcID=220999,expansion=10,roles={"rare"},locations={[2214]={x=56.7,y=87.6}},placeKeys={"zone:2214"},encounterIDs={2635}},
[221067] = {npcID=221067,expansion=10,roles={"rare"},locations={[2213]={x=17.1,y=33.4}},placeKeys={"zone:2213"},encounterIDs={2625}},
[221084] = {npcID=221084,expansion=10,roles={"rare"},placeKeys={"zone:2248"},encounterIDs={2637}},
[221224] = {npcID=221224,expansion=10,roles={"rare"},locations={[2215]={x=45.4,y=17.4}},placeKeys={"zone:2215"},encounterIDs={2636}},
[222318] = {npcID=222318,name="Bop",expansion=10,displayID=119745,roles={"boss"},placeKeys={"instance:1272"},encounterIDs={2589}},
[231448] = {npcID=231448,name="Tiny Torq",expansion=10,displayID=121417,roles={"rare"},placeKeys={"instance:1296"}},
[231454] = {npcID=231454,name="Fun-Size Flarendo",expansion=10,displayID=121813,roles={"rare"},placeKeys={"instance:1296"}},
[231821] = {npcID=231821,expansion=10,roles={"rare"},locations={[2346]={x=49.6,y=17.2}},placeKeys={"zone:2346"},encounterIDs={2683}},
[238319] = {npcID=238319,expansion=10,roles={"rare"},locations={[2371]={x=71.85,y=48.51}},placeKeys={"zone:2371"},encounterIDs={2762}},
[245479] = {npcID=245479,name="Looker Gaz'kreth Jr.",expansion=10,displayID=124295,roles={"rare"},placeKeys={"instance:1302"}},
[247463] = {npcID=247463,name="Zo'ya",expansion=10,displayID=98507,roles={"rare"},placeKeys={"instance:1302"}},
}
end)
