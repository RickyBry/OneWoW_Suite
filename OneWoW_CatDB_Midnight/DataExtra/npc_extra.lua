-- npc_extra.lua
local ADDON_NAME = ...
OneWoW.CatalogData:Defer(ADDON_NAME, 'npc', function()
return {
[244424] = {npcID=244424,expansion=11,roles={"rare"},locations={[2437]={x=45.24,y=47.9}},placeKeys={"zone:2437"},encounterIDs={2782}},
[244762] = {npcID=244762,expansion=11,roles={"rare"},locations={[2395]={x=45.24,y=59.97}},placeKeys={"zone:2395"},encounterIDs={2827}},
[249776] = {npcID=249776,expansion=11,roles={"rare"},locations={[2413]={x=39.02,y=66.91}},placeKeys={"zone:2413"},encounterIDs={2829}},
[251885] = {npcID=251885,expansion=11,roles={"rare"},placeKeys={"instance:1309"}},
[256567] = {npcID=256567,name="Gortham",expansion=11,displayID=138168,roles={"rare"},placeKeys={"instance:1316"}},
[260875] = {npcID=260875,expansion=11,roles={"rare"}},
[261072] = {npcID=261072,expansion=11,roles={"rare"}},
[270147] = {npcID=270147,name="Slitherfang",expansion=11,displayID=146343,roles={"rare"},placeKeys={"instance:1322"}},
[270425] = {npcID=270425,name="Ula'took",expansion=11,displayID=146376,roles={"boss"},placeKeys={"instance:1320"},encounterIDs={2895}},
}
end)
