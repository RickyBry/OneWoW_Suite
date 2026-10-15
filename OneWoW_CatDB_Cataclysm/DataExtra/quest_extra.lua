-- quest_extra.lua
local ADDON_NAME = ...
OneWoW.CatalogData:Defer(ADDON_NAME, 'quest', function()
return {
[25621] = {id=25621,name="Field Test: Gnomecorder",level=10,requiredLevel=10,faction="alliance",expansion=3,zoneID=406,description="Ze Gnomecorder iz complete! Now ve must test zit! Venture into Stonetalon Mountains to ze southeast and valk down ze Talondeep Pass until you reach a filzy goblin drill machine. I vill activate ze Gnomecorder ven you reach your destination!",rewardXP=355,starts={{npcID=40895,x=0.354,y=0.712,zoneID=331}},ends={{npcID=40895,x=0.354,y=0.712,zoneID=331}},coords={x=0.354,y=0.712,source="quest_giver",zoneID=331},questType="standard"},
[27114] = {id=27114,name="The Gordok Taste Test",level=15,requiredLevel=15,faction="none",expansion=3,zoneID=2557,rewardItems={18269,18284},questType="dungeon"},
}
end)
