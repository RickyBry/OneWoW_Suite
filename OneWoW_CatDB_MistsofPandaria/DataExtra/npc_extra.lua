-- npc_extra.lua
local ADDON_NAME = ...
OneWoW.CatalogData:Defer(ADDON_NAME, 'npc', function()
return {
[62346] = {npcID=62346,expansion=4,roles={"rare"},locations={[376]={x=69.7,y=61.9}},placeKeys={"zone:376"},encounterIDs={725}},
[64632] = {npcID=64632,name="Hopling",expansion=4,displayID=43597,roles={"rare"},placeKeys={"instance:302"}},
[69099] = {npcID=69099,expansion=4,roles={"rare"},locations={[504]={x=60.5,y=37.3}},placeKeys={"zone:504"},encounterIDs={814}},
[69748] = {npcID=69748,name="Living Sandling",expansion=4,displayID=47252,roles={"rare"},placeKeys={"instance:362"}},
}
end)
