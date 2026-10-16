local _, ns = ...

local tinsert = tinsert

-- ============================================================================
-- Catalog pack resolver (Catalog-side wrappers)
-- ============================================================================
-- Pack maps live on OneWoW (core) so QoL and other hubs can resolve without
-- this unit loaded. Catalog tabs keep calling ns.*. Always CatDB.
-- ============================================================================

--- Resolve a pack role or old/new addon name to the CatDB addon to load.
---@param roleOrName string
---@return string|nil addonName
function ns.ResolveCatalogPack(roleOrName)
    return OneWoW:ResolveCatalogPack(roleOrName)
end

--- Cross-unit API table for the resolved pack (`AddonName_API`).
---@param roleOrName string
---@return table|nil api
function ns.GetCatalogPackAPI(roleOrName)
    return OneWoW:GetCatalogPackAPI(roleOrName)
end

--- EnsureLoaded the resolved pack. Explicit user actions only.
---@param roleOrName string
---@return string|nil addonName
function ns.EnsureCatalogPack(roleOrName)
    return OneWoW:EnsureCatalogPack(roleOrName)
end

function ns.IsCatalogRoleReady(roleOrName)
    return OneWoW:IsCatalogRoleReady(roleOrName)
end

function ns.GetCatalogUnavailableNotice(roleOrRoles)
    return OneWoW:GetCatalogUnavailableNotice(roleOrRoles)
end

function ns.EnsureCatalogRoleShardsForFilter(role, expansionID, onUpdate)
    return OneWoW:EnsureCatalogRoleShardsForFilter(role, expansionID, onUpdate)
end

--- Shard filter for LE-keyed tabs (Vendors / Quests): -1 / nil is All (0),
--- otherwise the suite expansion for that LE ID.
---@param leID number|nil
---@return number suiteExpansionID
function ns.CatalogShardFilterFromLE(leID)
    if leID == nil or leID == -1 then
        return 0
    end
    return OneWoW.CatalogData.LE_TO_SUITE[leID]
end

--- LE expansion ID of the player's place (Vendors / Quests filter value).
---@return number|nil leID
function ns.GetPlayerLEExpansionID()
    return OneWoW.CatalogData.SUITE_TO_LE[OneWoW.CatalogData:GetPlayerSuiteExpansionID()]
end

function ns.GetWantedCatalogExpansions(role, useLeId)
    return OneWoW:GetWantedCatalogExpansions(role, useLeId)
end

--- Deduped list of addons Item Search watches for data-ready.
---@return string[]
function ns.GetCatalogItemSearchAddons()
    local seen = {}
    local out = {}
    local function add(name)
        if name and not seen[name] then
            seen[name] = true
            tinsert(out, name)
        end
    end
    add(OneWoW:ResolveCatalogPack("journal"))
    add(OneWoW:ResolveCatalogPack("vendors"))
    add(OneWoW:ResolveCatalogPack("tradeskills"))
    add(OneWoW:ResolveCatalogPack("quests"))
    add(OneWoW:ResolveCatalogPack("items"))
    add("OneWoW_AltTracker_Storage")
    return out
end
