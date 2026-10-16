local _, ns = ...

local C_AddOns = C_AddOns
local C_Map = C_Map
local EventRegistry = EventRegistry
local GetExpansionLevel = GetExpansionLevel
local GetInstanceInfo = GetInstanceInfo
local pairs, type, tonumber = pairs, type, tonumber
local tinsert, sort = tinsert, sort

-- ============================================================================
-- CatalogData
-- ============================================================================
-- Discovers installed OneWoW_CatDB_<Era> addons (plus Other), owns per-era
-- topic toggles, and loads only the shards a Catalog role needs. Era Data/
-- and DataExtra/ files register factories via Defer; tables are built when
-- the topic is enabled.
--
-- Role APIs live on Catalog (OneWoW_Catalog): journal/zones, vendors,
-- quests/archive, items. Tradeskills stay OneWoW_CatDB_TradeSkillDB.
-- ============================================================================

local CatalogData = {}
ns.CatalogData = CatalogData

local RUNTIME_ADDON = "OneWoW_Catalog"
local TRADESKILL_ADDON = "OneWoW_CatDB_TradeSkillDB"
local OTHER_ADDON = "OneWoW_CatDB_Other"
local OTHER_EXPANSION_ID = 99

local TOPICS = {
    "hubs",
    "zone",
    "zone_extra",
    "npc",
    "quest",
    "item",
    "achievement",
    "mappin",
}

local TOPIC_SET = {}
for i = 1, #TOPICS do
    TOPIC_SET[TOPICS[i]] = true
end

-- Suite expansion 1-12 -> LE expansion 0-11 (GetExpansionName).
local SUITE_TO_LE = {
    [1] = 0, [2] = 1, [3] = 2, [4] = 3, [5] = 4, [6] = 5,
    [7] = 6, [8] = 7, [9] = 8, [10] = 9, [11] = 10, [12] = 11,
}

local LE_TO_SUITE = {}
for suite, le in pairs(SUITE_TO_LE) do
    LE_TO_SUITE[le] = suite
end

local journalShardJob
local journalShardOnUpdate
local roleShardJobs = {}
local roleShardOnUpdate = {}
local TOPIC_DEFAULTS_VERSION = 2

local ROLE_API = {
    journal = "OneWoW_CatDB_ZoneDB_API",
    zones = "OneWoW_CatDB_ZoneDB_API",
    vendors = "OneWoW_CatDB_NPCDB_API",
    npcs = "OneWoW_CatDB_NPCDB_API",
    quests = "OneWoW_CatDB_QuestDBCurrent_API",
    archive = "OneWoW_CatDB_QuestDBCurrent_API",
    items = "OneWoW_CatDB_ItemDB_API",
    tradeskills = "OneWoW_CatDB_TradeSkillDB_API",
}

local ROLE_TOPICS = {
    journal = { hubs = true, zone = true, zone_extra = true },
    zones = { hubs = true, zone = true, zone_extra = true },
    vendors = { npc = true },
    npcs = { npc = true },
    quests = { quest = true },
    archive = { quest = true },
    items = { item = true, achievement = true },
}

local ROLE_RUNTIME = {
    journal = RUNTIME_ADDON,
    zones = RUNTIME_ADDON,
    vendors = RUNTIME_ADDON,
    npcs = RUNTIME_ADDON,
    quests = RUNTIME_ADDON,
    archive = RUNTIME_ADDON,
    items = RUNTIME_ADDON,
    tradeskills = TRADESKILL_ADDON,
}

-- LE expansion 0-9 (Classic-Dragonflight) used to live in Quest Archive.
local ARCHIVE_LE_MAX = 9

local factories = {} -- [addon][topic] = { fn, ... }
local activated = {} -- [addon][topic] = true
local sinks = {} -- [topic] = fn
local scanned
local eras -- sorted list of { addon, expansionID, title }
local mapEras -- { here, instance, contents } from Catalog's MapExpansion.lua
local playerPlaceKey
local playerPlace = { here = {}, contents = {} }

local function TopicsStore()
    return ns.db.global.catalogTopics
end

local function DefaultTopicOn(expansionID, topic)
    if topic == "zone_extra" then
        return false
    end
    if expansionID == OTHER_EXPANSION_ID then
        return topic == "item" or topic == "achievement"
    end
    -- Expansion on means every Catalog tab can use that pack. zone_extra stays
    -- off (heavy extras). Uncheck a topic in Manage Features to skip it.
    return true
end

local function ScanInstalled()
    if scanned then
        return
    end
    scanned = true
    eras = {}
    local n = C_AddOns.GetNumAddOns()
    for i = 1, n do
        local name = C_AddOns.GetAddOnInfo(i)
        local exp = C_AddOns.GetAddOnMetadata(name, "X-OneWoW-CatDB")
        if exp and exp ~= "" then
            local expansionID = tonumber(exp)
            local title
            if expansionID == OTHER_EXPANSION_ID then
                title = ns.L["CAT_MOD_ERA_OTHER"]
            else
                local le = SUITE_TO_LE[expansionID]
                title = le and ns:GetExpansionName(le) or name
            end
            tinsert(eras, {
                addon = name,
                expansionID = expansionID,
                title = title,
            })
        end
    end
    sort(eras, function(a, b)
        if a.expansionID == b.expansionID then
            return a.addon < b.addon
        end
        return a.expansionID < b.expansionID
    end)
end

--- Flip persisted old defaults so a ticked expansion feeds every Catalog tab.
function CatalogData:MigrateTopicDefaults()
    local db = ns.db.global
    if (db.catalogTopicsVersion or 0) >= TOPIC_DEFAULTS_VERSION then
        return
    end
    ScanInstalled()
    local store = TopicsStore()
    for i = 1, #eras do
        local era = eras[i]
        if era.expansionID ~= OTHER_EXPANSION_ID and era.expansionID < 11 then
            local row = store[era.addon]
            if row then
                if row.npc == false then
                    row.npc = true
                end
                if row.quest == false then
                    row.quest = true
                end
                if row.item == false then
                    row.item = true
                end
                if row.achievement == false then
                    row.achievement = true
                end
                if row.mappin == false then
                    row.mappin = true
                end
            end
        end
    end
    db.catalogTopicsVersion = TOPIC_DEFAULTS_VERSION
end

function CatalogData:GetTopics()
    return TOPICS
end

function CatalogData:IsRuntimeAddon(name)
    return name == RUNTIME_ADDON
end

function CatalogData:IsEraAddon(name)
    ScanInstalled()
    for i = 1, #eras do
        if eras[i].addon == name then
            return true
        end
    end
    return false
end

function CatalogData:GetEras()
    ScanInstalled()
    return eras
end

function CatalogData:GetEra(addon)
    ScanInstalled()
    for i = 1, #eras do
        if eras[i].addon == addon then
            return eras[i]
        end
    end
    return nil
end

function CatalogData:GetStoreTitle(store)
    if store == TRADESKILL_ADDON then
        return ns.L["CAT_MOD_TRADESKILLDB"]
    end
    local era = self:GetEra(store)
    if era then
        if era.expansionID == OTHER_EXPANSION_ID then
            return ns.L["CAT_MOD_ERA_OTHER"]
        end
        return era.title
    end
    return nil
end

function CatalogData:IsTopic(topic)
    return TOPIC_SET[topic] == true
end

function CatalogData:IsTopicEnabled(addon, topic)
    if not TOPIC_SET[topic] then
        return false
    end
    local store = TopicsStore()
    local row = store[addon]
    if row and row[topic] ~= nil then
        return row[topic] and true or false
    end
    local era = self:GetEra(addon)
    if not era then
        return false
    end
    return DefaultTopicOn(era.expansionID, topic)
end

function CatalogData:SetTopicEnabled(addon, topic, enabled)
    if not TOPIC_SET[topic] then
        return
    end
    local store = TopicsStore()
    store[addon] = store[addon] or {}
    store[addon][topic] = enabled and true or false
    if enabled and C_AddOns.IsAddOnLoaded(addon) then
        self:ActivateTopic(addon, topic)
    end
end

function CatalogData:GetDefaultTopicEnabled(addon, topic)
    local era = self:GetEra(addon)
    if not era then
        return false
    end
    return DefaultTopicOn(era.expansionID, topic)
end

--- Era Data/ and DataExtra/ files call this at parse time. `factory` is not run until Activate.
--- Multiple Defer calls for the same topic merge (base then extra).
---@param addon string
---@param topic string
---@param factory function
function CatalogData:Defer(addon, topic, factory)
    if type(factory) ~= "function" or not TOPIC_SET[topic] then
        return
    end
    factories[addon] = factories[addon] or {}
    local list = factories[addon][topic]
    if not list then
        list = {}
        factories[addon][topic] = list
    end
    tinsert(list, factory)
end

---@param topic string
---@param fn function
function CatalogData:SetSink(topic, fn)
    sinks[topic] = fn
end

function CatalogData:ActivateTopic(addon, topic)
    if not TOPIC_SET[topic] then
        return
    end
    activated[addon] = activated[addon] or {}
    if activated[addon][topic] then
        return
    end
    local bag = factories[addon]
    local list = bag and bag[topic]
    if type(list) ~= "table" then
        return
    end
    local sink = sinks[topic]
    for i = 1, #list do
        local payload = list[i]()
        if sink and payload ~= nil then
            sink(payload, addon, topic)
        end
    end
    activated[addon][topic] = true
    EventRegistry:TriggerEvent("ns.CatalogTopicActivated", addon, topic)
end

function CatalogData:ActivateEnabled(addon)
    for i = 1, #TOPICS do
        local topic = TOPICS[i]
        if self:IsTopicEnabled(addon, topic) then
            self:ActivateTopic(addon, topic)
        end
    end
end

local function RoleNeedsEra(self, role, era)
    local topics = ROLE_TOPICS[role]
    if not topics then
        return false
    end
    if role == "archive" then
        local le = SUITE_TO_LE[era.expansionID]
        if not le or le > ARCHIVE_LE_MAX then
            return false
        end
    end
    for topic in pairs(topics) do
        if self:IsTopicEnabled(era.addon, topic) then
            return true
        end
    end
    return false
end

function CatalogData:ResolveRoleAddon(roleOrName)
    if ROLE_RUNTIME[roleOrName] then
        return ROLE_RUNTIME[roleOrName]
    end
    if self:IsEraAddon(roleOrName) then
        return roleOrName
    end
    if roleOrName == RUNTIME_ADDON or roleOrName == TRADESKILL_ADDON then
        return roleOrName
    end
    return nil
end

function CatalogData:GetRoleAPIName(roleOrName)
    if ROLE_API[roleOrName] then
        return ROLE_API[roleOrName]
    end
    return nil
end

function CatalogData:GetRoleAPI(roleOrName)
    local apiName = ROLE_API[roleOrName]
    if not apiName then
        return nil
    end
    return _G[apiName]
end

function CatalogData:IsRoleAvailable(roleOrName)
    if roleOrName == "tradeskills" or roleOrName == TRADESKILL_ADDON then
        if not C_AddOns.DoesAddOnExist(TRADESKILL_ADDON) then
            return false
        end
        if not ns:IsFeatureWanted(RUNTIME_ADDON) then
            return false
        end
        return ns:IsFeatureWanted(TRADESKILL_ADDON)
    end
    if not C_AddOns.DoesAddOnExist(RUNTIME_ADDON) then
        return false
    end
    if not ns:IsFeatureWanted(RUNTIME_ADDON) then
        return false
    end
    ScanInstalled()
    if roleOrName == RUNTIME_ADDON then
        return true
    end
    local role = ROLE_TOPICS[roleOrName] and roleOrName or nil
    if not role then
        return self:IsEraAddon(roleOrName) and ns:IsAddonEnabled(roleOrName)
    end
    for i = 1, #eras do
        local era = eras[i]
        if ns:IsFeatureWanted(era.addon) and RoleNeedsEra(self, role, era) then
            return true
        end
    end
    -- Runtime can still answer empty queries when no era topic is on.
    return true
end

local function FinishRoleRuntime(role)
    if role == "quests" or role == "archive" then
        OneWoW_Catalog.EnsureCatDBQuestRuntime()
    elseif role == "vendors" or role == "npcs" then
        OneWoW_Catalog.EnsureCatDBVendorRuntime()
    end
end

--- Load runtime + the player's expansion for this role, then activate.
---@param roleOrName string
---@return string|nil runtimeAddon
function CatalogData:EnsureRole(roleOrName)
    if roleOrName == "tradeskills" or roleOrName == TRADESKILL_ADDON then
        ns:EnsureLoaded(RUNTIME_ADDON)
        ns:EnsureLoaded(TRADESKILL_ADDON)
        return TRADESKILL_ADDON
    end
    if not ns:EnsureLoaded(RUNTIME_ADDON) then
        return nil
    end
    if self:IsEraAddon(roleOrName) then
        ns:EnsureLoaded(roleOrName)
        self:ActivateEnabled(roleOrName)
        return RUNTIME_ADDON
    end
    local role = ROLE_TOPICS[roleOrName] and roleOrName or nil
    -- Only the player's expansion. Other eras load on an explicit All filter
    -- or a cross-era search (EnsureRoleShardsForFilter with 0).
    if role then
        self:EnsureRoleShards(role, self:GetPlayerSuiteExpansionID())
        FinishRoleRuntime(role)
    end
    return RUNTIME_ADDON
end

function CatalogData:IsTopicActivated(addon, topic)
    return activated[addon] and activated[addon][topic] == true
end

local function EraRoleTopicsReady(self, era, topics)
    if not C_AddOns.IsAddOnLoaded(era.addon) then
        return false
    end
    for topic in pairs(topics) do
        if self:IsTopicEnabled(era.addon, topic) and not self:IsTopicActivated(era.addon, topic) then
            return false
        end
    end
    return true
end

local function TradeskillRoleReady(self)
    if not ns:IsFeatureWanted(RUNTIME_ADDON) then
        return false
    end
    if not ns:IsFeatureWanted(TRADESKILL_ADDON) then
        return false
    end
    if not C_AddOns.DoesAddOnExist(TRADESKILL_ADDON) then
        return false
    end
    return C_AddOns.IsAddOnLoaded(TRADESKILL_ADDON) and self:GetRoleAPI("tradeskills") ~= nil
end

--- wanted eras for this role, and how many of those have their topics activated.
---@return number wanted
---@return number ready
local function CountRoleEraReadiness(self, role)
    ScanInstalled()
    local topics = ROLE_TOPICS[role]
    local wanted, ready = 0, 0
    for i = 1, #eras do
        local era = eras[i]
        if (role == "journal" or role == "zones") and era.expansionID == OTHER_EXPANSION_ID then
            -- Other has no Journal places.
        elseif ns:IsFeatureWanted(era.addon) and RoleNeedsEra(self, role, era) then
            wanted = wanted + 1
            if EraRoleTopicsReady(self, era, topics) then
                ready = ready + 1
            end
        end
    end
    return wanted, ready
end

--- True when this role can answer a query from already-loaded expansion data.
--- Journal is ready when any wanted expansion is activated (not every era).
---@param roleOrName string
---@return boolean
function CatalogData:IsRoleQueryReady(roleOrName)
    if roleOrName == "tradeskills" or roleOrName == TRADESKILL_ADDON then
        return TradeskillRoleReady(self)
    end
    if not ns:IsFeatureWanted(RUNTIME_ADDON) then
        return false
    end
    if not C_AddOns.IsAddOnLoaded(RUNTIME_ADDON) then
        return false
    end
    if not self:GetRoleAPI(roleOrName) then
        return false
    end
    local role = ROLE_TOPICS[roleOrName] and roleOrName or nil
    if not role then
        return self:IsEraAddon(roleOrName) and C_AddOns.IsAddOnLoaded(roleOrName)
    end
    local _, ready = CountRoleEraReadiness(self, role)
    return ready > 0
end

--- True when every wanted expansion for this role is loaded and activated
--- (nothing left to load; also true when no expansion is wanted).
---@param roleOrName string
---@return boolean
function CatalogData:IsRoleFullyLoaded(roleOrName)
    if roleOrName == "tradeskills" or roleOrName == TRADESKILL_ADDON then
        return TradeskillRoleReady(self)
    end
    if not ns:IsFeatureWanted(RUNTIME_ADDON) then
        return false
    end
    if not C_AddOns.IsAddOnLoaded(RUNTIME_ADDON) then
        return false
    end
    if not self:GetRoleAPI(roleOrName) then
        return false
    end
    local role = ROLE_TOPICS[roleOrName] and roleOrName or nil
    if not role then
        return self:IsEraAddon(roleOrName) and C_AddOns.IsAddOnLoaded(roleOrName)
    end
    local wanted, ready = CountRoleEraReadiness(self, role)
    return ready == wanted
end

--- Player-facing reason a Catalog-backed line is empty. Nil when a requested
--- role can already answer from loaded data (even if other eras are still LoD).
---@param roleOrRoles string|string[]
---@return string|nil
function CatalogData:GetUnavailableNotice(roleOrRoles)
    local roles
    if type(roleOrRoles) == "table" then
        roles = roleOrRoles
    elseif roleOrRoles then
        roles = { roleOrRoles }
    else
        return nil
    end

    if not ns:IsFeatureWanted(RUNTIME_ADDON) then
        return ns.L["CATALOG_NOT_ENABLED"]
    end

    for i = 1, #roles do
        if self:IsRoleQueryReady(roles[i]) then
            return nil
        end
    end
    return ns.L["CATALOG_NOT_LOADED"]
end

--- Map -> expansion index (Catalog CatDB/Data/MapExpansion.lua). Lets the
--- player's expansion be picked before any era pack loads.
---@param source { here: table<number, number>, instance: table<number, number[]>, contents: table<number, number[]> }
function CatalogData:SetMapExpansions(source)
    mapEras = source
    playerPlaceKey = nil
end

local function FindEra(expansionID)
    ScanInstalled()
    for i = 1, #eras do
        local era = eras[i]
        if era.expansionID == expansionID then
            return era
        end
    end
    return nil
end

local function IsEraWanted(expansionID)
    local era = FindEra(expansionID)
    return era ~= nil and ns:IsFeatureWanted(era.addon)
end

local function AppendUnique(dest, seen, list)
    if not list then
        return
    end
    for i = 1, #list do
        local id = list[i]
        if not seen[id] then
            seen[id] = true
            tinsert(dest, id)
        end
    end
end

--- Instance map IDs and world uiMapIDs share numbers; only use instance keys while instanced.
local function PlayerInstanceMapID()
    local _, instanceType, _, _, _, _, _, instanceMapID = GetInstanceInfo()
    if instanceType and instanceType ~= "none" and instanceMapID and instanceMapID > 0 then
        return instanceMapID
    end
    return nil
end

--- Eras of the player's place ("here") and of the places listed on that map
--- ("contents"). Mirrors the Zones scope resolver; cached per map.
local function ResolvePlayerPlace()
    local instanceMapID = PlayerInstanceMapID()
    local current = C_Map.GetBestMapForUnit("player")
    local key = (instanceMapID or 0) * 100000 + (current or 0)
    if key == playerPlaceKey then
        return playerPlace
    end
    local here, contents = {}, {}
    playerPlace.here, playerPlace.contents = here, contents
    if not mapEras then
        return playerPlace
    end
    playerPlaceKey = key
    local hereSeen, contentsSeen = {}, {}

    local interior = instanceMapID and mapEras.instance[instanceMapID]
    if interior then
        AppendUnique(here, hereSeen, interior)
        AppendUnique(contents, contentsSeen, interior)
        return playerPlace
    end

    local root = current
    local id = current
    for _ = 1, 8 do
        if not id or id == 0 then
            break
        end
        local era = mapEras.here[id]
        if era then
            root = id
            AppendUnique(here, hereSeen, { era })
            break
        end
        local info = C_Map.GetMapInfo(id)
        id = info and info.parentMapID
    end
    if not root then
        return playerPlace
    end
    AppendUnique(contents, contentsSeen, here)
    AppendUnique(contents, contentsSeen, mapEras.contents[root])
    local children = C_Map.GetMapChildrenInfo(root, nil, true)
    if children then
        for i = 1, #children do
            AppendUnique(contents, contentsSeen, mapEras.contents[children[i].mapID])
        end
    end
    return playerPlace
end

--- Wanted expansions for the player's place. With includeContents, also the
--- expansions of the dungeons, raids, Delves, and cities listed on that map.
--- Empty until Catalog has loaded (the map index ships with it).
---@param includeContents boolean|nil
---@return number[] expansionIDs
function CatalogData:GetPlayerPlaceExpansions(includeContents)
    local place = ResolvePlayerPlace()
    local list = includeContents and place.contents or place.here
    local out = {}
    for i = 1, #list do
        if IsEraWanted(list[i]) then
            tinsert(out, list[i])
        end
    end
    return out
end

--- Expansions whose places sit on this map (zone card by uiMapID, or interior
--- places by instance mapID / uiMapID). Empty until Catalog has loaded.
---@param mapID number
---@return number[] expansionIDs
function CatalogData:GetMapPlaceExpansions(mapID)
    local out, seen = {}, {}
    if mapEras and mapID then
        local era = mapEras.here[mapID]
        if era then
            seen[era] = true
            out[1] = era
        end
        AppendUnique(out, seen, mapEras.instance[mapID])
    end
    return out
end

--- Suite expansion of the player's place, else the client's current expansion.
---@return number expansionID 0 when no journal pack is wanted
function CatalogData:GetPlayerSuiteExpansionID()
    local here = self:GetPlayerPlaceExpansions(false)
    if here[1] then
        return here[1]
    end
    return self:GetCurrentSuiteExpansionID()
end

local function PlayerHereExpansions(self)
    local here = self:GetPlayerPlaceExpansions(false)
    if #here == 0 then
        here[1] = self:GetCurrentSuiteExpansionID()
    end
    return here
end

--- True when Catalog is up and the Journal place topics (hubs + zone) for the
--- player's place are loaded. Missing a shard means this place's card/toast
--- should say Zones Catalog is not loaded.
function CatalogData:ArePlayerJournalPlacesLoaded()
    if not C_AddOns.IsAddOnLoaded(RUNTIME_ADDON) then
        return false
    end
    if not self:GetRoleAPI("journal") then
        return false
    end
    local here = PlayerHereExpansions(self)
    for i = 1, #here do
        local era = FindEra(here[i])
        if era then
            if not C_AddOns.IsAddOnLoaded(era.addon) then
                return false
            end
            if not self:IsTopicActivated(era.addon, "hubs") or not self:IsTopicActivated(era.addon, "zone") then
                return false
            end
        end
    end
    return true
end

local function ActivateJournalEra(self, era)
    ns:EnsureLoaded(era.addon)
    self:ActivateTopic(era.addon, "hubs")
    self:ActivateTopic(era.addon, "zone")
    if self:IsTopicEnabled(era.addon, "zone_extra") then
        self:ActivateTopic(era.addon, "zone_extra")
    end
    if self:IsTopicEnabled(era.addon, "mappin") then
        self:ActivateTopic(era.addon, "mappin")
    end
end

function CatalogData:CancelJournalShardJob()
    if journalShardJob then
        local job = journalShardJob
        journalShardJob = nil
        journalShardOnUpdate = nil
        job:Cancel()
    end
end

--- Suite expansion for the client's current expansion, or the newest wanted pack.
---@return number expansionID 0 when no journal pack is wanted
function CatalogData:GetCurrentSuiteExpansionID()
    ScanInstalled()
    local current = LE_TO_SUITE[GetExpansionLevel()] or 12
    for i = 1, #eras do
        local era = eras[i]
        if era.expansionID == current and ns:IsFeatureWanted(era.addon) then
            return current
        end
    end
    for i = #eras, 1, -1 do
        local era = eras[i]
        if era.expansionID ~= OTHER_EXPANSION_ID and ns:IsFeatureWanted(era.addon) then
            return era.expansionID
        end
    end
    return 0
end

--- Wanted expansions for a Catalog role dropdown (even before those shards load).
---@param role string
---@param useLeId boolean|nil vendors/quests use LE expansion IDs
---@return { expansionID: number, displayName: string, id: number, name: string }[]
function CatalogData:GetWantedRoleExpansions(role, useLeId)
    ScanInstalled()
    local out = {}
    local journal = role == "journal" or role == "zones"
    for i = 1, #eras do
        local era = eras[i]
        if era.expansionID ~= OTHER_EXPANSION_ID and ns:IsFeatureWanted(era.addon) then
            if journal or RoleNeedsEra(self, role, era) then
                local id = era.expansionID
                if useLeId then
                    id = SUITE_TO_LE[era.expansionID]
                end
                if id ~= nil then
                    tinsert(out, {
                        expansionID = id,
                        displayName = era.title,
                        id = id,
                        name = era.title,
                    })
                end
            end
        end
    end
    return out
end

--- Wanted Journal expansions for the Zones dropdown (even before those shards load).
---@return { expansionID: number, displayName: string }[]
function CatalogData:GetWantedJournalExpansions()
    return self:GetWantedRoleExpansions("journal")
end

--- Load hubs + zone for one suite expansion (no-op for 0 / All).
---@param expansionID number
function CatalogData:EnsureJournalShards(expansionID)
    if not expansionID or expansionID == 0 then
        return
    end
    ns:EnsureLoaded(RUNTIME_ADDON)
    ScanInstalled()
    for i = 1, #eras do
        local era = eras[i]
        if era.expansionID == expansionID and ns:IsFeatureWanted(era.addon) then
            ActivateJournalEra(self, era)
            return
        end
    end
end

--- Load the selected expansion now. All loads the player's expansion first, then
--- the rest across frames so opening Zones does not hitch every pack on one paint.
---@param expansionID number
---@param onUpdate function|nil
function CatalogData:EnsureJournalShardsForFilter(expansionID, onUpdate)
    ns:EnsureLoaded(RUNTIME_ADDON)
    ScanInstalled()
    if expansionID and expansionID ~= 0 then
        self:CancelJournalShardJob()
        self:EnsureJournalShards(expansionID)
        return
    end
    local current = self:GetPlayerSuiteExpansionID()
    if current ~= 0 then
        self:EnsureJournalShards(current)
    end
    if onUpdate then
        journalShardOnUpdate = onUpdate
    end
    if journalShardJob then
        return
    end
    local pending = {}
    for i = 1, #eras do
        local era = eras[i]
        if era.expansionID ~= OTHER_EXPANSION_ID
            and era.expansionID ~= current
            and ns:IsFeatureWanted(era.addon)
        then
            if not (self:IsTopicActivated(era.addon, "hubs") and self:IsTopicActivated(era.addon, "zone")) then
                tinsert(pending, era)
            end
        end
    end
    if #pending == 0 then
        journalShardOnUpdate = nil
        return
    end
    journalShardJob = ns.ChunkedJob.Start({
        budgetMs = 8,
        run = function(shouldYield)
            for i = 1, #pending do
                ActivateJournalEra(self, pending[i])
                ns.ChunkedJob.YieldIfNeeded(shouldYield)
            end
        end,
        onProgress = function()
            if journalShardOnUpdate then
                journalShardOnUpdate()
            end
        end,
        onComplete = function()
            journalShardJob = nil
            local cb = journalShardOnUpdate
            journalShardOnUpdate = nil
            if cb then
                cb()
            end
        end,
        onCancel = function()
            journalShardJob = nil
        end,
    })
end

local function ActivateRoleEra(self, role, era)
    if role == "journal" or role == "zones" then
        ActivateJournalEra(self, era)
        return
    end
    ns:EnsureLoaded(era.addon)
    local topics = ROLE_TOPICS[role]
    for topic in pairs(topics) do
        if self:IsTopicEnabled(era.addon, topic) then
            self:ActivateTopic(era.addon, topic)
        end
    end
    if role == "vendors" or role == "npcs" or role == "quests" or role == "archive" then
        if self:IsTopicEnabled(era.addon, "mappin") then
            self:ActivateTopic(era.addon, "mappin")
        end
    end
end

function CatalogData:CancelRoleShardJob(role)
    if role == "journal" or role == "zones" then
        self:CancelJournalShardJob()
        return
    end
    local job = roleShardJobs[role]
    if job then
        roleShardJobs[role] = nil
        roleShardOnUpdate[role] = nil
        job:Cancel()
    end
end

--- Load one wanted expansion's topics for this role. Suite IDs only; LE-keyed
--- tabs convert with LE_TO_SUITE.
---@param role string
---@param expansionID number
function CatalogData:EnsureRoleShards(role, expansionID)
    if role == "journal" or role == "zones" then
        self:EnsureJournalShards(expansionID)
        return
    end
    if not expansionID or expansionID == 0 or expansionID == -1 then
        return
    end
    if not ns:EnsureLoaded(RUNTIME_ADDON) then
        return
    end
    ScanInstalled()
    for i = 1, #eras do
        local era = eras[i]
        if era.expansionID == expansionID
            and ns:IsFeatureWanted(era.addon)
            and RoleNeedsEra(self, role, era)
        then
            ActivateRoleEra(self, role, era)
            FinishRoleRuntime(role)
            return
        end
    end
end

--- Load the selected expansion now. All (0 / -1) loads the player's expansion
--- first, then the rest across frames so opening NPCs / Quests / Item Search does
--- not hitch every pack.
---@param role string
---@param expansionID number suite expansion ID, or 0 / -1 for All
---@param onUpdate function|nil
function CatalogData:EnsureRoleShardsForFilter(role, expansionID, onUpdate)
    if role == "journal" or role == "zones" then
        self:EnsureJournalShardsForFilter(expansionID == -1 and 0 or expansionID, onUpdate)
        return
    end
    if not ns:EnsureLoaded(RUNTIME_ADDON) then
        return
    end
    ScanInstalled()
    if expansionID and expansionID ~= 0 and expansionID ~= -1 then
        self:CancelRoleShardJob(role)
        self:EnsureRoleShards(role, expansionID)
        return
    end
    local current = self:GetPlayerSuiteExpansionID()
    if current ~= 0 then
        self:EnsureRoleShards(role, current)
    end
    if onUpdate then
        roleShardOnUpdate[role] = onUpdate
    end
    if roleShardJobs[role] then
        return
    end
    local pending = {}
    local topics = ROLE_TOPICS[role]
    for i = 1, #eras do
        local era = eras[i]
        if era.expansionID ~= OTHER_EXPANSION_ID
            and era.expansionID ~= current
            and ns:IsFeatureWanted(era.addon)
            and RoleNeedsEra(self, role, era)
        then
            local needActivate = false
            for topic in pairs(topics) do
                if self:IsTopicEnabled(era.addon, topic) and not self:IsTopicActivated(era.addon, topic) then
                    needActivate = true
                    break
                end
            end
            if needActivate then
                tinsert(pending, era)
            end
        end
    end
    FinishRoleRuntime(role)
    if #pending == 0 then
        roleShardOnUpdate[role] = nil
        return
    end
    roleShardJobs[role] = ns.ChunkedJob.Start({
        budgetMs = 8,
        run = function(shouldYield)
            for i = 1, #pending do
                ActivateRoleEra(self, role, pending[i])
                ns.ChunkedJob.YieldIfNeeded(shouldYield)
            end
        end,
        onProgress = function()
            local cb = roleShardOnUpdate[role]
            if cb then
                cb()
            end
        end,
        onComplete = function()
            roleShardJobs[role] = nil
            local cb = roleShardOnUpdate[role]
            roleShardOnUpdate[role] = nil
            FinishRoleRuntime(role)
            if cb then
                cb()
            end
        end,
        onCancel = function()
            roleShardJobs[role] = nil
        end,
    })
end

--- Load zone + hubs for the player's place. With includeContents, also the
--- expansions of the places listed on that map (Zones "In this zone").
---@param includeContents boolean|nil
function CatalogData:EnsurePlayerJournalPlaces(includeContents)
    if not ns:EnsureLoaded(RUNTIME_ADDON) then
        return
    end
    local expansions = includeContents and self:GetPlayerPlaceExpansions(true) or PlayerHereExpansions(self)
    if #expansions == 0 then
        expansions[1] = self:GetCurrentSuiteExpansionID()
    end
    for i = 1, #expansions do
        self:EnsureJournalShards(expansions[i])
    end
end

function CatalogData:GetMapPinPacks()
    ScanInstalled()
    local out = {}
    for i = 1, #eras do
        local era = eras[i]
        if C_AddOns.IsAddOnLoaded(era.addon) and self:IsTopicEnabled(era.addon, "mappin") then
            self:ActivateTopic(era.addon, "mappin")
        end
        local pins = self.shippedPins[era.addon]
        if type(pins) == "table" then
            tinsert(out, {
                id = "catdb:" .. era.addon,
                name = era.title,
                expansion = SUITE_TO_LE[era.expansionID],
                pins = pins,
                shipped = true,
                addon = era.addon,
            })
        end
    end
    return out
end

CatalogData.shippedPins = CatalogData.shippedPins or {}
CatalogData.RUNTIME_ADDON = RUNTIME_ADDON
CatalogData.TRADESKILL_ADDON = TRADESKILL_ADDON
CatalogData.OTHER_ADDON = OTHER_ADDON
CatalogData.OTHER_EXPANSION_ID = OTHER_EXPANSION_ID
CatalogData.SUITE_TO_LE = SUITE_TO_LE
CatalogData.LE_TO_SUITE = LE_TO_SUITE
CatalogData.ARCHIVE_LE_MAX = ARCHIVE_LE_MAX
