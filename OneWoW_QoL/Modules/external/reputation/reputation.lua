local _, ns = ...
local Reputation, L = ns.ModuleRegistry:Current()
if not Reputation then return end

local OneWoW_GUI = OneWoW_GUI

-- ============================================================================
-- Reputation Tracker
-- ============================================================================
-- Three live behaviors, all gated by this module's toggles:
--   Chat: append session total and reputation left onto the faction gain line.
--   Bar: optionally watch the faction that just gained reputation.
--   Tooltip: list other characters' saved standing for the hovered faction.
--
-- Progress is snapshotted from C_Reputation. The first pass only records a
-- baseline, so logging in does not print a gain. Session totals live in
-- memory and reset on reload.
-- Collapsed headers hide child factions from GetNumFactions. While the
-- reputation panel is closed, the scan expands headers and restores the
-- previous open set so those gains are still seen.
-- ============================================================================

local pairs, wipe, sort = pairs, wipe, sort
local format = format
local floor, abs = math.floor, math.abs
local C_Reputation = C_Reputation
local C_MajorFactions = C_MajorFactions
local C_GossipInfo = C_GossipInfo
local C_Timer = C_Timer
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame
local ChatFrame_AddMessageEventFilter = ChatFrame_AddMessageEventFilter
local ChatFrame_RemoveMessageEventFilter = ChatFrame_RemoveMessageEventFilter
local BreakUpLargeNumbers = BreakUpLargeNumbers
local UnitSex = UnitSex

local MODULE_ID = Reputation.id

local function Toggle(toggleId)
    return ns.ModuleRegistry:GetToggleValue(MODULE_ID, toggleId)
end

local function Enabled()
    return ns.ModuleRegistry:IsEnabled(MODULE_ID)
end

local function PanelShown()
    return ReputationFrame and ReputationFrame:IsShown()
end

local function HeaderToken(data)
    if data.factionID and data.factionID > 0 then
        return data.factionID
    end
    return data.name
end

local function StandingLabel(reaction)
    if not reaction or reaction < 1 then return nil end
    local key = "FACTION_STANDING_LABEL" .. reaction
    if UnitSex("player") == 3 then
        local female = _G[key .. "_FEMALE"]
        if type(female) == "string" and female ~= "" then
            return female
        end
    end
    local label = _G[key]
    if type(label) == "string" and label ~= "" then
        return label
    end
    return nil
end

local function Signed(amount)
    local text = BreakUpLargeNumbers(floor(abs(amount)))
    if amount > 0 then
        return "+" .. text
    end
    if amount < 0 then
        return "-" .. text
    end
    return text
end

local function CopyProgress(data)
    local factionID = data.factionID
    local value = data.currentStanding or 0
    local kind = "standing"
    if C_Reputation.IsFactionParagon(factionID) then
        local current = C_Reputation.GetFactionParagonInfo(factionID)
        if current then
            value = current
            kind = "paragon"
        end
    elseif C_Reputation.IsMajorFaction(factionID) then
        local major = C_MajorFactions.GetMajorFactionData(factionID)
        if major and major.renownLevelThreshold and major.renownLevelThreshold > 0 then
            value = major.renownLevel * major.renownLevelThreshold + major.renownReputationEarned
            kind = "renown"
        end
    end
    return {
        name = data.name,
        value = value,
        kind = kind,
        reaction = data.reaction,
        currentStanding = data.currentStanding,
        currentReactionThreshold = data.currentReactionThreshold,
        nextReactionThreshold = data.nextReactionThreshold,
        isAccountWide = data.isAccountWide,
        isWatched = data.isWatched,
    }
end

local function EachVisibleFaction(fn)
    local num = C_Reputation.GetNumFactions()
    for i = 1, num do
        local data = C_Reputation.GetFactionDataByIndex(i)
        if data and data.factionID and data.factionID > 0 and (not data.isHeader or data.isHeaderWithRep) then
            fn(data, i)
        end
    end
end

-- Restore headers that were open before a temporary ExpandAll. Walk until
-- every remembered header is open; expanding shifts later indexes.
local function RestoreExpandedHeaders(open)
    C_Reputation.CollapseAllFactionHeaders()
    for _ = 1, 30 do
        local expandedOne = false
        local num = C_Reputation.GetNumFactions()
        for i = 1, num do
            local data = C_Reputation.GetFactionDataByIndex(i)
            if data and data.isHeader and data.isCollapsed and open[HeaderToken(data)] then
                C_Reputation.ExpandFactionHeader(i)
                expandedOne = true
                break
            end
        end
        if not expandedOne then
            return
        end
    end
end

function Reputation:ReadFactions(fn)
    if PanelShown() then
        EachVisibleFaction(fn)
        return
    end
    local open = {}
    local num = C_Reputation.GetNumFactions()
    for i = 1, num do
        local data = C_Reputation.GetFactionDataByIndex(i)
        if data and data.isHeader and not data.isCollapsed then
            open[HeaderToken(data)] = true
        end
    end
    C_Reputation.ExpandAllFactionHeaders()
    EachVisibleFaction(fn)
    RestoreExpandedHeaders(open)
end

function Reputation:IsGuild(factionID)
    local guild = C_Reputation.GetGuildFactionData()
    return guild and guild.factionID == factionID
end

function Reputation:Remaining(factionID, info)
    if info.kind == "paragon" then
        local current, threshold = C_Reputation.GetFactionParagonInfo(factionID)
        if current and threshold and threshold > 0 then
            local into = current % threshold
            -- A full bar (reward waiting) has nothing left until it is collected.
            -- A fresh paragon value of 0 still has the whole threshold to go.
            if current > 0 and into == 0 then
                return 0, nil, false
            end
            return threshold - into, nil, false
        end
    end
    if C_Reputation.IsMajorFaction(factionID) then
        local major = C_MajorFactions.GetMajorFactionData(factionID)
        if major then
            if C_MajorFactions.HasMaximumRenown(factionID) then
                return 0, nil, true
            end
            local left = major.renownLevelThreshold - major.renownReputationEarned
            if left < 0 then left = 0 end
            return left, RENOWN_LEVEL_LABEL:format(major.renownLevel + 1), false
        end
    end
    local friend = C_GossipInfo.GetFriendshipReputation(factionID)
    if friend and friend.friendshipFactionID and friend.friendshipFactionID > 0 and friend.maxRep and friend.maxRep > 0 then
        if not friend.nextThreshold then
            return 0, nil, true
        end
        local left = friend.nextThreshold - friend.standing
        if left < 0 then left = 0 end
        return left, nil, false
    end
    if info.reaction and info.reaction >= 8 then
        return 0, nil, true
    end
    local left = (info.nextReactionThreshold or 0) - (info.currentStanding or 0)
    if left < 0 then left = 0 end
    return left, StandingLabel((info.reaction or 0) + 1), false
end

function Reputation:Suffix(factionID)
    local info = self._snapshot[factionID]
    if not info then return "" end
    local session = self._session[factionID] or 0
    local left, nextLabel, capped = self:Remaining(factionID, info)
    local parts = { L["REP_CHAT_SESSION"]:format(Signed(session)) }
    if capped then
        parts[#parts + 1] = CAPPED
    elseif nextLabel then
        parts[#parts + 1] = L["REP_CHAT_LEFT"]:format(nextLabel, BreakUpLargeNumbers(floor(left)))
    else
        parts[#parts + 1] = L["REP_CHAT_LEFT_PLAIN"]:format(BreakUpLargeNumbers(floor(left)))
    end
    return " (" .. table.concat(parts, ", ") .. ")"
end

function Reputation:PrintLine(text)
    local info = ChatTypeInfo["COMBAT_FACTION_CHANGE"]
    DEFAULT_CHAT_FRAME:AddMessage(text, info.r, info.g, info.b)
end

function Reputation:FormatBase(info, delta)
    local amount = floor(abs(delta))
    if delta >= 0 then
        if info.isAccountWide then
            return FACTION_STANDING_INCREASED_ACCOUNT_WIDE:format(info.name, amount)
        end
        return FACTION_STANDING_INCREASED:format(info.name, amount)
    end
    if info.isAccountWide then
        return FACTION_STANDING_DECREASED_ACCOUNT_WIDE:format(info.name, amount)
    end
    return FACTION_STANDING_DECREASED:format(info.name, amount)
end

function Reputation:MaybeSwitch(factionID, info)
    if not Toggle("switchBar") then return end
    if info.isWatched then return end
    if self:IsGuild(factionID) and Toggle("skipGuildSwitch") then return end
    C_Reputation.SetWatchedFactionByID(factionID)
    if not Toggle("silentSwitch") then
        self:PrintLine(L["REP_CHAT_SWITCH"]:format(info.name))
    end
end

function Reputation:Seed()
    self._snapshot = self._snapshot or {}
    self._session = self._session or {}
    self._pending = self._pending or {}
    self._announced = self._announced or {}
    self._inDiff = true
    self:ReadFactions(function(data, index)
        local info = CopyProgress(data)
        info.active = C_Reputation.IsFactionActive(index)
        self._snapshot[data.factionID] = info
    end)
    self._inDiff = false
    wipe(self._pending)
end

function Reputation:Diff()
    if self._inDiff then return end
    self._inDiff = true
    self._snapshot = self._snapshot or {}
    self._session = self._session or {}
    self._pending = self._pending or {}
    self:ReadFactions(function(data, index)
        local factionID = data.factionID
        local info = CopyProgress(data)
        info.active = C_Reputation.IsFactionActive(index)
        local prev = self._snapshot[factionID]
        self._snapshot[factionID] = info
        if prev and prev.value ~= info.value then
            local delta = info.value - prev.value
            self._session[factionID] = (self._session[factionID] or 0) + delta
            self._pending[factionID] = {
                factionID = factionID,
                delta = delta,
                active = info.active,
            }
            if delta > 0 then
                self:MaybeSwitch(factionID, info)
            end
        end
    end)
    self._inDiff = false
    self:ScheduleFlush()
end

function Reputation:ScheduleFlush()
    if self._flushScheduled then return end
    if not self._pending or not next(self._pending) then return end
    self._flushScheduled = true
    C_Timer.After(0, function()
        self._flushScheduled = false
        self:Flush()
    end)
end

function Reputation:Flush()
    if not Enabled() or not Toggle("detailedChat") or not Toggle("showHidden") then
        wipe(self._pending)
        wipe(self._announced)
        return
    end
    for factionID, change in pairs(self._pending) do
        if not self._announced[factionID] and not change.active then
            if not (self:IsGuild(factionID) and Toggle("skipGuildChat")) then
                local info = self._snapshot[factionID]
                if info then
                    self:PrintLine(self:FormatBase(info, change.delta) .. self:Suffix(factionID))
                end
            end
        end
    end
    wipe(self._pending)
    wipe(self._announced)
end

function Reputation:MatchName(msg)
    local bestID, bestLen
    for factionID, info in pairs(self._snapshot) do
        local name = info.name
        if type(name) == "string" and name ~= "" and msg:find(name, 1, true) then
            local len = #name
            if not bestLen or len > bestLen then
                bestID = factionID
                bestLen = len
            end
        end
    end
    return bestID
end

function Reputation:OnChat(msg, ...)
    if not Enabled() or not Toggle("detailedChat") then return end
    if type(msg) ~= "string" then return end
    self:Diff()
    local factionID = self:MatchName(msg)
    if not factionID then return end
    self._announced[factionID] = true
    if self:IsGuild(factionID) and Toggle("skipGuildChat") then
        return true
    end
    return false, msg .. self:Suffix(factionID), ...
end

local function DescribeStored(faction)
    if faction.isParagon and faction.paragonThreshold and faction.paragonThreshold > 0 then
        local into = (faction.paragonValue or 0) % faction.paragonThreshold
        return L["REP_ALT_LINE"]:format(L["REP_ALT_PARAGON"], BreakUpLargeNumbers(into), BreakUpLargeNumbers(faction.paragonThreshold))
    end
    local label = StandingLabel(faction.reaction) or ""
    local span = (faction.nextReactionThreshold or 0) - (faction.currentReactionThreshold or 0)
    if span > 0 then
        local cur = (faction.currentStanding or 0) - (faction.currentReactionThreshold or 0)
        if cur < 0 then cur = 0 end
        if label == "" then
            return BreakUpLargeNumbers(cur) .. " / " .. BreakUpLargeNumbers(span)
        end
        return L["REP_ALT_LINE"]:format(label, BreakUpLargeNumbers(cur), BreakUpLargeNumbers(span))
    end
    return label
end

function Reputation:CollectAlts(factionID)
    local api = OneWoW_AltTracker_Collections_API
    if not api or not api.GetAllCharacters then return nil end
    local mine = OneWoW_GUI:GetCharacterKey()
    local rows = {}
    for charKey, charData in pairs(api.GetAllCharacters()) do
        if charKey ~= mine and type(charData) == "table" and type(charData.reputations) == "table" then
            local factions = charData.reputations.factions
            if factions then
                for i = 1, #factions do
                    local faction = factions[i]
                    if faction.factionID == factionID and (not faction.isHeader or faction.isHeaderWithRep) then
                        rows[#rows + 1] = { key = charKey, faction = faction }
                        break
                    end
                end
            end
        end
    end
    if #rows == 0 then return nil end
    sort(rows, function(a, b)
        local ar, br = a.faction.reaction or 0, b.faction.reaction or 0
        if ar ~= br then return ar > br end
        return (a.faction.currentStanding or 0) > (b.faction.currentStanding or 0)
    end)
    return rows
end

function Reputation:AppendAlts(tooltip, factionID)
    if tooltip._onewowRepShown == factionID then return end
    local rows = self:CollectAlts(factionID)
    if not rows then return end
    local nameColor = NORMAL_FONT_COLOR
    tooltip:AddLine(" ")
    tooltip:AddLine(L["REP_ALT_HEADER"], nameColor.r, nameColor.g, nameColor.b)
    for i = 1, #rows do
        local row = rows[i]
        local standingColor = FACTION_BAR_COLORS[row.faction.reaction or 0] or nameColor
        tooltip:AddDoubleLine(
            row.key,
            DescribeStored(row.faction),
            nameColor.r, nameColor.g, nameColor.b,
            standingColor.r, standingColor.g, standingColor.b
        )
    end
    tooltip._onewowRepShown = factionID
end

function Reputation:HideAltTip()
    if GameTooltip then GameTooltip._onewowRepShown = nil end
    if EmbeddedItemTooltip then EmbeddedItemTooltip._onewowRepShown = nil end
    if self._altTip then self._altTip:Hide() end
end

function Reputation:ShowDockedAlts(anchor, factionID)
    local rows = self:CollectAlts(factionID)
    if not rows then return end
    local tip = self._altTip
    if not tip then
        tip = CreateFrame("GameTooltip", "OneWoW_QoL_ReputationAltTooltip", UIParent, "GameTooltipTemplate")
        tip:SetFrameStrata("TOOLTIP")
        tip:SetClampedToScreen(true)
        self._altTip = tip
    end
    tip:Hide()
    tip:ClearLines()
    tip:SetOwner(UIParent, "ANCHOR_NONE")
    tip:ClearAllPoints()
    tip:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -6)
    tip._onewowRepShown = nil
    self:AppendAlts(tip, factionID)
    tip:Show()
end

local function FactionIDFromRow(row)
    if type(row.factionID) == "number" and row.factionID > 0 then
        return row.factionID
    end
    if row.GetElementData then
        local data = row:GetElementData()
        if type(data) == "table" then
            if type(data.factionID) == "number" and data.factionID > 0 then
                return data.factionID
            end
            if type(data.index) == "number" then
                local faction = C_Reputation.GetFactionDataByIndex(data.index)
                if faction and faction.factionID and faction.factionID > 0 then
                    return faction.factionID
                end
            end
        end
    end
    if type(row.factionIndex) == "number" then
        local faction = C_Reputation.GetFactionDataByIndex(row.factionIndex)
        if faction and faction.factionID and faction.factionID > 0 then
            return faction.factionID
        end
    end
end

function Reputation:OnRowEnter(row)
    if not Enabled() or not Toggle("altTooltip") then return end
    local factionID = FactionIDFromRow(row)
    if not factionID then return end
    if EmbeddedItemTooltip and EmbeddedItemTooltip:IsShown() and EmbeddedItemTooltip:GetOwner() == row then
        self:ShowDockedAlts(EmbeddedItemTooltip, factionID)
        return
    end
    if GameTooltip:IsShown() then
        self:AppendAlts(GameTooltip, factionID)
        GameTooltip:Show()
    end
end

function Reputation:OnBarEnter(bar)
    if not Enabled() or not Toggle("altTooltip") then return end
    local watched = C_Reputation.GetWatchedFactionData()
    if not watched or not watched.factionID or watched.factionID == 0 then return end
    local owner = GameTooltip:GetOwner()
    if GameTooltip:IsShown() and (owner == bar or owner == bar:GetParent()) then
        self:AppendAlts(GameTooltip, watched.factionID)
        GameTooltip:Show()
        return
    end
    if not self:CollectAlts(watched.factionID) then return end
    GameTooltip:SetOwner(bar, "ANCHOR_RIGHT")
    GameTooltip:SetText(watched.name or "")
    self:AppendAlts(GameTooltip, watched.factionID)
    GameTooltip:Show()
end

function Reputation:HookMixin(mixin, flag)
    if self[flag] or not mixin or not mixin.OnEnter then return end
    hooksecurefunc(mixin, "OnEnter", function(row)
        if mixin == ReputationStatusBarMixin then
            Reputation:OnBarEnter(row)
        else
            Reputation:OnRowEnter(row)
        end
    end)
    if mixin.OnLeave then
        hooksecurefunc(mixin, "OnLeave", function()
            Reputation:HideAltTip()
        end)
    end
    self[flag] = true
end

function Reputation:HookUI()
    self:HookMixin(ReputationEntryMixin, "_hookedEntry")
    self:HookMixin(ReputationSubHeaderMixin, "_hookedSub")
    self:HookMixin(ReputationStatusBarMixin, "_hookedBar")
end

function Reputation:OnEnable()
    self._snapshot = self._snapshot or {}
    self._session = self._session or {}
    self._pending = self._pending or {}
    self._announced = self._announced or {}
    if not self._frame then
        self._frame = CreateFrame("Frame")
        self._frame:SetScript("OnEvent", function(_, event)
            if not Enabled() then return end
            if event == "UPDATE_FACTION" or event == "MAJOR_FACTION_RENOWN_LEVEL_CHANGED" then
                Reputation:Diff()
            end
        end)
    end
    if not self._filter then
        self._filter = function(_, _, msg, ...)
            return Reputation:OnChat(msg, ...)
        end
    end
    self._frame:RegisterEvent("UPDATE_FACTION")
    self._frame:RegisterEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED")
    if not self._filterOn then
        ChatFrame_AddMessageEventFilter("CHAT_MSG_COMBAT_FACTION_CHANGE", self._filter)
        self._filterOn = true
    end
    self:HookUI()
    if not self._uiWatch then
        self._uiWatch = true
        OneWoW:RegisterAddonLoadedWatcher("Blizzard_UIPanels_Game", function()
            Reputation:HookUI()
        end)
    end
    self:Seed()
end

function Reputation:OnDisable()
    if self._frame then
        self._frame:UnregisterAllEvents()
    end
    if self._filterOn and self._filter then
        ChatFrame_RemoveMessageEventFilter("CHAT_MSG_COMBAT_FACTION_CHANGE", self._filter)
        self._filterOn = false
    end
    self:HideAltTip()
end
