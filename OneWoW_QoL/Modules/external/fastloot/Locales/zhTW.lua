local _, ns = ...
local M = ns.ModuleRegistry:Current()

-- Machine-drafted — zhTW (Taiwan terms), pending native review.
OneWoW.Locale:Register(M._scope, "zhTW", {

    ["FASTLOOT_TITLE"] = "快速拾取",
    ["FASTLOOT_DESC"] = "在拾取視窗就緒的那一刻，自動拾取屍體或箱子中的所有物品。與遊戲的自動拾取設定協同運作。",
    ["FASTLOOT_TOGGLE_HIDE"] = "隱藏拾取視窗",
    ["FASTLOOT_TOGGLE_HIDE_DESC"] = "自動拾取物品時隱藏拾取視窗。如果有無法拾取的物品（背包已滿、物品被鎖定，或需要擲骰或確認），視窗會立即顯示。",
})
