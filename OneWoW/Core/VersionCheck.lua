local ADDON_NAME, ns = ...

local OneWoW_GUI = OneWoW_GUI

-- ============================================================================
-- VersionCheck
-- ============================================================================
-- Peer TOC-version exchange for the core load unit only. Other OneWoW clients
-- announce on hidden addon chat; a strictly newer R#.#.# trips chat, a popup,
-- and a Home attention row. There is no HTTP / CurseForge probe.
--
-- Protocol (prefix ONEWOW_VER):
--   V\t<tocVersion>  announce
--
-- Cadence: one session announce shortly after the first loading screen
-- (group, GUILD, YELL, Battle.net Retail friends staggered); GUILD again on
-- joining a guild; group again only when the roster grows. No SAY / CHANNEL.
-- Sends that hit AddOnMessageLockdown are kept per channel / BN account and
-- resent once when the Chat restriction lifts (capped timer fallback).
--
-- A newer version is saved (Home row, popup) only after two distinct peers
-- report it; one peer gets the chat line. Implausible versions are ignored.
--
-- Nearby report (REPORT_NEARBY below) is a code-only switch. It ships false
-- so players never see it. Set true to print a chat line when another OneWoW
-- is heard on group / raid / instance / guild / yell / Battle.net.
-- ============================================================================

local C_BattleNet = C_BattleNet
local C_ChatInfo = C_ChatInfo
local C_DateAndTime = C_DateAndTime
local C_Timer = C_Timer
local format = string.format
local gsub = string.gsub
local ipairs = ipairs
local pairs = pairs
local sort = sort
local strmatch = string.match
local strsplit = strsplit
local wipe = wipe

-- Dev-only: set true to print nearby OneWoW users in chat. Ships false.
local REPORT_NEARBY = false

local PREFIX = "ONEWOW_VER"
local DOWNLOAD_URL = "https://onewow.net/"
local ANNOUNCE_DELAY = 10
local LOCKDOWN_RETRY = 5
local MAX_TIMER_RETRIES = 3
local BN_STAGGER = 0.75
local LOGIN_POPUP_DELAY = 5
local PEERS_TO_SAVE = 2

local LOCKDOWN = Enum.SendAddonMessageResult.AddOnMessageLockdown
local CHAT_RESTRICTION = Enum.AddOnRestrictionType.Chat
local RESTRICTION_INACTIVE = Enum.AddOnRestrictionState.Inactive

local VersionCheck = {}
ns.VersionCheck = VersionCheck

local announcePending = false
local sessionAnnounced = false
local guildAnnounced = false
local chatPrinted = false
local popupShownFor = nil
local groupSize = 0
local activeDialog = nil
-- Sends that hit lockdown: [channel] = true ("GROUP" / "GUILD" / "YELL"),
-- and [gameAccountID] = true for Battle.net.
local pendingChat = {}
local pendingBN = {}
local retryTimer = nil
local timerRetries = 0
-- [peerKey] = highest plausible newer version that peer reported.
local peerBest = {}
-- [kind] = { [id] = true } unique peers heard this session (REPORT_NEARBY).
local nearbySeen = {}

local NEARBY_LABEL = {
    PARTY = "group",
    RAID = "raid",
    INSTANCE_CHAT = "instance",
    GUILD = "guild",
    YELL = "yell range",
    WHISPER = "whisper",
    BN = "Battle.net",
}

--- Parse shipped core TOC versions (`R6.2608.2805`). Unparseable strings
--- (Unknown, Git, hashes) return nil so they never count as newer.
---@param version string|nil
---@return number|nil major
---@return number|nil yymm
---@return number|nil patch
local function ParseVersion(version)
    if type(version) ~= "string" then return nil end
    local major, yymm, patch = strmatch(version, "^R(%d+)%.(%d+)%.(%d+)")
    if not major then return nil end
    return tonumber(major), tonumber(yymm), tonumber(patch)
end

--- True when `remote` is a parseable TOC string strictly greater than `localVer`.
---@param remote string|nil
---@param localVer string|nil
---@return boolean
function VersionCheck.IsNewer(remote, localVer)
    local r1, r2, r3 = ParseVersion(remote)
    local l1, l2, l3 = ParseVersion(localVer)
    if not r1 or not l1 then return false end
    if r1 ~= l1 then return r1 > l1 end
    if r2 ~= l2 then return r2 > l2 end
    return r3 > l3
end

--- False for a version no real build could carry yet: a year-month more than
--- one month past today, or a major more than one past ours.
---@param remote string
---@param localVer string
---@return boolean
local function IsPlausible(remote, localVer)
    local r1, r2 = ParseVersion(remote)
    local l1 = ParseVersion(localVer)
    if r1 > l1 + 1 then return false end
    local now = C_DateAndTime.GetCurrentCalendarTime()
    local year, month = now.year % 100, now.month + 1
    if month > 12 then
        year, month = (year + 1) % 100, 1
    end
    return r2 <= year * 100 + month
end

---@return string|nil version nil when missing or unparseable
local function LocalVersion()
    local ver = ns:GetAddonVersion(ADDON_NAME)
    if not ver or not ParseVersion(ver) then return nil end
    return ver
end

local function PruneIfUpdated()
    local localVer = LocalVersion()
    local seen = ns.db.global.remoteUpdateLatestSeen
    if seen == "" or not localVer then return end
    if not VersionCheck.IsNewer(seen, localVer) then
        ns.db.global.remoteUpdateLatestSeen = ""
        ns.db.global.remoteUpdatePopupDismissedVersion = ""
    end
end

---@return boolean
local function WizardPending()
    return ns.FirstRun:ShouldShowWizard()
end

---@param remote string
local function ApplyPopupDismiss(checkbox, remote)
    if not checkbox or remote == "" then return end
    if checkbox:GetChecked() then
        ns.db.global.remoteUpdatePopupDismissedVersion = remote
    elseif ns.db.global.remoteUpdatePopupDismissedVersion == remote then
        ns.db.global.remoteUpdatePopupDismissedVersion = ""
    end
end

---@param remote string
local function ShowPopup(remote)
    if activeDialog and activeDialog.frame and activeDialog.frame:IsShown() then
        return
    end

    local L = ns.L
    local localVer = LocalVersion() or ""
    local result
    local preferenceApplied = false
    local function FinishDialog()
        if preferenceApplied then return end
        preferenceApplied = true
        ApplyPopupDismiss(result and result.checkbox, remote)
        activeDialog = nil
    end

    result = OneWoW_GUI:CreateConfirmDialog({
        name = "OneWoW_VersionCheck",
        addonTitle = "OneWoW",
        title = L["VERSION_CHECK_POPUP_TITLE"],
        message = format(L["VERSION_CHECK_POPUP_BODY"], localVer, remote),
        width = 480,
        showBrand = true,
        checkbox = {
            label = L["VERSION_CHECK_DONT_SHOW"],
            wrap = true,
        },
        buttons = {
            {
                text = CLOSE,
                color = { 0.2, 0.6, 0.2 },
                onClick = function(dialog)
                    FinishDialog()
                    dialog:Hide()
                end,
            },
        },
        onClose = function()
            FinishDialog()
        end,
    })

    if result and result.checkbox then
        result.checkbox:SetChecked(ns.db.global.remoteUpdatePopupDismissedVersion == remote)
    end

    if result and result.frame then
        local downloadBtn = OneWoW_GUI:CreateFitTextButton(result.frame, {
            text = L["VERSION_CHECK_DOWNLOAD_BTN"],
            height = 28,
            minWidth = 80,
        })
        downloadBtn:SetPoint("BOTTOMLEFT", result.frame, "BOTTOMLEFT", 10, 10)
        downloadBtn:SetScript("OnClick", function()
            OneWoW_GUI:ShowCopyURLDialog(L["VERSION_CHECK_DOWNLOAD_BTN"], DOWNLOAD_URL)
        end)

        result.frame:HookScript("OnHide", function()
            FinishDialog()
        end)
    end

    activeDialog = result
    if result and result.frame then
        result.frame:Show()
        result.frame:Raise()
    end
end

---@param remote string
---@param delay number|nil
local function TryPopup(remote, delay)
    if popupShownFor == remote then return end
    if ns.db.global.remoteUpdatePopupDismissedVersion == remote then return end
    if WizardPending() then return end

    local function open()
        if popupShownFor == remote then return end
        if ns.db.global.remoteUpdatePopupDismissedVersion == remote then return end
        if WizardPending() then return end
        popupShownFor = remote
        ShowPopup(remote)
    end

    if delay and delay > 0 then
        C_Timer.After(delay, open)
    else
        open()
    end
end

---@param remote string
local function PrintChat(remote)
    if chatPrinted then return end
    chatPrinted = true
    print("|cFF00FF00OneWoW|r: " .. format(ns.L["VERSION_CHECK_CHAT"], remote))
end

--- Chat once per session; popup once per remote version this session unless dismissed.
---@param remote string
---@param popupDelay number|nil
local function Notify(remote, popupDelay)
    PrintChat(remote)
    TryPopup(remote, popupDelay)
end

--- Highest version that at least PEERS_TO_SAVE distinct peers report (each
--- peer counts toward every version up to its own best).
---@return string|nil
local function ConfirmedVersion()
    local versions = {}
    for _, ver in pairs(peerBest) do
        versions[#versions + 1] = ver
    end
    if #versions < PEERS_TO_SAVE then return nil end
    sort(versions, function(a, b) return VersionCheck.IsNewer(a, b) end)
    return versions[PEERS_TO_SAVE]
end

---@param remote string
---@param peerKey string|nil nil when the sender is secret / unknown
local function AcceptRemote(remote, peerKey)
    local localVer = LocalVersion()
    if not localVer or not VersionCheck.IsNewer(remote, localVer) or not IsPlausible(remote, localVer) then
        return
    end

    PrintChat(remote)
    if not peerKey then return end

    local best = peerBest[peerKey]
    if best and not VersionCheck.IsNewer(remote, best) then return end
    peerBest[peerKey] = remote

    local confirmed = ConfirmedVersion()
    if not confirmed or not VersionCheck.IsNewer(confirmed, localVer) then return end

    local prev = ns.db.global.remoteUpdateLatestSeen
    if prev == "" or VersionCheck.IsNewer(confirmed, prev) then
        ns.db.global.remoteUpdateLatestSeen = confirmed
        EventRegistry:TriggerEvent("ns.FeatureStateChanged", "remote_update")
    end
    TryPopup(ns.db.global.remoteUpdateLatestSeen)
end

local FlushPendingSends

local function ArmRetry()
    -- While Chat is restricted the state callback flushes; the timer covers
    -- a lockdown result with no Chat restriction reported.
    if retryTimer or ns.Restriction.IsChatRestricted() or timerRetries >= MAX_TIMER_RETRIES then return end
    timerRetries = timerRetries + 1
    retryTimer = C_Timer.NewTimer(LOCKDOWN_RETRY * timerRetries, function()
        retryTimer = nil
        FlushPendingSends()
    end)
end

---@param chatType string
---@return boolean lockdown
local function SendChat(chatType)
    local ver = LocalVersion()
    if not ver then return false end
    return C_ChatInfo.SendAddonMessage(PREFIX, "V\t" .. ver, chatType) == LOCKDOWN
end

local CHANNEL_SENDERS = {
    GROUP = function()
        if IsInRaid() then
            local instanceOnly = not IsInRaid(LE_PARTY_CATEGORY_HOME) and IsInRaid(LE_PARTY_CATEGORY_INSTANCE)
            return SendChat(instanceOnly and "INSTANCE_CHAT" or "RAID")
        elseif IsInGroup() then
            local instanceOnly = not IsInGroup(LE_PARTY_CATEGORY_HOME) and IsInGroup(LE_PARTY_CATEGORY_INSTANCE)
            return SendChat(instanceOnly and "INSTANCE_CHAT" or "PARTY")
        end
        return false
    end,
    GUILD = function()
        return IsInGuild() and SendChat("GUILD")
    end,
    YELL = function()
        return SendChat("YELL")
    end,
}

---@param channel string GROUP / GUILD / YELL
local function SendChannel(channel)
    if CHANNEL_SENDERS[channel]() then
        pendingChat[channel] = true
        ArmRetry()
    end
end

---@param gameAccountID number
local function SendBNAccount(gameAccountID)
    local ver = LocalVersion()
    if not ver then return end
    if C_BattleNet.SendGameData(gameAccountID, PREFIX, "V\t" .. ver) == LOCKDOWN then
        pendingBN[gameAccountID] = true
        ArmRetry()
    end
end

---@param accounts number[]
local function SendBNStaggered(accounts)
    for index, gameAccountID in ipairs(accounts) do
        C_Timer.After((index - 1) * BN_STAGGER, function()
            SendBNAccount(gameAccountID)
        end)
    end
end

local function SendBNFriends()
    local accounts = {}
    local myGUID = UnitGUID("player")
    for i = 1, BNGetNumFriends() do
        for j = 1, C_BattleNet.GetFriendNumGameAccounts(i) do
            local info = C_BattleNet.GetFriendGameAccountInfo(i, j)
            if info and info.isOnline and info.gameAccountID and info.gameAccountID > 0
                and info.clientProgram == "WoW"
                and (not info.wowProjectID or info.wowProjectID == WOW_PROJECT_ID)
                and info.playerGuid ~= myGUID
            then
                accounts[#accounts + 1] = info.gameAccountID
            end
        end
    end
    SendBNStaggered(accounts)
end

--- Resend only what hit lockdown, once.
FlushPendingSends = function()
    if retryTimer then
        retryTimer:Cancel()
        retryTimer = nil
    end
    local channels, accounts = {}, {}
    for channel in pairs(pendingChat) do
        channels[#channels + 1] = channel
    end
    for gameAccountID in pairs(pendingBN) do
        accounts[#accounts + 1] = gameAccountID
    end
    wipe(pendingChat)
    wipe(pendingBN)
    for _, channel in ipairs(channels) do
        SendChannel(channel)
    end
    SendBNStaggered(accounts)
end

local function OnRestrictionState(restrictionType, restrictionState)
    if restrictionType ~= CHAT_RESTRICTION or restrictionState ~= RESTRICTION_INACTIVE then return end
    timerRetries = 0
    FlushPendingSends()
end

local function AnnounceGuild()
    if guildAnnounced or not IsInGuild() then return end
    guildAnnounced = true
    SendChannel("GUILD")
end

--- One broadcast per session: group, guild, yell, Battle.net friends.
local function AnnounceSession()
    if sessionAnnounced or not LocalVersion() then return end
    sessionAnnounced = true
    SendChannel("GROUP")
    AnnounceGuild()
    SendChannel("YELL")
    SendBNFriends()
end

--- Chat line when a new OneWoW peer is heard on a channel. Names are not
--- printed (instance senders can be secret). Secret / missing ids collapse
--- to one slot per channel so the count is "at least one".
---@param kindKey string PARTY / RAID / INSTANCE_CHAT / GUILD / YELL / WHISPER / BN
---@param peerID string|nil
local function NoteNearby(kindKey, peerID)
    if not REPORT_NEARBY then return end
    local label = NEARBY_LABEL[kindKey]
    if not label then return end

    local id = peerID or "?"

    local bucket = nearbySeen[kindKey]
    if not bucket then
        bucket = {}
        nearbySeen[kindKey] = bucket
    end
    if bucket[id] then return end
    bucket[id] = true

    local n = 0
    for _ in pairs(bucket) do
        n = n + 1
    end
    print("|cFF00FF00OneWoW|r: Nearby: " .. label .. " (" .. n .. ")")
end

---@param name string
---@param realm string
---@return string
local function PeerKey(name, realm)
    return name .. "-" .. gsub(realm, "[%s%-]", "")
end

--- Name-Realm key for a chat sender; nil when missing or secret.
---@param sender string|nil
---@return string|nil
local function ChatPeerKey(sender)
    if not sender or ns.Restriction.IsSecretValue(sender) or sender == "" then return nil end
    local name, realm = strsplit("-", sender, 2)
    return PeerKey(name, (realm and realm ~= "") and realm or GetNormalizedRealmName())
end

---@param peerKey string|nil
---@return boolean
local function IsSelf(peerKey)
    return peerKey == PeerKey(UnitName("player"), GetNormalizedRealmName())
end

---@param text string
---@param kindKey string
---@param peerKey string|nil
local function HandlePayload(text, kindKey, peerKey)
    NoteNearby(kindKey, peerKey)
    local remote = strmatch(text, "^V\t(.+)$")
    if remote then
        AcceptRemote(remote, peerKey)
    end
end

local function OnChatAddon(_, prefix, text, channel, sender)
    if prefix ~= PREFIX or not text then return end
    local peerKey = ChatPeerKey(sender)
    if IsSelf(peerKey) then return end
    HandlePayload(text, channel, peerKey)
end

local function OnBNChatAddon(_, prefix, text, _, senderID)
    if prefix ~= PREFIX or not text or not senderID or senderID <= 0 then return end
    local info = C_BattleNet.GetGameAccountInfoByID(senderID)
    local peerKey = info and info.characterName and info.realmName
        and PeerKey(info.characterName, info.realmName) or nil
    HandlePayload(text, "BN", peerKey)
end

local function OnGroupRoster()
    local num = GetNumGroupMembers()
    if sessionAnnounced and num > 1 and num > groupSize then
        SendChannel("GROUP")
    end
    groupSize = num
end

local function OnGuildUpdate(_, unit)
    if unit ~= "player" then return end
    if not IsInGuild() then
        guildAnnounced = false
    elseif sessionAnnounced then
        AnnounceGuild()
    end
end

local function NotifyPersisted()
    local seen = ns.db.global.remoteUpdateLatestSeen
    local localVer = LocalVersion()
    if seen ~= "" and localVer and VersionCheck.IsNewer(seen, localVer) then
        Notify(seen, LOGIN_POPUP_DELAY)
    end
end

ns:RegisterCoreLoginHandler("VersionCheck", function()
    PruneIfUpdated()
    C_ChatInfo.RegisterAddonMessagePrefix(PREFIX)
    ns.RegisterEvent("CHAT_MSG_ADDON", "VersionCheck", OnChatAddon)
    ns.RegisterEvent("BN_CHAT_MSG_ADDON", "VersionCheck", OnBNChatAddon)
    ns.RegisterEvent("GROUP_ROSTER_UPDATE", "VersionCheck", OnGroupRoster)
    ns.RegisterEvent("PLAYER_GUILD_UPDATE", "VersionCheck", OnGuildUpdate)
    ns.Restriction.RegisterStateCallback("VersionCheck", OnRestrictionState)
    groupSize = GetNumGroupMembers()
    NotifyPersisted()
end)

ns:RegisterCoreEnteringWorldHandler("VersionCheck", function()
    if sessionAnnounced or announcePending then return end
    announcePending = true
    C_Timer.After(ANNOUNCE_DELAY, function()
        announcePending = false
        AnnounceSession()
    end)
end)
