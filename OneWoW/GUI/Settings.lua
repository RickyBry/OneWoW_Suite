-- ============================================================================
-- Shared settings store
-- ============================================================================
-- Suite appearance settings (theme, language, font keys, minimap, money display)
-- live in core OneWoW_DB. This file owns the get/set/migrate/callback API on
-- OneWoW_GUI. Font application lives in GUI/Fonts.lua.
-- ============================================================================

local OneWoW_GUI = OneWoW_GUI
local Constants = OneWoW_GUI.Constants

OneWoW_GUI._settingsDB = nil

local DEFAULT_THEME_KEY = Constants.DEFAULT_THEME_KEY

-- callbacks[event][owner] = func. Weak keys: a discarded owner frame drops out
-- without an explicit unregister. Fire order is unspecified.
local callbacks = {}

function OneWoW_GUI:RegisterSettingsCallback(event, owner, func)
    local bucket = callbacks[event]
    if not bucket then
        bucket = setmetatable({}, { __mode = "k" })
        callbacks[event] = bucket
    end
    bucket[owner] = func
end

function OneWoW_GUI:UnregisterSettingsCallback(event, owner)
    local bucket = callbacks[event]
    if bucket then
        bucket[owner] = nil
    end
end

local function FireCallbacks(event, value)
    local bucket = callbacks[event]
    if not bucket then return end
    -- Snapshot: a callback may rebuild UI that registers new owners mid-fire.
    local owners, funcs, n = {}, {}, 0
    for owner, func in pairs(bucket) do
        n = n + 1
        owners[n], funcs[n] = owner, func
    end
    for i = 1, n do
        local owner = owners[i]
        if bucket[owner] == funcs[i] then
            funcs[i](owner, value)
        end
    end
end

function OneWoW_GUI:GetSetting(key)
    local db = self._settingsDB

    if key == "theme" then return db.theme
    elseif key == "language" then return db.language
    elseif key == "font" then return db.font
    elseif key == "fontSizeOffset" then return db.fontSizeOffset
    elseif key == "minimap.hide" then return db.minimap.hide
    elseif key == "minimap.theme" then return db.minimap.theme
    elseif key == "featureIcons.style" then return db.featureIcons.style
    elseif key == "moneyDisplay.useLetters" then
        return db.moneyDisplay.useLetters == true
    elseif key == "moneyDisplay.useGrouping" then
        return db.moneyDisplay.useGrouping ~= false
    elseif key == "moneyDisplay.useRegionalNumbers" then
        return db.moneyDisplay.useRegionalNumbers ~= false
    elseif key == "moneyDisplay.useWhiteValues" then
        return db.moneyDisplay.useWhiteValues == true
    end
end

function OneWoW_GUI:SetSetting(key, value)
    local db = self._settingsDB

    if key == "theme" then
        db.theme = value
        self:ApplyTheme()
        FireCallbacks("OnThemeChanged", value)
    elseif key == "language" then
        db.language = value
        FireCallbacks("OnLanguageChanged", value)
    elseif key == "font" then
        db.font = value
        FireCallbacks("OnFontChanged", value)
    elseif key == "fontSizeOffset" then
        db.fontSizeOffset = value
        FireCallbacks("OnFontSizeChanged", value)
        FireCallbacks("OnFontChanged", db.font)
    elseif key == "minimap.hide" then
        if not db.minimap then db.minimap = {} end
        db.minimap.hide = value
        FireCallbacks("OnMinimapChanged", value)
    elseif key == "minimap.theme" then
        if not db.minimap then db.minimap = {} end
        db.minimap.theme = value
        FireCallbacks("OnIconThemeChanged", value)
    elseif key == "featureIcons.style" then
        if not db.featureIcons then db.featureIcons = {} end
        if value ~= "ringless" then
            value = "ring"
        end
        db.featureIcons.style = value
        FireCallbacks("OnFeatureIconStyleChanged", value)
    elseif key == "moneyDisplay.useLetters" then
        db.moneyDisplay.useLetters = value and true or false
        FireCallbacks("OnMoneyDisplayChanged", value)
    elseif key == "moneyDisplay.useGrouping" then
        db.moneyDisplay.useGrouping = value and true or false
        FireCallbacks("OnMoneyDisplayChanged", value)
    elseif key == "moneyDisplay.useRegionalNumbers" then
        db.moneyDisplay.useRegionalNumbers = value and true or false
        FireCallbacks("OnMoneyDisplayChanged", value)
    elseif key == "moneyDisplay.useWhiteValues" then
        db.moneyDisplay.useWhiteValues = value and true or false
        FireCallbacks("OnMoneyDisplayChanged", value)
    end
end

function OneWoW_GUI:MigrateSettings(sourceGlobal)
    local db = self._settingsDB
    if not sourceGlobal then return end
    if db._migrated then return end
    db._migrated = true

    if sourceGlobal.theme and sourceGlobal.theme ~= DEFAULT_THEME_KEY then
        db.theme = sourceGlobal.theme
    end
    if sourceGlobal.language then
        db.language = sourceGlobal.language
    end
    if sourceGlobal.font then
        db.font = sourceGlobal.font
    end
    if sourceGlobal.fontSizeOffset ~= nil then
        db.fontSizeOffset = sourceGlobal.fontSizeOffset
    end
    if sourceGlobal.minimap then
        if sourceGlobal.minimap.hide ~= nil then db.minimap.hide = sourceGlobal.minimap.hide end
        if sourceGlobal.minimap.theme then db.minimap.theme = sourceGlobal.minimap.theme end
    end
    if sourceGlobal.moneyDisplay then
        if sourceGlobal.moneyDisplay.useLetters ~= nil then db.moneyDisplay.useLetters = sourceGlobal.moneyDisplay.useLetters end
        if sourceGlobal.moneyDisplay.useGrouping ~= nil then db.moneyDisplay.useGrouping = sourceGlobal.moneyDisplay.useGrouping end
        if sourceGlobal.moneyDisplay.useRegionalNumbers ~= nil then db.moneyDisplay.useRegionalNumbers = sourceGlobal.moneyDisplay.useRegionalNumbers end
        if sourceGlobal.moneyDisplay.useWhiteValues ~= nil then db.moneyDisplay.useWhiteValues = sourceGlobal.moneyDisplay.useWhiteValues end
    end
end

-- Settings DB bootstrap. Called by core's OnAddonLoaded right after
-- InitializeDatabase, before any theme/font reads. Shared settings live in
-- core's OneWoW_DB, so the toolkit binds to core's db handle instead of
-- owning its own.
---@param db table the core OneWoW db handle returned by DB:Init
function OneWoW_GUI:InitializeSettings(db)
    OneWoW_GUI._settingsDBHandle = db
    OneWoW_GUI._settingsDB = db.global
    OneWoW_GUI:ApplyTheme()
    OneWoW_GUI:PrewarmFonts()
end
