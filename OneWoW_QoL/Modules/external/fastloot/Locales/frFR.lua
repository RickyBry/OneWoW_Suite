local _, ns = ...
local M = ns.ModuleRegistry:Current()

-- Machine-drafted — frFR, pending native review.
OneWoW.Locale:Register(M._scope, "frFR", {

    ["FASTLOOT_TITLE"] = "Butin rapide",
    ["FASTLOOT_DESC"] = "Ramasse automatiquement tous les objets d'un cadavre ou d'un coffre dès que la fenêtre de butin est prête. Fonctionne avec le paramètre de ramassage auto du jeu.",
    ["FASTLOOT_TOGGLE_HIDE"] = "Masquer la fenêtre de butin",
    ["FASTLOOT_TOGGLE_HIDE_DESC"] = "Garde la fenêtre de butin masquée pendant le ramassage automatique. Si quelque chose ne peut pas être ramassé (sacs pleins, objet verrouillé, ou objet qui demande un jet ou une confirmation), la fenêtre s'affiche aussitôt.",
})
