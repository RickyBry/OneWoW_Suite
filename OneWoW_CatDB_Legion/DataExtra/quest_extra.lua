-- quest_extra.lua
local ADDON_NAME = ...
OneWoW.CatalogData:Defer(ADDON_NAME, 'quest', function()
return {
[39353] = {id=39353,name="Test - New",level=0,requiredLevel=0,faction="both",expansion=6,zoneID=11,mapID=56,questType="standard"},
[40103] = {id=40103,name="7.0 ALPHA DK TEST QUEST",level=0,requiredLevel=0,faction="both",expansion=6,zoneID=7679,questType="standard"},
[40991] = {id=40991,name="Opening the Test Kitchen",level=10,requiredLevel=10,faction="both",expansion=6,zoneID=7502,description="I can cook, but I can't really hunt... or even fish, for that matter. If you bring me ingredients, however, I will use them to research new recipes for you. We can start with the few fish I managed to scrounge up. You'll find them in the barrel in the back of the kitchen.",rewardGold=202200,rewardXP=1415,questType="standard"},
[42364] = {id=42364,name="Tracker Test Quest - DAW",level=1,requiredLevel=1,faction="both",expansion=6,zoneID=7637,mapID=680,questType="standard"},
[43473] = {id=43473,name="Experimental Potion: Test Subjects Needed",level=45,requiredLevel=45,faction="both",expansion=6,zoneID=7502,mapID=627,rewardCurrencies={{id=1149,amount=150}},questType="standard"},
[43474] = {id=43474,name="Experimental Potion: Test Subjects Needed",level=45,requiredLevel=45,faction="both",expansion=6,zoneID=7502,mapID=627,rewardCurrencies={{id=1149,amount=150}},questType="standard"},
[43475] = {id=43475,name="Experimental Potion: Test Subjects Needed",level=45,requiredLevel=45,faction="both",expansion=6,zoneID=7502,mapID=627,rewardCurrencies={{id=1149,amount=150}},questType="standard"},
[43476] = {id=43476,name="Experimental Potion: Test Subjects Needed",level=45,requiredLevel=45,faction="both",expansion=6,zoneID=7502,mapID=627,rewardCurrencies={{id=1149,amount=150}},questType="standard"},
[43477] = {id=43477,name="Experimental Potion: Test Subjects Needed",level=45,requiredLevel=45,faction="both",expansion=6,zoneID=7502,mapID=627,rewardCurrencies={{id=1149,amount=150}},questType="standard"},
[43478] = {id=43478,name="Experimental Potion: Test Subjects Needed",level=45,requiredLevel=45,faction="both",expansion=6,zoneID=7502,mapID=627,rewardCurrencies={{id=1149,amount=150}},questType="standard"},
[43526] = {id=43526,name="A True Test",level=45,requiredLevel=45,faction="both",expansion=6,zoneID=7637,description="Vizuul's runebindings are more potent than I had anticipated. Not a bad thing - more power is certainly welcome - but there's certainly more potential for catastrophe if the spell matrix somehow becomes unstable. We should be able to safely contain the fel energy within the containment field using the eon winder you recovered... but keep an eye open just in case.",rewardGold=202200,rewardXP=6140,starts={{npcID=101080,x=0.378,y=0.472,zoneID=7637}},ends={{npcID=101080,x=0.378,y=0.472,zoneID=7637}},coords={x=0.378,y=0.472,source="quest_giver",zoneID=7637},questType="standard"},
}
end)
