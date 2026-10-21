local _, ns = ...
local M = ns.ModuleRegistry:Current()

OneWoW.Locale:Register(M._scope, "enUS", {
    ["REP_TITLE"] = "Reputation Tracker",
    ["REP_DESC"] = "Replaces the faction gain chat line with this session's total and how much is left to the next standing, friendship rank, or renown. Can switch the reputation bar to that faction, and lists your other characters on reputation tooltips.",
    ["REP_TOGGLE_CHAT"] = "Detailed faction gain chat",
    ["REP_TOGGLE_CHAT_DESC"] = "Replace the faction gain chat line with the gain, this session's total, and how much is left. The game's own bonus text stays on that line.",
    ["REP_TOGGLE_GUILD_CHAT"] = "Skip guild reputation chat",
    ["REP_TOGGLE_GUILD_CHAT_DESC"] = "Do not print a chat line when you gain guild reputation.",
    ["REP_TOGGLE_HIDDEN"] = "Include inactive factions",
    ["REP_TOGGLE_HIDDEN_DESC"] = "Also print gains for factions you moved to inactive, which the game does not announce in chat.",
    ["REP_TOGGLE_SWITCH"] = "Switch reputation bar on gain",
    ["REP_TOGGLE_SWITCH_DESC"] = "Set the tracked reputation bar to a faction when you gain reputation with it.",
    ["REP_TOGGLE_GUILD_SWITCH"] = "Do not switch for guild reputation",
    ["REP_TOGGLE_GUILD_SWITCH_DESC"] = "Leave the tracked bar alone when the gain is guild reputation.",
    ["REP_TOGGLE_SILENT"] = "No chat line when the bar switches",
    ["REP_TOGGLE_SILENT_DESC"] = "Do not print a chat line when the tracked reputation bar changes.",
    ["REP_TOGGLE_ALTS"] = "Other characters on reputation tooltips",
    ["REP_TOGGLE_ALTS_DESC"] = "On a reputation row or the tracked reputation bar, list standing for your other characters. Uses reputation saved by AltTracker.",
    ["REP_CHAT_SESSION"] = "Session: %s",
    ["REP_CHAT_LEFT"] = "Left to %s: %s",
    ["REP_CHAT_LEFT_PLAIN"] = "Left: %s",
    ["REP_CHAT_SWITCH"] = "Reputation bar switched to %s.",
    ["REP_ALT_HEADER"] = "Other characters",
    ["REP_ALT_LINE"] = "%s (%s / %s)",
    ["REP_ALT_PARAGON"] = "Paragon",
})
