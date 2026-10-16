local ADDON_NAME, ns = ...

local OneWoW_GUI = OneWoW_GUI

local L = ns.L

ns._loadedComponents = {}
ns._registeredAddons = {}
ns._minimapEntries = {}

function ns:RegisterMinimap(addon, label, tabKey, callback)
    -- addon: global name (e.g. "OneWoW_AltTracker")
    -- label: display string for context menu
    -- tabKey: for ns.UI:Show(tabKey) or nil if callback used
    -- callback: optional function() for custom open logic
    tinsert(self._minimapEntries, { addon = addon, label = label, tabKey = tabKey, callback = callback })
end

function ns:RegisterLoadComponent(displayName, version, command, addonName)
    self._registeredAddons[displayName] = true
    tinsert(self._loadedComponents, {
        name = displayName,
        ver = version,
        cmd = command,
        addon = addonName,
    })
end

local _defaultSaveTimer = nil
local function ScheduleDefaultSave()
    if _defaultSaveTimer then
        _defaultSaveTimer:Cancel()
    end
    _defaultSaveTimer = C_Timer.NewTimer(2, function()
        ns.Profiles.AutoSaveDefault()
    end)
end

local function ApplyLanguage()
    local lang = OneWoW_GUI:GetSetting("language")
    lang = lang or ns.db.global.language
    -- Locale service folds enUS <- selected language, refolds the stable ns.L
    -- view in place, and pushes BINDING_* globals. esMX->esES is normalized inside.
    ns.Locale:SetLanguage(lang)
end

local function RegisterSlashCommands()
    SLASH_ONEWOW1 = "/1w"
    SlashCmdList["ONEWOW"] = function()
        ns.UI:Toggle()
    end
end

function ns:OnAddonLoaded(loadedAddon)
    if loadedAddon ~= ADDON_NAME then return end

    -- Fresh accounts have an empty OneWoW_DB before Init. Capture that before
    -- MergeMissing fills defaults, then seed utility opt-outs after Init so
    -- login skips them while they stay Blizzard-enabled (LoadAddOn later this
    -- session). Existing SVs are left alone.
    local sv = OneWoW_DB
    local isFreshAccount = sv == nil or next(sv) == nil

    -- Core DB first, then the toolkit binds its settings handle to core's
    -- OneWoW_DB — before any theme/font reads or module UI built by the
    -- orchestrator below.
    self:InitializeDatabase()
    OneWoW_GUI:InitializeSettings(self.db)

    -- Read the persisted lifecycle-trace flag into memory before RunStartupPhase
    -- so a /reload captures the full startup orchestration from the first event.
    ns.Lifecycle.Trace:Sync()

    OneWoW_GUI:ApplyTheme(ns)
    ApplyLanguage()
    RegisterSlashCommands()

    OneWoW_GUI:RegisterSettingsCallback("OnThemeChanged", self, function(self2)
        OneWoW_GUI:ApplyTheme(ns)
        ScheduleDefaultSave()
        self2.UI:RefreshTheme()
    end)
    OneWoW_GUI:RegisterSettingsCallback("OnLanguageChanged", self, function(self2)
        ApplyLanguage()
        ScheduleDefaultSave()
        self2.UI:RebuildContent()
    end)
    OneWoW_GUI:RegisterSettingsCallback("OnMinimapChanged", self, function(self2, hidden)
        ScheduleDefaultSave()
        if hidden then
            self2.Minimap:Hide()
        else
            self2.Minimap:Show()
        end
    end)
    OneWoW_GUI:RegisterSettingsCallback("OnIconThemeChanged", self, function(self2)
        ScheduleDefaultSave()
        self2.Minimap:UpdateIcon()
        self2.UI:RebuildContent()
    end)
    OneWoW_GUI:RegisterSettingsCallback("OnFeatureIconStyleChanged", self, function(self2)
        ScheduleDefaultSave()
        self2.UI:RebuildContent()
    end)
    -- Fires for both a font swap and a size change. The main window is a font
    -- root, so its chrome re-fonts in place; tab content is rebuilt because it
    -- measures text at build time.
    OneWoW_GUI:RegisterSettingsCallback("OnFontChanged", self, function(self2)
        ScheduleDefaultSave()
        self2.UI:RebuildContent()
    end)

    local _ver = ns:GetAddonVersion(ADDON_NAME)
    self:RegisterLoadComponent("Core", _ver, "/1w", ADDON_NAME)

    self:RegisterMinimap("OneWoW", L["OPEN_ONEWOW"], nil, function()
        self.UI:Show()
    end)

    if isFreshAccount then
        ns.FirstRun:SeedUtilityOptOuts()
    end

    -- Pull enabled Tier-2 modules and their data stores now (still inside core's
    -- ADDON_LOADED, before PLAYER_LOGIN). EnsureLoaded drives each unit's
    -- OnAddonLoaded() hook synchronously, so every DB is built in dependency order
    -- before any PLAYER_LOGIN fires.
    ns.LoadOrchestrator:RunStartupPhase()
end

-- The core PLAYER_LOGIN sequence. Lives here (not in Core/Events.lua) so it keeps
-- file-local access to ADDON_NAME and the helpers above; Core/Events.lua owns the
-- shared event frame and invokes this on PLAYER_LOGIN.
function ns:RunCoreLoginSequence()
    -- Feature inits register themselves as "early" handlers in their own
    -- files; "late" handlers (integrations) run after the load banner.
    ns:FireCoreLoginHandlers("early")

    for _, comp in ipairs(ns.ModuleManifest or {}) do
        if not ns._registeredAddons[comp.display] and C_AddOns.IsAddOnLoaded(comp.addon) then
            ns:RegisterLoadComponent(comp.display, ns:GetAddonVersion(comp.addon), comp.cmd, comp.addon)
        end
    end

    local comps = ns._loadedComponents
    if comps and #comps > 0 then
        local ver = ns:GetAddonVersion(ADDON_NAME)
        local parts = {}
        for _, c in ipairs(comps) do
            tinsert(parts, "|cFFFFFFFF" .. c.name .. "|r")
        end
        print("|cFF00FF00OneWoW|r |cFF888888v." .. ver .. "|r: " .. table.concat(parts, " + ") .. " |cFF00FF00loaded|r - /1w")
    end

    -- First-run feature picker: show once per account. Delayed a few
    -- seconds so it appears AFTER the suite's load banner and any error
    -- popups have cleared. What's New only auto-shows when the wizard
    -- will not (upgrades, not brand-new installs).
    if ns.FirstRun:ShouldShowWizard() then
        C_Timer.After(3, function()
            if ns.FirstRun:ShouldShowWizard() then
                ns.FirstRun:ShowWizard()
            end
        end)
    else
        C_Timer.After(3, function()
            ns.WhatsNew:TryAutoShow()
        end)
    end

    ns:FireCoreLoginHandlers("late")
    ns:RunManifestLoginPhase()
end

_G["1WoW_OnAddonCompartmentClick"] = function()
    ns.UI:Toggle()
end

_G["1WoW_OnAddonCompartmentEnter"] = function(_, button)
    GameTooltip:SetOwner(button, "ANCHOR_LEFT")
    GameTooltip:SetText("|cFFFFD1001WoW|r", 1, 1, 1)
    local modCount = ns:GetLoadedModuleCount()
    if modCount > 0 then
        GameTooltip:AddLine(format(ns.L["MINIMAP_MODULES_LOADED"], modCount), 0.7, 0.7, 0.7)
    end
    GameTooltip:AddLine(ns.L["MINIMAP_TOOLTIP_HINT"], 0.7, 0.7, 0.7)
    GameTooltip:Show()
end

_G["1WoW_OnAddonCompartmentLeave"] = function()
    GameTooltip:Hide()
end
