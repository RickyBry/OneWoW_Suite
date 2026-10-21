-- Machine-drafted — deDE, pending native review.
local _, ns = ...
local M = ns.ModuleRegistry:Current()

OneWoW.Locale:Register(M._scope, "deDE", {
    ["REP_TITLE"] = "Rufverfolgung",
    ["REP_DESC"] = "Ersetzt die Ruf-Gewinnzeile im Chat durch die Summe dieser Sitzung und wie viel bis zur nächsten Stufe, Freundschaftsrang oder Ruhmstufe fehlt. Kann die Rufleiste auf diese Fraktion umschalten und zeigt andere Charaktere in Ruf-Tooltips.",
    ["REP_TOGGLE_CHAT"] = "Ausführlicher Ruf-Chat",
    ["REP_TOGGLE_CHAT_DESC"] = "Ersetzt die Ruf-Gewinnzeile durch den Gewinn, die Summe dieser Sitzung und wie viel noch fehlt. Der Bonus-Text des Spiels bleibt in der Zeile.",
    ["REP_TOGGLE_GUILD_CHAT"] = "Gildenruf im Chat auslassen",
    ["REP_TOGGLE_GUILD_CHAT_DESC"] = "Keine Chatzeile, wenn du Gildenruf erhältst.",
    ["REP_TOGGLE_HIDDEN"] = "Inaktive Fraktionen einbeziehen",
    ["REP_TOGGLE_HIDDEN_DESC"] = "Auch Gewinne für Fraktionen melden, die du auf inaktiv gesetzt hast und die das Spiel nicht im Chat ansagt.",
    ["REP_TOGGLE_SWITCH"] = "Rufleiste bei Gewinn umschalten",
    ["REP_TOGGLE_SWITCH_DESC"] = "Setzt die verfolgte Rufleiste auf eine Fraktion, wenn du bei ihr Ruf erhältst.",
    ["REP_TOGGLE_GUILD_SWITCH"] = "Bei Gildenruf nicht umschalten",
    ["REP_TOGGLE_GUILD_SWITCH_DESC"] = "Die verfolgte Leiste bleibt, wenn der Gewinn Gildenruf ist.",
    ["REP_TOGGLE_SILENT"] = "Keine Chatzeile beim Umschalten",
    ["REP_TOGGLE_SILENT_DESC"] = "Keine Chatzeile, wenn die verfolgte Rufleiste wechselt.",
    ["REP_TOGGLE_ALTS"] = "Andere Charaktere in Ruf-Tooltips",
    ["REP_TOGGLE_ALTS_DESC"] = "In einer Rufzeile oder an der verfolgten Rufleiste den Stand deiner anderen Charaktere anzeigen. Nutzt den von AltTracker gespeicherten Ruf.",
    ["REP_CHAT_SESSION"] = "Sitzung: %s",
    ["REP_CHAT_LEFT"] = "Bis %s: %s",
    ["REP_CHAT_LEFT_PLAIN"] = "Fehlt: %s",
    ["REP_CHAT_SWITCH"] = "Rufleiste gewechselt zu %s.",
    ["REP_ALT_HEADER"] = "Andere Charaktere",
    ["REP_ALT_LINE"] = "%s (%s / %s)",
    ["REP_ALT_PARAGON"] = "Paragon",
})
