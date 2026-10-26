local _, ns = ...
local M = ns.ModuleRegistry:Current()

-- Machine-drafted — deDE, pending native review.
OneWoW.Locale:Register(M._scope, "deDE", {

    ["FASTLOOT_TITLE"] = "Schnellplündern",
    ["FASTLOOT_DESC"] = "Plündert automatisch alle Gegenstände von einer Leiche oder Truhe, sobald das Beutefenster bereit ist. Funktioniert zusammen mit der Auto-Plündern-Einstellung des Spiels.",
    ["FASTLOOT_TOGGLE_HIDE"] = "Beutefenster ausblenden",
    ["FASTLOOT_TOGGLE_HIDE_DESC"] = "Hält das Beutefenster verborgen, während Gegenstände automatisch geplündert werden. Wenn etwas nicht geplündert werden kann (volle Taschen, ein gesperrter Gegenstand oder ein Gegenstand, der einen Wurf oder eine Bestätigung braucht), erscheint das Fenster sofort.",
})
