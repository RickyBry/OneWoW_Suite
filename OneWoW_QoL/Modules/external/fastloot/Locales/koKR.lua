local _, ns = ...
local M = ns.ModuleRegistry:Current()

-- Machine-drafted — koKR (replaces TEST placeholder), pending native review.
OneWoW.Locale:Register(M._scope, "koKR", {

    ["FASTLOOT_TITLE"] = "빠른 획득",
    ["FASTLOOT_DESC"] = "전리품 창이 준비되는 순간 시체나 상자의 모든 아이템을 자동으로 획득합니다. 게임의 자동 획득 설정과 함께 작동합니다.",
    ["FASTLOOT_TOGGLE_HIDE"] = "전리품 창 숨기기",
    ["FASTLOOT_TOGGLE_HIDE_DESC"] = "아이템을 자동으로 획득하는 동안 전리품 창을 숨깁니다. 가방이 가득 찼거나, 잠긴 아이템이거나, 주사위 굴림이나 확인이 필요한 아이템처럼 획득할 수 없는 것이 있으면 창이 바로 표시됩니다.",
})
