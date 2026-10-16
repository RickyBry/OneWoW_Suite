local _, ns = ...

ns.Minimap = {}
local MinimapMod = ns.Minimap

local contextMenu
local minimapBtn
local position

local OneWoW_GUI = OneWoW_GUI

local ROW_HEIGHT = 22

local function EnsureContextMenu()
    if contextMenu then return contextMenu end
    contextMenu = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    contextMenu:SetFrameStrata("FULLSCREEN_DIALOG")
    contextMenu:SetBackdrop(OneWoW_GUI.Constants.BACKDROP_SOFT)
    contextMenu.rows = {}
    contextMenu:SetScript("OnUpdate", function(self, elapsed)
        if not self:IsMouseOver() and not self.anchor:IsMouseOver() then
            self.timeOutside = self.timeOutside + elapsed
            if self.timeOutside > 0.5 then
                self:Hide()
            end
        else
            self.timeOutside = 0
        end
    end)
    contextMenu:Hide()
    return contextMenu
end

local function GetMenuRow(index)
    local row = contextMenu.rows[index]
    if row then return row end

    row = CreateFrame("Button", nil, contextMenu, "BackdropTemplate")
    row:SetHeight(ROW_HEIGHT)
    row:SetPoint("TOPLEFT", contextMenu, "TOPLEFT", 4, -4 - (index - 1) * ROW_HEIGHT)
    row:SetPoint("TOPRIGHT", contextMenu, "TOPRIGHT", -4, -4 - (index - 1) * ROW_HEIGHT)
    row:SetBackdrop(OneWoW_GUI.Constants.BACKDROP_SIMPLE)
    row:SetBackdropColor(0, 0, 0, 0)
    row.text = OneWoW_GUI:CreateFS(row, 12)
    row.alertIcon = row:CreateTexture(nil, "OVERLAY")
    row.alertIcon:SetSize(16, 16)
    row.alertIcon:SetPoint("LEFT", 4, 0)
    row.alertIcon:SetAtlas("Ping_Chat_Warning")
    row:SetScript("OnEnter", function(self)
        self:SetBackdropColor(OneWoW_GUI:GetThemeColor("BG_HOVER"))
    end)
    row:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0, 0, 0, 0)
    end)
    row:SetScript("OnClick", function(self)
        contextMenu:Hide()
        self.action()
    end)
    contextMenu.rows[index] = row
    return row
end

local function ShowContextMenu(anchorFrame)
    local entries = ns._minimapEntries or {}
    local oneWoWEntry
    local otherEntries = {}
    for _, item in ipairs(entries) do
        if item.addon == "OneWoW" then
            oneWoWEntry = item
        elseif _G[item.addon] ~= nil then
            tinsert(otherEntries, item)
        end
    end
    sort(otherEntries, function(a, b) return (a.label or "") < (b.label or "") end)

    local visibleItems = {}
    if oneWoWEntry then
        tinsert(visibleItems, { label = oneWoWEntry.label, global = "OneWoW", action = oneWoWEntry.callback or (function() ns.UI:Show() end) })
    end
    for _, item in ipairs(otherEntries) do
        local action = item.callback
        if not action and item.tabKey then
            action = function() ns.UI:Show(item.tabKey) end
        end
        if action then
            tinsert(visibleItems, { label = item.label, global = item.addon, action = action })
        end
    end

    if #visibleItems == 0 then return end

    local menu = EnsureContextMenu()
    menu:Hide()
    menu:SetBackdropColor(OneWoW_GUI:GetThemeColor("BG_PRIMARY"))
    menu:SetBackdropBorderColor(OneWoW_GUI:GetThemeColor("BORDER_DEFAULT"))

    local maxWidth = 140
    for index, item in ipairs(visibleItems) do
        local row = GetMenuRow(index)
        local hasErrorAlert = item.global == "OneWoW_Utility_DevTool"
            and OneWoW_Utility_DevTool_API ~= nil
            and OneWoW_Utility_DevTool_API.HasCurrentSessionErrors()
        row.alertIcon:SetShown(hasErrorAlert)
        row.text:ClearAllPoints()
        row.text:SetPoint("LEFT", hasErrorAlert and 24 or 8, 0)
        row.text:SetText(item.label)
        row.text:SetTextColor(OneWoW_GUI:GetThemeColor("TEXT_PRIMARY"))
        row:SetBackdropColor(0, 0, 0, 0)
        row.action = item.action
        row:Show()

        local textW = row.text:GetStringWidth() + 20 + (hasErrorAlert and 16 or 0)
        if textW > maxWidth then maxWidth = textW end
    end
    for index = #visibleItems + 1, #menu.rows do
        menu.rows[index]:Hide()
    end

    menu:SetSize(maxWidth + 16, #visibleItems * ROW_HEIGHT + 12)

    local screenW   = UIParent:GetWidth()
    local menuW     = menu:GetWidth()
    local menuH     = menu:GetHeight()
    local ancLeft   = anchorFrame:GetLeft()   or 0
    local ancBottom = anchorFrame:GetBottom() or 0

    local goLeft  = (ancLeft + menuW) > screenW
    local goAbove = (ancBottom - menuH) < 0

    menu:ClearAllPoints()
    if goAbove and goLeft then
        menu:SetPoint("BOTTOMRIGHT", anchorFrame, "TOPRIGHT", 0, 2)
    elseif goAbove then
        menu:SetPoint("BOTTOMLEFT", anchorFrame, "TOPLEFT", 0, 2)
    elseif goLeft then
        menu:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT", 0, -2)
    else
        menu:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT", 0, -2)
    end

    menu.anchor = anchorFrame
    menu.timeOutside = 0
    menu:Show()
end

local function GetCurrentIcon()
    return OneWoW_GUI:GetBrandIcon(OneWoW_GUI:GetSetting("minimap.theme"))
end

local MinimapShapes = {
    ["ROUND"]                 = {true,  true,  true,  true },
    ["SQUARE"]                = {false, false, false, false},
    ["CORNER-TOPLEFT"]        = {false, false, false, true },
    ["CORNER-TOPRIGHT"]       = {false, false, true,  false},
    ["CORNER-BOTTOMLEFT"]     = {false, true,  false, false},
    ["CORNER-BOTTOMRIGHT"]    = {true,  false, false, false},
    ["SIDE-LEFT"]             = {false, true,  false, true },
    ["SIDE-RIGHT"]            = {true,  false, true,  false},
    ["SIDE-TOP"]              = {false, false, true,  true },
    ["SIDE-BOTTOM"]           = {true,  true,  false, false},
    ["TRICORNER-TOPLEFT"]     = {false, true,  true,  true },
    ["TRICORNER-TOPRIGHT"]    = {true,  false, true,  true },
    ["TRICORNER-BOTTOMLEFT"]  = {true,  true,  false, true },
    ["TRICORNER-BOTTOMRIGHT"] = {true,  true,  true,  false},
}

local function UpdatePosition(self)
    local angle = math.rad(position)
    local x, y, q = math.cos(angle), math.sin(angle), 1
    if x < 0 then q = q + 1 end
    if y > 0 then q = q + 2 end
    local width   = Minimap:GetWidth()  * 0.5
    local height  = Minimap:GetHeight() * 0.5
    local rounding = 10
    if MinimapShapes[GetMinimapShape and GetMinimapShape() or "ROUND"][q] then
        x, y = x * width, y * height
    else
        x = math.max(-width,  math.min(x * (math.sqrt(2 * width^2)  - rounding), width))
        y = math.max(-height, math.min(y * (math.sqrt(2 * height^2) - rounding), height))
    end
    self:SetPoint("CENTER", Minimap, "CENTER", math.floor(x), math.floor(y))
end

local function CreateMinimapButton()
    if minimapBtn then return end
    position = ns.db.global.minimap.minimapPos

    minimapBtn = CreateFrame("Button", "OneWoW_MinimapButton", Minimap)
    minimapBtn:SetSize(35, 35)
    minimapBtn:SetFrameStrata("MEDIUM")
    minimapBtn:SetMovable(true)
    minimapBtn:EnableMouse(true)
    minimapBtn:RegisterForDrag("LeftButton", "RightButton")
    minimapBtn:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    local tex = minimapBtn:CreateTexture(nil, "BACKGROUND")
    tex:SetTexture(GetCurrentIcon())
    tex:SetAllPoints()
    tex:Show()
    minimapBtn.tex = tex

    minimapBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("|cFFFFD1001WoW|r", 1, 0.82, 0, 1)
        local L = ns.L
        GameTooltip:AddLine(L["MINIMAP_TOOLTIP_HINT"], 0.7, 0.7, 0.8, 1)
        GameTooltip:AddLine(L["MINIMAP_RIGHT_CLICK"], 0.5, 0.5, 0.6, 1)
        GameTooltip:Show()
    end)
    minimapBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    minimapBtn:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            ns.UI:Toggle()
        elseif button == "RightButton" then
            ShowContextMenu(self)
        end
    end)
    minimapBtn:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", function(myself)
            local mx, my = Minimap:GetCenter()
            local px, py = GetCursorPosition()
            local scale = Minimap:GetEffectiveScale()
            position = math.deg(math.atan2((py / scale) - my, (px / scale) - mx)) % 360
            ns.db.global.minimap.minimapPos = position
            myself:Raise()
            UpdatePosition(myself)
        end)
    end)
    minimapBtn:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
    end)
    minimapBtn:SetScript("OnEvent", function(self)
        UpdatePosition(self)
    end)
    minimapBtn:RegisterEvent("LOADING_SCREEN_DISABLED")

    UpdatePosition(minimapBtn)
    minimapBtn:Show()
end

function MinimapMod:UpdateIcon()
    if minimapBtn and minimapBtn.tex then
        minimapBtn.tex:SetTexture(GetCurrentIcon())
    end
    if MinimapMod._ldbPlugin then
        MinimapMod._ldbPlugin.icon = GetCurrentIcon()
    end
end

function MinimapMod:Initialize()
    local ldb = LibStub and LibStub:GetLibrary("LibDataBroker-1.1", true)
    if ldb then
        local plugin = ldb:NewDataObject("OneWoW", {
            type = "launcher",
            icon = GetCurrentIcon(),
            OnClick = function(myself, button)
                if button == "LeftButton" then
                    ns.UI:Toggle()
                elseif button == "RightButton" then
                    ShowContextMenu(myself)
                end
            end,
            OnEnter = function(myself)
                GameTooltip:SetOwner(myself, "ANCHOR_LEFT")
                GameTooltip:AddLine("|cFFFFD1001WoW|r", 1, 0.82, 0, 1)
                local L = ns.L
                GameTooltip:AddLine(L["MINIMAP_TOOLTIP_HINT"], 0.7, 0.7, 0.8, 1)
                GameTooltip:AddLine(L["MINIMAP_RIGHT_CLICK"], 0.5, 0.5, 0.6, 1)
                GameTooltip:Show()
            end,
            OnLeave = function()
                GameTooltip:Hide()
            end,
        })
        MinimapMod._ldbPlugin = plugin
    end

    if OneWoW_GUI:GetSetting("minimap.hide") then return end

    CreateMinimapButton()
end

function MinimapMod:Show()
    if not minimapBtn then
        CreateMinimapButton()
    else
        minimapBtn:Show()
    end
end

function MinimapMod:Hide()
    if minimapBtn then minimapBtn:Hide() end
end

function MinimapMod:Toggle()
    OneWoW_GUI:SetSetting("minimap.hide", not OneWoW_GUI:GetSetting("minimap.hide"))
end

function MinimapMod:IsShown()
    return minimapBtn and minimapBtn:IsShown()
end

--- Hub minimap button frame (for badges / attachments). Suite units no longer
--- create their own LibDBIcon launchers.
---@return Frame|nil
function OneWoW_GUI:GetMinimapButton()
    return OneWoW_MinimapButton
end

ns:RegisterCoreLoginHandler("Minimap", function()
    MinimapMod:Initialize()
end, "early")
