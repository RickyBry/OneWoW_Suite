local _, ns = ...
local M = ns.ModuleRegistry:Current()

-- Machine-drafted — itIT (no official IT client), pending native review.
OneWoW.Locale:Register(M._scope, "itIT", {

    ["FASTLOOT_TITLE"] = "Saccheggio rapido",
    ["FASTLOOT_DESC"] = "Saccheggia automaticamente tutti gli oggetti da un cadavere o forziere nel momento in cui la finestra del bottino è pronta. Funziona insieme all'impostazione di saccheggio automatico del gioco.",
    ["FASTLOOT_TOGGLE_HIDE"] = "Nascondi finestra del bottino",
    ["FASTLOOT_TOGGLE_HIDE_DESC"] = "Mantiene nascosta la finestra del bottino mentre gli oggetti vengono raccolti automaticamente. Se qualcosa non può essere raccolto (borse piene, un oggetto bloccato o un oggetto che richiede un tiro o una conferma), la finestra appare subito.",
})
