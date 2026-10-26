local _, ns = ...
local M = ns.ModuleRegistry:Current()

-- Machine-drafted — esES, pending native review.
OneWoW.Locale:Register(M._scope, "esES", {

    ["FASTLOOT_TITLE"] = "Saqueo rápido",
    ["FASTLOOT_DESC"] = "Saquea automáticamente todos los objetos de un cadáver o cofre en el momento en que la ventana de botín está lista. Funciona junto con el ajuste de auto-saqueo del juego.",
    ["FASTLOOT_TOGGLE_HIDE"] = "Ocultar ventana de botín",
    ["FASTLOOT_TOGGLE_HIDE_DESC"] = "Mantiene oculta la ventana de botín mientras se despoja automáticamente. Si algo no se puede despojar (bolsas llenas, un objeto bloqueado o un objeto que requiere una tirada o confirmación), la ventana aparece al instante.",
})
