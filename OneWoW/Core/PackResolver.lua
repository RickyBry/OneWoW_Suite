local _, ns = ...

-- ============================================================================
-- Catalog pack resolver
-- ============================================================================
-- Consumers pass a role (journal, vendors, quests, tradeskills, items) or a
-- CatDB folder name. Era shards live in OneWoW_CatDB_<Era>; query APIs live
-- on OneWoW_Catalog. Tradeskills stay OneWoW_CatDB_TradeSkillDB.
-- This lives on core so QoL / Notes / ShoppingList / toasts can resolve
-- without opening Catalog tabs.
--
-- Roles: journal/zones, vendors/npcs, quests, archive, tradeskills, items.
-- ============================================================================

--- Resolve a pack role or CatDB addon name to the addon EnsureLoaded should
--- treat as the provider (runtime for journal/vendors/quests/items).
---@param roleOrName string
---@return string|nil addonName
function ns:ResolveCatalogPack(roleOrName)
    if not roleOrName then
        return nil
    end
    return ns.CatalogData:ResolveRoleAddon(roleOrName) or roleOrName
end

--- Cross-unit API table for the resolved pack role.
---@param roleOrName string
---@return table|nil api
function ns:GetCatalogPackAPI(roleOrName)
    if not roleOrName then
        return nil
    end
    local api = ns.CatalogData:GetRoleAPI(roleOrName)
    if api then
        return api
    end
    local addon = self:ResolveCatalogPack(roleOrName)
    if not addon then
        return nil
    end
    return _G[addon .. "_API"]
end

--- Load runtime + enabled era topics for this role. Explicit user actions only.
---@param roleOrName string
---@return string|nil addonName
function ns:EnsureCatalogPack(roleOrName)
    if not roleOrName then
        return nil
    end
    return ns.CatalogData:EnsureRole(roleOrName)
end

--- Load Journal places for the player's place; with includeContents, also the
--- expansions of the places listed on that map.
---@param includeContents boolean|nil
function ns:EnsurePlayerJournalPlaces(includeContents)
    ns.CatalogData:EnsurePlayerJournalPlaces(includeContents)
end

--- Load Journal hubs + zone for one suite expansion (no-op for All / 0).
---@param expansionID number
function ns:EnsureJournalShards(expansionID)
    ns.CatalogData:EnsureJournalShards(expansionID)
end

--- Load the Zones expansion filter: one pack now, or this expansion plus the rest across frames.
---@param expansionID number
---@param onUpdate function|nil
function ns:EnsureJournalShardsForFilter(expansionID, onUpdate)
    ns.CatalogData:EnsureJournalShardsForFilter(expansionID, onUpdate)
end

--- Load one role's expansion shards. All (0 / -1) loads the player's expansion first, then the rest.
---@param role string
---@param expansionID number suite expansion ID (1-12, 99 Other), or 0 / -1 for All
---@param onUpdate function|nil
function ns:EnsureCatalogRoleShardsForFilter(role, expansionID, onUpdate)
    ns.CatalogData:EnsureRoleShardsForFilter(role, expansionID, onUpdate)
end

--- Wanted expansions for a Catalog role dropdown (before those shards load).
---@param role string
---@param useLeId boolean|nil
---@return table
function ns:GetWantedCatalogExpansions(role, useLeId)
    return ns.CatalogData:GetWantedRoleExpansions(role, useLeId)
end

--- True when the Journal place shards for the player's place are loaded and activated.
function ns:ArePlayerJournalPlacesLoaded()
    return ns.CatalogData:ArePlayerJournalPlacesLoaded()
end

--- True if the resolved CatDB provider exists and is enabled.
---@param roleOrName string
---@return boolean
function ns:IsCatalogPackAvailable(roleOrName)
    if not roleOrName then
        return false
    end
    return ns.CatalogData:IsRoleAvailable(roleOrName)
end

--- True when this role can query loaded expansion data (not merely that the API table exists).
---@param roleOrName string
---@return boolean
function ns:IsCatalogRoleReady(roleOrName)
    if not roleOrName then
        return false
    end
    return ns.CatalogData:IsRoleQueryReady(roleOrName)
end

--- True when every wanted expansion for this role is loaded.
---@param roleOrName string
---@return boolean
function ns:IsCatalogRoleFullyLoaded(roleOrName)
    if not roleOrName then
        return false
    end
    return ns.CatalogData:IsRoleFullyLoaded(roleOrName)
end

--- Catalog-off vs data-not-loaded-this-session. Nil when a requested role can query.
---@param roleOrRoles string|string[]
---@return string|nil
function ns:GetCatalogUnavailableNotice(roleOrRoles)
    return ns.CatalogData:GetUnavailableNotice(roleOrRoles)
end
