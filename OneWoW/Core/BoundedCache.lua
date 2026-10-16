local _, ns = ...

-- ============================================================================
-- BoundedCache
-- ============================================================================
-- Two-generation soft-capped cache for session caches keyed by open-ended
-- input (hyperlinks, item identities, expression strings). Entries go into the
-- current generation; once it holds `cap` keys it becomes the old generation
-- and the previous old one is dropped. A hit in the old generation moves the
-- entry forward, so anything used since the last rotation survives it.
-- At most 2 * cap entries are held, with no per-access bookkeeping.
-- ============================================================================

local pairs, wipe = pairs, wipe
local setmetatable = setmetatable

local BoundedCache = {}
ns.BoundedCache = BoundedCache

local Cache = {}
Cache.__index = Cache

---@param cap number entries per generation
function BoundedCache.New(cap)
    return setmetatable({ cur = {}, old = {}, n = 0, cap = cap }, Cache)
end

function Cache:Set(key, value)
    local cur = self.cur
    if cur[key] == nil then
        if self.n >= self.cap then
            local old = self.old
            self.old = cur
            cur = wipe(old)
            self.cur = cur
            self.n = 0
        end
        self.n = self.n + 1
    end
    cur[key] = value
end

function Cache:Get(key)
    local value = self.cur[key]
    if value ~= nil then return value end
    value = self.old[key]
    if value ~= nil then
        self.old[key] = nil
        self:Set(key, value)
    end
    return value
end

function Cache:Remove(key)
    self.cur[key] = nil
    self.old[key] = nil
end

local function RemoveFrom(gen, predicate)
    for key, value in pairs(gen) do
        if predicate(key, value) then
            gen[key] = nil
        end
    end
end

--- Remove every entry for which `predicate(key, value)` is true.
---@param predicate fun(key: any, value: any): boolean
function Cache:RemoveWhere(predicate)
    RemoveFrom(self.cur, predicate)
    RemoveFrom(self.old, predicate)
end

function Cache:Wipe()
    wipe(self.cur)
    wipe(self.old)
    self.n = 0
end
