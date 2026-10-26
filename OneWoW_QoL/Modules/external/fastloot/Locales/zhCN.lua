local _, ns = ...
local M = ns.ModuleRegistry:Current()

-- Machine-drafted — zhCN, pending native review.
OneWoW.Locale:Register(M._scope, "zhCN", {

    ["FASTLOOT_TITLE"] = "快速拾取",
    ["FASTLOOT_DESC"] = "在拾取窗口就绪的那一刻，自动拾取尸体或箱子中的所有物品。与游戏的自动拾取设置协同工作。",
    ["FASTLOOT_TOGGLE_HIDE"] = "隐藏拾取窗口",
    ["FASTLOOT_TOGGLE_HIDE_DESC"] = "自动拾取物品时隐藏拾取窗口。如果有无法拾取的物品（背包已满、物品被锁定，或需要掷骰或确认），窗口会立即显示。",
})
