local _, ns = ...

-- ============================================================================
-- QuestDB loader
-- ============================================================================
-- Emit agents call ns:RegisterQuestData{ [questID] = { ... } } from Data/ shards.
--   ns.ExternalQuestDB              [questID] = quest record
--   ns.ExternalQuestDBByExpansion   [expansionID][questID] = quest record
--   ns.QuestsByNPC                  [npcID] = { quest, ... }
--   ns.QuestsByRewardItem           [itemID] = { questID, ... }
-- ============================================================================

local pairs = pairs
local tinsert, tremove = tinsert, tremove

ns.ExternalQuestDB = ns.ExternalQuestDB or {}
ns.ExternalQuestDBByExpansion = ns.ExternalQuestDBByExpansion or {}
ns.QuestsByNPC = ns.QuestsByNPC or {}
ns.QuestsByRewardItem = ns.QuestsByRewardItem or {}

local db = ns.ExternalQuestDB
local byExpansion = ns.ExternalQuestDBByExpansion
local byNPC = ns.QuestsByNPC
local byReward = ns.QuestsByRewardItem

-- A quest is indexed once per NPC even when that NPC both starts and ends it.
local function IndexNPC(npcID, quest)
    if type(npcID) ~= "number" then return end
    local list = byNPC[npcID]
    if not list then
        list = {}
        byNPC[npcID] = list
    end
    for i = 1, #list do
        if list[i] == quest then
            return
        end
    end
    tinsert(list, quest)
end

local function UnindexNPC(npcID, quest)
    local list = type(npcID) == "number" and byNPC[npcID]
    if not list then return end
    for i = #list, 1, -1 do
        if list[i] == quest then
            tremove(list, i)
        end
    end
end

local function ForEachRefNPC(refs, fn, quest)
    if not refs then return end
    for _, ref in pairs(refs) do
        if type(ref) == "table" then
            fn(ref.npcID, quest)
        elseif type(ref) == "number" then
            fn(ref, quest)
        end
    end
end

---@param quest table
---@param fn fun(npcID: number|nil, quest: table)
local function ForEachQuestNPC(quest, fn)
    ForEachRefNPC(quest.starts, fn, quest)
    ForEachRefNPC(quest.ends, fn, quest)
end

local function RewardItemID(entry)
    if type(entry) == "number" then
        return entry
    end
    if type(entry) == "table" then
        return entry.itemID or entry.id
    end
    return nil
end

local function IndexRewardItem(itemID, questID)
    itemID = tonumber(itemID)
    if not itemID then
        return
    end
    local list = byReward[itemID]
    if not list then
        list = {}
        byReward[itemID] = list
    end
    for i = 1, #list do
        if list[i] == questID then
            return
        end
    end
    tinsert(list, questID)
end

local function IndexRewardList(list, questID)
    if type(list) ~= "table" then
        return
    end
    for _, entry in pairs(list) do
        IndexRewardItem(RewardItemID(entry), questID)
    end
end

--- Fill QuestsByRewardItem from a quest row. Safe to call again; IDs dedupe.
---@param questID number
---@param questData table
function ns:IndexQuestRewards(questID, questData)
    if type(questID) ~= "number" or type(questData) ~= "table" then
        return
    end
    IndexRewardList(questData.rewardItems, questID)
    IndexRewardList(questData.rewardChoices, questID)
    IndexRewardList(questData.packageItems, questID)
end

--- Merge quest rows keyed by questID.
---@param source table<number, table>
function ns:RegisterQuestData(source)
    if type(source) ~= "table" then return end

    for questID, questData in pairs(source) do
        if type(questID) == "number" and type(questData) == "table" then
            -- A later shard replacing this quest must not leave the old row
            -- behind in the NPC / expansion indexes.
            local old = db[questID]
            if old and old ~= questData then
                ForEachQuestNPC(old, UnindexNPC)
                local oldExpansion = byExpansion[old.expansion]
                if oldExpansion and oldExpansion[questID] == old then
                    oldExpansion[questID] = nil
                end
            end
            db[questID] = questData

            local expansionID = questData.expansion
            if type(expansionID) == "number" then
                byExpansion[expansionID] = byExpansion[expansionID] or {}
                byExpansion[expansionID][questID] = questData
            end

            ForEachQuestNPC(questData, IndexNPC)

            self:IndexQuestRewards(questID, questData)
        end
    end
end
