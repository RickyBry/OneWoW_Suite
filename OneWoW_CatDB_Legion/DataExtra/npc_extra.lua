-- npc_extra.lua
local ADDON_NAME = ...
OneWoW.CatalogData:Defer(ADDON_NAME, 'npc', function()
return {
[63724] = {npcID=63724,name="Micronax",expansion=6,displayID=78587,roles={"rare"},placeKeys={"instance:875"}},
[107544] = {npcID=107544,name="Nithogg",expansion=6,displayID=69816,roles={"rare"},locations={[634]={x=46.6,y=30}},placeKeys={"zone:634"},encounterIDs={1749}},
[112015] = {npcID=112015,name="Nightmare Whelpling",expansion=6,displayID=71945,roles={"boss"},placeKeys={"instance:768"},encounterIDs={1704}},
[112167] = {npcID=112167,name="Lagan",expansion=6,displayID=71980,roles={"boss"},placeKeys={"instance:727"},encounterIDs={1663}},
[112350] = {npcID=112350,expansion=6,roles={"rare"},locations={[630]={x=52.4,y=80.4}},placeKeys={"zone:630"},encounterIDs={1796}},
}
end)
