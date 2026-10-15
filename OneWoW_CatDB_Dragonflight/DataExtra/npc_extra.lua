-- npc_extra.lua
local ADDON_NAME = ...
OneWoW.CatalogData:Defer(ADDON_NAME, 'npc', function()
return {
[193532] = {npcID=193532,expansion=9,roles={"rare"},locations={[2024]={x=79.5,y=35.9}},placeKeys={"zone:2024"},encounterIDs={2517}},
[193533] = {npcID=193533,expansion=9,roles={"rare"},encounterIDs={2518}},
[193534] = {npcID=193534,expansion=9,roles={"rare"},locations={[2023]={x=83.5,y=76.3}},placeKeys={"zone:2023"},encounterIDs={2515}},
[193535] = {npcID=193535,expansion=9,roles={"rare"},locations={[2022]={x=55.1,y=77.4}},placeKeys={"zone:2022"},encounterIDs={2506}},
[209574] = {npcID=209574,expansion=9,roles={"rare"},locations={[2200]={x=39.61,y=53.86}},placeKeys={"zone:2200"},encounterIDs={2562}},
[211939] = {npcID=211939,name="Sergeant Quackers",expansion=9,displayID=114494,roles={"boss"},placeKeys={"instance:1207"},encounterIDs={2555}},
[212275] = {npcID=212275,name="Ivy",expansion=9,displayID=114645,roles={"boss"},placeKeys={"instance:1207"},encounterIDs={2553}},
}
end)
