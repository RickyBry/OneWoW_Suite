-- Machine-drafted — ptBR, pending native review.
local _, ns = ...
local M = ns.ModuleRegistry:Current()

OneWoW.Locale:Register(M._scope, "ptBR", {
    ["REP_TITLE"] = "Rastreador de reputação",
    ["REP_DESC"] = "Substitui a linha de ganho de reputação no chat pelo total da sessão e quanto falta para o próximo nível, posto de amizade ou renome. Pode trocar a barra de reputação para essa facção e lista seus outros personagens nas dicas de reputação.",
    ["REP_TOGGLE_CHAT"] = "Chat detalhado de reputação",
    ["REP_TOGGLE_CHAT_DESC"] = "Substitui a linha de ganho pelo ganho, o total da sessão e quanto falta. O texto de bônus do jogo permanece na linha.",
    ["REP_TOGGLE_GUILD_CHAT"] = "Ignorar reputação da guilda",
    ["REP_TOGGLE_GUILD_CHAT_DESC"] = "Não mostra uma linha quando você ganha reputação da guilda.",
    ["REP_TOGGLE_HIDDEN"] = "Incluir facções inativas",
    ["REP_TOGGLE_HIDDEN_DESC"] = "Também anuncia ganhos de facções que você moveu para inativas e que o jogo não anuncia no chat.",
    ["REP_TOGGLE_SWITCH"] = "Trocar a barra ao ganhar reputação",
    ["REP_TOGGLE_SWITCH_DESC"] = "Define a barra de reputação acompanhada para uma facção quando você ganha reputação com ela.",
    ["REP_TOGGLE_GUILD_SWITCH"] = "Não trocar pela guilda",
    ["REP_TOGGLE_GUILD_SWITCH_DESC"] = "Deixa a barra acompanhada como está quando o ganho é reputação da guilda.",
    ["REP_TOGGLE_SILENT"] = "Sem linha ao trocar a barra",
    ["REP_TOGGLE_SILENT_DESC"] = "Não mostra uma linha quando a barra de reputação acompanhada muda.",
    ["REP_TOGGLE_ALTS"] = "Outros personagens nas dicas",
    ["REP_TOGGLE_ALTS_DESC"] = "Em uma linha de reputação ou na barra acompanhada, mostra o nível dos seus outros personagens. Usa a reputação salva pelo AltTracker.",
    ["REP_CHAT_SESSION"] = "Sessão: %s",
    ["REP_CHAT_LEFT"] = "Falta para %s: %s",
    ["REP_CHAT_LEFT_PLAIN"] = "Falta: %s",
    ["REP_CHAT_SWITCH"] = "Barra de reputação trocada para %s.",
    ["REP_ALT_HEADER"] = "Outros personagens",
    ["REP_ALT_LINE"] = "%s (%s / %s)",
    ["REP_ALT_PARAGON"] = "Paragão",
})
