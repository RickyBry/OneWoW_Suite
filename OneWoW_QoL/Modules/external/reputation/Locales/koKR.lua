-- Machine-drafted — koKR, pending native review.
local _, ns = ...
local M = ns.ModuleRegistry:Current()

OneWoW.Locale:Register(M._scope, "koKR", {
    ["REP_TITLE"] = "평판 추적",
    ["REP_DESC"] = "평판 획득 대화 줄을 이번 접속의 합계와 다음 평판 단계, 우호도 등급, 또는 영예까지 남은 양으로 바꿉니다. 그 진영으로 평판 막대를 바꿀 수 있고, 평판 툴팁에 다른 캐릭터를 표시합니다.",
    ["REP_TOGGLE_CHAT"] = "자세한 평판 획득 대화",
    ["REP_TOGGLE_CHAT_DESC"] = "평판 획득 줄을 획득량, 이번 접속 합계, 남은 양으로 바꿉니다. 게임의 보너스 문구는 그 줄에 남습니다.",
    ["REP_TOGGLE_GUILD_CHAT"] = "길드 평판 대화 생략",
    ["REP_TOGGLE_GUILD_CHAT_DESC"] = "길드 평판을 얻어도 대화 줄을 출력하지 않습니다.",
    ["REP_TOGGLE_HIDDEN"] = "비활성 진영 포함",
    ["REP_TOGGLE_HIDDEN_DESC"] = "비활성으로 옮긴 진영의 획득도 출력합니다. 게임은 이 획득을 대화에 알리지 않습니다.",
    ["REP_TOGGLE_SWITCH"] = "획득 시 평판 막대 전환",
    ["REP_TOGGLE_SWITCH_DESC"] = "진영 평판을 얻으면 추적 중인 평판 막대를 그 진영으로 바꿉니다.",
    ["REP_TOGGLE_GUILD_SWITCH"] = "길드 평판으로는 전환하지 않음",
    ["REP_TOGGLE_GUILD_SWITCH_DESC"] = "획득이 길드 평판이면 추적 막대를 그대로 둡니다.",
    ["REP_TOGGLE_SILENT"] = "막대 전환 시 대화 없음",
    ["REP_TOGGLE_SILENT_DESC"] = "추적 중인 평판 막대가 바뀔 때 대화 줄을 출력하지 않습니다.",
    ["REP_TOGGLE_ALTS"] = "평판 툴팁에 다른 캐릭터",
    ["REP_TOGGLE_ALTS_DESC"] = "평판 줄이나 추적 막대에서 다른 캐릭터의 평판을 표시합니다. AltTracker가 저장한 평판을 사용합니다.",
    ["REP_CHAT_SESSION"] = "이번 접속: %s",
    ["REP_CHAT_LEFT"] = "%s까지: %s",
    ["REP_CHAT_LEFT_PLAIN"] = "남음: %s",
    ["REP_CHAT_SWITCH"] = "평판 막대를 %s(으)로 바꿨습니다.",
    ["REP_ALT_HEADER"] = "다른 캐릭터",
    ["REP_ALT_LINE"] = "%s (%s / %s)",
    ["REP_ALT_PARAGON"] = "불멸",
})
