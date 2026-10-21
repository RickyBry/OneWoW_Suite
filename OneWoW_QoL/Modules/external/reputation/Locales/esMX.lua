-- Machine-drafted — esMX (LatAm terms applied: presionar, mouse), pending native review.
local _, ns = ...
local M = ns.ModuleRegistry:Current()

OneWoW.Locale:Register(M._scope, "esMX", {
    ["REP_TITLE"] = "Seguimiento de reputación",
    ["REP_DESC"] = "Sustituye la línea de ganancia de reputación del chat por el total de la sesión y lo que falta para el siguiente nivel, rango de amistad o renombre. Puede cambiar la barra de reputación a esa facción y muestra tus otros personajes en las descripciones de reputación.",
    ["REP_TOGGLE_CHAT"] = "Chat detallado de reputación",
    ["REP_TOGGLE_CHAT_DESC"] = "Sustituye la línea de ganancia por la ganancia, el total de la sesión y lo que falta. El texto de bonus del juego se mantiene en la línea.",
    ["REP_TOGGLE_GUILD_CHAT"] = "Omitir la reputación de hermandad",
    ["REP_TOGGLE_GUILD_CHAT_DESC"] = "No muestra una línea cuando ganas reputación de hermandad.",
    ["REP_TOGGLE_HIDDEN"] = "Incluir facciones inactivas",
    ["REP_TOGGLE_HIDDEN_DESC"] = "También anuncia ganancias de facciones que pasaste a inactivas y que el juego no anuncia en el chat.",
    ["REP_TOGGLE_SWITCH"] = "Cambiar la barra al ganar reputación",
    ["REP_TOGGLE_SWITCH_DESC"] = "Pone la barra de reputación seguida en una facción cuando ganas reputación con ella.",
    ["REP_TOGGLE_GUILD_SWITCH"] = "No cambiar con la hermandad",
    ["REP_TOGGLE_GUILD_SWITCH_DESC"] = "Deja la barra seguida como está cuando la ganancia es reputación de hermandad.",
    ["REP_TOGGLE_SILENT"] = "Sin línea al cambiar la barra",
    ["REP_TOGGLE_SILENT_DESC"] = "No muestra una línea cuando cambia la barra de reputación seguida.",
    ["REP_TOGGLE_ALTS"] = "Otros personajes en las descripciones",
    ["REP_TOGGLE_ALTS_DESC"] = "En una fila de reputación o en la barra seguida, muestra el nivel de tus otros personajes. Usa la reputación guardada por AltTracker.",
    ["REP_CHAT_SESSION"] = "Sesión: %s",
    ["REP_CHAT_LEFT"] = "Falta para %s: %s",
    ["REP_CHAT_LEFT_PLAIN"] = "Falta: %s",
    ["REP_CHAT_SWITCH"] = "Barra de reputación cambiada a %s.",
    ["REP_ALT_HEADER"] = "Otros personajes",
    ["REP_ALT_LINE"] = "%s (%s / %s)",
    ["REP_ALT_PARAGON"] = "Paragón",
})
