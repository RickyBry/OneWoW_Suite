-- Machine-drafted — zhCN, pending native review.
local _, ns = ...
local M = ns.ModuleRegistry:Current()

OneWoW.Locale:Register(M._scope, "zhCN", {
    ["REP_TITLE"] = "声望追踪",
    ["REP_DESC"] = "把声望获得的聊天行换成本次登录的合计，以及距离下一声望等级、友谊等级或名望还差多少。可以把声望条切到该阵营，并在声望鼠标提示里列出其他角色。",
    ["REP_TOGGLE_CHAT"] = "详细声望获得聊天",
    ["REP_TOGGLE_CHAT_DESC"] = "把声望获得行换成获得量、本次登录合计和剩余量。游戏自己的奖励文字仍留在这一行。",
    ["REP_TOGGLE_GUILD_CHAT"] = "跳过公会声望聊天",
    ["REP_TOGGLE_GUILD_CHAT_DESC"] = "获得公会声望时不显示聊天行。",
    ["REP_TOGGLE_HIDDEN"] = "包含未激活阵营",
    ["REP_TOGGLE_HIDDEN_DESC"] = "也显示你移到未激活的阵营的声望获得。游戏不会在聊天里宣布这些。",
    ["REP_TOGGLE_SWITCH"] = "获得时切换声望条",
    ["REP_TOGGLE_SWITCH_DESC"] = "当你获得某阵营声望时，把追踪的声望条设为该阵营。",
    ["REP_TOGGLE_GUILD_SWITCH"] = "公会声望不切换",
    ["REP_TOGGLE_GUILD_SWITCH_DESC"] = "获得的是公会声望时，不改变追踪条。",
    ["REP_TOGGLE_SILENT"] = "切换声望条时不发聊天",
    ["REP_TOGGLE_SILENT_DESC"] = "追踪的声望条改变时不显示聊天行。",
    ["REP_TOGGLE_ALTS"] = "声望提示中显示其他角色",
    ["REP_TOGGLE_ALTS_DESC"] = "在声望行或追踪条上列出其他角色的声望。使用 AltTracker 保存的声望。",
    ["REP_CHAT_SESSION"] = "本次登录: %s",
    ["REP_CHAT_LEFT"] = "距离%s: %s",
    ["REP_CHAT_LEFT_PLAIN"] = "剩余: %s",
    ["REP_CHAT_SWITCH"] = "声望条已切换到%s。",
    ["REP_ALT_HEADER"] = "其他角色",
    ["REP_ALT_LINE"] = "%s (%s / %s)",
    ["REP_ALT_PARAGON"] = "巅峰",
})
