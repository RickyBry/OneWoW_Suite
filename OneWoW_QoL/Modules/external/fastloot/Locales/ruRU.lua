local _, ns = ...
local M = ns.ModuleRegistry:Current()

-- Machine-drafted — ruRU, pending native review.
OneWoW.Locale:Register(M._scope, "ruRU", {

    ["FASTLOOT_TITLE"] = "Быстрая добыча",
    ["FASTLOOT_DESC"] = "Автоматически забирает всю добычу с трупа или из сундука в момент готовности окна добычи. Работает вместе с настройкой автодобычи игры.",
    ["FASTLOOT_TOGGLE_HIDE"] = "Скрывать окно добычи",
    ["FASTLOOT_TOGGLE_HIDE_DESC"] = "Окно добычи остается скрытым, пока предметы собираются автоматически. Если что-то нельзя забрать (сумки полны, предмет заблокирован или требуется бросок или подтверждение), окно сразу появится.",
})
