-- quest_extra.lua
local ADDON_NAME = ...
OneWoW.CatalogData:Defer(ADDON_NAME, 'quest', function()
return {
[72659] = {id=72659,name="Test Subject",level=36,requiredLevel=36,faction="both",expansion=9,zoneID=618,description="Today is day forty-one without finding a harmful artifact. I am further delighted to report that while you were away, a handful more proved harmless. Perhaps my hunt in Winterspring is almost concluded! Come to think of it... you have some magical ability, don't you? Or enough bravery to help me test some more artifacts? Do not be nervous. None of them will permanently hurt you. Artifacts with that kind of dangerous power were taken care of in my first year here.",rewardGold=309800,rewardXP=4925,rewardItems={259009,259011,259012,259010},rewardCurrencies={{id=2245,amount=10}},starts={{npcID=199370,x=0.48,y=0.59,zoneID=618}},ends={{npcID=199370,x=0.48,y=0.59,zoneID=618}},coords={x=0.48,y=0.59,source="quest_giver",zoneID=618},questType="standard"},
}
end)
