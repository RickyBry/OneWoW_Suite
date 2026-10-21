local ADDON_NAME, ns = ...

ns.ModuleRegistry:Define(ADDON_NAME, {
    id          = "reputation",
    title       = "REP_TITLE",
    category    = "INTERFACE",
    description = "REP_DESC",
    version     = "1.0",
    tags        = { "reputation", "faction", "renown", "paragon", "exalted" },
    toggles = {
        { id = "detailedChat", label = "REP_TOGGLE_CHAT", description = "REP_TOGGLE_CHAT_DESC", default = true },
        { id = "skipGuildChat", label = "REP_TOGGLE_GUILD_CHAT", description = "REP_TOGGLE_GUILD_CHAT_DESC", default = false },
        { id = "showHidden", label = "REP_TOGGLE_HIDDEN", description = "REP_TOGGLE_HIDDEN_DESC", default = false },
        { id = "switchBar", label = "REP_TOGGLE_SWITCH", description = "REP_TOGGLE_SWITCH_DESC", default = false },
        { id = "skipGuildSwitch", label = "REP_TOGGLE_GUILD_SWITCH", description = "REP_TOGGLE_GUILD_SWITCH_DESC", default = true },
        { id = "silentSwitch", label = "REP_TOGGLE_SILENT", description = "REP_TOGGLE_SILENT_DESC", default = true },
        { id = "altTooltip", label = "REP_TOGGLE_ALTS", description = "REP_TOGGLE_ALTS_DESC", default = true },
    },
    defaultEnabled = false,
})
