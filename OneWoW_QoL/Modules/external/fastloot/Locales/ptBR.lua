local _, ns = ...
local M = ns.ModuleRegistry:Current()

-- Machine-drafted — ptBR, pending native review.
OneWoW.Locale:Register(M._scope, "ptBR", {

    ["FASTLOOT_TITLE"] = "Saque rápido",
    ["FASTLOOT_DESC"] = "Saqueia automaticamente todos os itens de um cadáver ou baú no momento em que a janela de saque está pronta. Funciona junto com a configuração de saque automático do jogo.",
    ["FASTLOOT_TOGGLE_HIDE"] = "Ocultar janela de saque",
    ["FASTLOOT_TOGGLE_HIDE_DESC"] = "Mantém a janela de saque oculta enquanto os itens são saqueados automaticamente. Se algo não puder ser saqueado (bolsas cheias, um item bloqueado ou um item que exige rolagem ou confirmação), a janela aparece na hora.",
})
