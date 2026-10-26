local ADDON_NAME, ns = ...

ns.ModuleRegistry:Define(ADDON_NAME, {
    id          = "fastloot",
    title       = "FASTLOOT_TITLE",
    category    = "AUTOMATION",
    description = "FASTLOOT_DESC",
    version     = "1.0",
    author      = "Ricky",
    contact     = "ricky@onewow.net",
    link        = "https://www.onewow.net",
    toggles     = {
        { id = "hide_loot_window", label = "FASTLOOT_TOGGLE_HIDE", description = "FASTLOOT_TOGGLE_HIDE_DESC", default = false },
    },
    preview     = true,
    _frame      = nil,
    _epoch      = 0,
})
