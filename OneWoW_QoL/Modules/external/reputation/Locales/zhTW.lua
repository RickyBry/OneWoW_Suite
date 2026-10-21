-- Machine-drafted — zhTW, pending native review.
local _, ns = ...
local M = ns.ModuleRegistry:Current()

OneWoW.Locale:Register(M._scope, "zhTW", {
    ["REP_TITLE"] = "聲望追蹤",
    ["REP_DESC"] = "把聲望獲得的聊天行換成這次登入的合計，以及距離下一個聲望等級、友誼等級或名望還差多少。可以把聲望條切到該陣營，並在聲望滑鼠提示裡列出其他角色。",
    ["REP_TOGGLE_CHAT"] = "詳細聲望獲得聊天",
    ["REP_TOGGLE_CHAT_DESC"] = "把聲望獲得行換成獲得量、這次登入合計和剩餘量。遊戲自己的獎勵文字仍留在這一行。",
    ["REP_TOGGLE_GUILD_CHAT"] = "略過公會聲望聊天",
    ["REP_TOGGLE_GUILD_CHAT_DESC"] = "獲得公會聲望時不顯示聊天行。",
    ["REP_TOGGLE_HIDDEN"] = "包含未啟用陣營",
    ["REP_TOGGLE_HIDDEN_DESC"] = "也顯示你移到未啟用的陣營的聲望獲得。遊戲不會在聊天裡宣布這些。",
    ["REP_TOGGLE_SWITCH"] = "獲得時切換聲望條",
    ["REP_TOGGLE_SWITCH_DESC"] = "當你獲得某陣營聲望時，把追蹤的聲望條設為該陣營。",
    ["REP_TOGGLE_GUILD_SWITCH"] = "公會聲望不切換",
    ["REP_TOGGLE_GUILD_SWITCH_DESC"] = "獲得的是公會聲望時，不改變追蹤條。",
    ["REP_TOGGLE_SILENT"] = "切換聲望條時不發聊天",
    ["REP_TOGGLE_SILENT_DESC"] = "追蹤的聲望條改變時不顯示聊天行。",
    ["REP_TOGGLE_ALTS"] = "聲望提示中顯示其他角色",
    ["REP_TOGGLE_ALTS_DESC"] = "在聲望列或追蹤條上列出其他角色的聲望。使用 AltTracker 儲存的聲望。",
    ["REP_CHAT_SESSION"] = "這次登入: %s",
    ["REP_CHAT_LEFT"] = "距離%s: %s",
    ["REP_CHAT_LEFT_PLAIN"] = "剩餘: %s",
    ["REP_CHAT_SWITCH"] = "聲望條已切換到%s。",
    ["REP_ALT_HEADER"] = "其他角色",
    ["REP_ALT_LINE"] = "%s (%s / %s)",
    ["REP_ALT_PARAGON"] = "巔峰",
})
