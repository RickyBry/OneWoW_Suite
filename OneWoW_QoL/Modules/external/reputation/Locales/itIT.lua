-- Machine-drafted — itIT, pending native review.
local _, ns = ...
local M = ns.ModuleRegistry:Current()

OneWoW.Locale:Register(M._scope, "itIT", {
    ["REP_TITLE"] = "Tracciamento reputazione",
    ["REP_DESC"] = "Sostituisce la riga di guadagno reputazione in chat con il totale della sessione e quanto manca al livello successivo, grado di amicizia o fama. Può cambiare la barra della reputazione su quella fazione ed elenca gli altri personaggi nei suggerimenti della reputazione.",
    ["REP_TOGGLE_CHAT"] = "Chat dettagliata della reputazione",
    ["REP_TOGGLE_CHAT_DESC"] = "Sostituisce la riga di guadagno con il guadagno, il totale della sessione e quanto manca. Il testo del bonus del gioco resta sulla riga.",
    ["REP_TOGGLE_GUILD_CHAT"] = "Salta la reputazione di gilda",
    ["REP_TOGGLE_GUILD_CHAT_DESC"] = "Non mostra una riga quando ottieni reputazione di gilda.",
    ["REP_TOGGLE_HIDDEN"] = "Includi fazioni inattive",
    ["REP_TOGGLE_HIDDEN_DESC"] = "Annuncia anche i guadagni delle fazioni che hai spostato tra le inattive e che il gioco non annuncia in chat.",
    ["REP_TOGGLE_SWITCH"] = "Cambia barra al guadagno",
    ["REP_TOGGLE_SWITCH_DESC"] = "Imposta la barra della reputazione seguita su una fazione quando ottieni reputazione con essa.",
    ["REP_TOGGLE_GUILD_SWITCH"] = "Non cambiare per la gilda",
    ["REP_TOGGLE_GUILD_SWITCH_DESC"] = "Lascia la barra seguita com'è quando il guadagno è reputazione di gilda.",
    ["REP_TOGGLE_SILENT"] = "Nessuna riga al cambio barra",
    ["REP_TOGGLE_SILENT_DESC"] = "Non mostra una riga quando cambia la barra della reputazione seguita.",
    ["REP_TOGGLE_ALTS"] = "Altri personaggi nei suggerimenti",
    ["REP_TOGGLE_ALTS_DESC"] = "Su una riga di reputazione o sulla barra seguita, mostra il livello degli altri personaggi. Usa la reputazione salvata da AltTracker.",
    ["REP_CHAT_SESSION"] = "Sessione: %s",
    ["REP_CHAT_LEFT"] = "Manca a %s: %s",
    ["REP_CHAT_LEFT_PLAIN"] = "Manca: %s",
    ["REP_CHAT_SWITCH"] = "Barra della reputazione cambiata su %s.",
    ["REP_ALT_HEADER"] = "Altri personaggi",
    ["REP_ALT_LINE"] = "%s (%s / %s)",
    ["REP_ALT_PARAGON"] = "Paragon",
})
