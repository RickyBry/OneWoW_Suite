-- npc_extra.lua
local ADDON_NAME = ...
OneWoW.CatalogData:Defer(ADDON_NAME, 'npc', function()
return {
[81252] = {npcID=81252,name="Drov the Ruiner",expansion=5,displayID=58260,roles={"rare"},placeKeys={"zone:543"},encounterIDs={1291}},
[83746] = {npcID=83746,expansion=5,roles={"rare"},locations={[542]={x=36,y=39}},placeKeys={"zone:542"},encounterIDs={1262}},
[86532] = {npcID=86532,name="Lanticore Spawnling",expansion=5,displayID=59668,roles={"rare"},placeKeys={"instance:559"}},
[274291] = {npcID=274291,expansion=5,category="housing",roles={"vendor"},locations={[550]={x=82.11,y=44.79}},placeKeys={"zone:550"}},
}
end)
