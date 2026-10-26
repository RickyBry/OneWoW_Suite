-- ============================================================================
-- Fast Loot
-- ============================================================================
-- Loots every slot on LOOT_READY when auto loot applies.
--
-- Hide loot window (toggle):
--   LOOT_READY fires before LOOT_OPENED, so LootFrame is moved under a hidden
--   holder before Blizzard shows it. The frame keeps working (IsShown stays
--   true) but never becomes visible, so it cannot flash. A parent swap is used
--   instead of SetAlpha because the panel's ShowAnim (setToFinalAlpha) would
--   reset the alpha to 1.
--   The window is handed back to its real parent as soon as looting stalls:
--   a UI error (bags full), a Bind on Pickup confirm, a locked slot, or slots
--   still left after REVEAL_DELAY. On LOOT_CLOSED a still-hidden frame is
--   hidden directly (its close animation cannot finish while invisible) and
--   then returned to its parent.
-- ============================================================================
local _, ns = ...
local FastLootModule = ns.ModuleRegistry:Current()
if not FastLootModule then return end

local REVEAL_DELAY = 0.3

function FastLootModule:OnEnable()
    if not self._frame then
        self._frame = CreateFrame("Frame", "OneWoW_QoL_FastLoot")
        self._frame:SetScript("OnEvent", function(_, event)
            if event == "LOOT_READY" then
                self:LOOT_READY()
            elseif event == "LOOT_CLOSED" then
                self:LOOT_CLOSED()
            else
                self:RevealLootFrame()
            end
        end)
    end
    self._frame:RegisterEvent("LOOT_READY")
    self._frame:RegisterEvent("LOOT_CLOSED")
end

function FastLootModule:OnDisable()
    if self._frame then
        self._frame:UnregisterAllEvents()
    end
    self:RevealLootFrame()
end

function FastLootModule:OnToggle(toggleId, value)
    if toggleId == "hide_loot_window" and not value then
        self:RevealLootFrame()
    end
end

function FastLootModule:LOOT_READY()
    if GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE") then
        local now = GetTime()
        if (now - self._epoch) >= 0.3 then
            if ns.ModuleRegistry:GetToggleValue("fastloot", "hide_loot_window") then
                self:ConcealLootFrame()
            end
            for i = GetNumLootItems(), 1, -1 do
                LootSlot(i)
            end
            self._epoch = now
            if self._concealed then
                self:CheckStalledLoot(now)
            end
        end
    end
end

function FastLootModule:LOOT_CLOSED()
    if self._concealed then
        LootFrame:StopAllAnimations()
        LootFrame:Hide()
        self:RevealLootFrame()
    end
end

function FastLootModule:ConcealLootFrame()
    if self._concealed then return end
    if not self._holder then
        self._holder = CreateFrame("Frame", nil, UIParent)
        self._holder:Hide()
    end
    self._lootParent = LootFrame:GetParent()
    self._lootStrata = LootFrame:GetFrameStrata()
    self._lootLevel = LootFrame:GetFrameLevel()
    LootFrame:SetParent(self._holder)
    self._concealed = true
    self._frame:RegisterEvent("UI_ERROR_MESSAGE")
    self._frame:RegisterEvent("LOOT_BIND_CONFIRM")
end

function FastLootModule:RevealLootFrame()
    if not self._concealed then return end
    self._concealed = false
    self._frame:UnregisterEvent("UI_ERROR_MESSAGE")
    self._frame:UnregisterEvent("LOOT_BIND_CONFIRM")
    LootFrame:SetParent(self._lootParent)
    LootFrame:SetFrameStrata(self._lootStrata)
    LootFrame:SetFrameLevel(self._lootLevel)
end

--- Reveals the window right away for locked slots, otherwise once more after
--- REVEAL_DELAY if anything is still left to loot.
---@param epoch number GetTime() of the LOOT_READY pass that concealed the frame
function FastLootModule:CheckStalledLoot(epoch)
    for i = 1, GetNumLootItems() do
        local _, _, _, _, _, locked = GetLootSlotInfo(i)
        if locked then
            self:RevealLootFrame()
            return
        end
    end
    C_Timer.After(REVEAL_DELAY, function()
        if self._concealed and self._epoch == epoch then
            for i = 1, GetNumLootItems() do
                if LootSlotHasItem(i) then
                    self:RevealLootFrame()
                    return
                end
            end
        end
    end)
end
