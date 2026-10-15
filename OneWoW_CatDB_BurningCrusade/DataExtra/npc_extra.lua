-- npc_extra.lua
local ADDON_NAME = ...
OneWoW.CatalogData:Defer(ADDON_NAME, 'npc', function()
return {
[17711] = {npcID=17711,expansion=1,roles={"rare"},placeKeys={"zone:104"}},
[18728] = {npcID=18728,expansion=1,roles={"rare"},placeKeys={"zone:100"}},
}
end)
