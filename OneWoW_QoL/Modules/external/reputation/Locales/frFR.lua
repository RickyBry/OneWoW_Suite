-- Machine-drafted — frFR, pending native review.
local _, ns = ...
local M = ns.ModuleRegistry:Current()

OneWoW.Locale:Register(M._scope, "frFR", {
    ["REP_TITLE"] = "Suivi de réputation",
    ["REP_DESC"] = "Remplace la ligne de gain de réputation dans le chat par le total de la session et ce qu'il reste avant le prochain palier, rang d'amitié ou renom. Peut basculer la barre de réputation sur cette faction, et liste vos autres personnages dans les infobulles de réputation.",
    ["REP_TOGGLE_CHAT"] = "Chat détaillé des gains de réputation",
    ["REP_TOGGLE_CHAT_DESC"] = "Remplace la ligne de gain par le gain, le total de la session et ce qu'il reste. Le texte de bonus du jeu reste sur la ligne.",
    ["REP_TOGGLE_GUILD_CHAT"] = "Ignorer la réputation de guilde",
    ["REP_TOGGLE_GUILD_CHAT_DESC"] = "N'affiche pas de ligne quand vous gagnez de la réputation de guilde.",
    ["REP_TOGGLE_HIDDEN"] = "Inclure les factions inactives",
    ["REP_TOGGLE_HIDDEN_DESC"] = "Annonce aussi les gains des factions passées en inactif, que le jeu n'annonce pas dans le chat.",
    ["REP_TOGGLE_SWITCH"] = "Changer la barre de réputation au gain",
    ["REP_TOGGLE_SWITCH_DESC"] = "Met la barre de réputation suivie sur une faction quand vous gagnez de la réputation avec elle.",
    ["REP_TOGGLE_GUILD_SWITCH"] = "Ne pas changer pour la guilde",
    ["REP_TOGGLE_GUILD_SWITCH_DESC"] = "Laisse la barre suivie telle quelle quand le gain est de la réputation de guilde.",
    ["REP_TOGGLE_SILENT"] = "Pas de ligne quand la barre change",
    ["REP_TOGGLE_SILENT_DESC"] = "N'affiche pas de ligne quand la barre de réputation suivie change.",
    ["REP_TOGGLE_ALTS"] = "Autres personnages dans les infobulles",
    ["REP_TOGGLE_ALTS_DESC"] = "Sur une ligne de réputation ou la barre suivie, affiche le palier de vos autres personnages. Utilise la réputation enregistrée par AltTracker.",
    ["REP_CHAT_SESSION"] = "Session : %s",
    ["REP_CHAT_LEFT"] = "Reste avant %s : %s",
    ["REP_CHAT_LEFT_PLAIN"] = "Reste : %s",
    ["REP_CHAT_SWITCH"] = "Barre de réputation basculée sur %s.",
    ["REP_ALT_HEADER"] = "Autres personnages",
    ["REP_ALT_LINE"] = "%s (%s / %s)",
    ["REP_ALT_PARAGON"] = "Parangon",
})
