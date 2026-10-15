-- npc_extra.lua
local ADDON_NAME = ...
OneWoW.CatalogData:Defer(ADDON_NAME, 'npc', function()
return {
[24480] = {npcID=24480,name="Mojo",expansion=3,displayID=28501,roles={"rare"},placeKeys={"instance:77","zone:333"}},
[50005] = {npcID=50005,expansion=3,roles={"rare"},placeKeys={"zone:204"}},
[50009] = {npcID=50009,expansion=3,roles={"rare"},locations={[204]={x=63.12,y=31.62}},placeKeys={"zone:204"}},
[50056] = {npcID=50056,expansion=3,roles={"rare"},locations={[198]={x=37.1,y=72.33}},placeKeys={"zone:198"}},
[50061] = {npcID=50061,expansion=3,roles={"rare"},locations={[207]={x=43.1,y=60.8}},placeKeys={"zone:207"}},
[50063] = {npcID=50063,expansion=3,roles={"rare"},locations={[249]={x=38.2,y=60.28}},placeKeys={"zone:249"}},
[50089] = {npcID=50089,expansion=3,roles={"rare"},locations={[241]={x=53.23,y=7.77}},placeKeys={"zone:241"}},
[52442] = {npcID=52442,expansion=3,roles={"rare"},placeKeys={"instance:76","zone:337"}},
[52894] = {npcID=52894,name="Lashtail Hatchling",expansion=3,displayID=38065,roles={"rare"},placeKeys={"instance:76","zone:337"}},
}
end)
