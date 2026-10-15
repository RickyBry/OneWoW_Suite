-- quest_extra.lua
local ADDON_NAME = ...
OneWoW.CatalogData:Defer(ADDON_NAME, 'quest', function()
return {
[38331] = {id=38331,name="Havi's Test",level=10,requiredLevel=10,faction="both",expansion=5,zoneID=7541,description="I could sense your power the moment you arrived in this land. You carry great purpose and a heavy task. Know that the Aegis of Agrammar rests in the high halls of the All-Father. Only if you prove your valor, can you claim it against your foe. Many trials must you face for this, but first I must know your strength. My stew is incomplete, and my old bones couldn't carry the ingredients up the hill. You look like you have a good arm. Will you help an old man finish his stew?",rewardGold=20220,rewardXP=175,starts={{npcID=96254,x=0.418,y=0.43,zoneID=7541}},ends={{npcID=96254,x=0.418,y=0.43,zoneID=7541}},coords={x=0.418,y=0.43,source="quest_giver",zoneID=7541},questType="standard"},
[38598] = {id=38598,name="TEST: Craft Some Legplates",level=10,requiredLevel=10,faction="none",expansion=5,description="The Highmountain tauren craft their legplates piece-by-piece, then assemble them all at the end. Seems pretty slow and unnecessarily arduous if you ask me, but we should start here before making any efficiency improvements. Here's some leystone. I've added the recipe into your workbook, as well. Let's give this a shot!",rewardXP=1415,questType="standard"},
}
end)
