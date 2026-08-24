local _, SNEK = ...

SNEK.Minimap = {}
local M = SNEK.Minimap

local button
local RADIUS = 105

local function UpdatePosition()
    if not button then return end
    local angle = math.rad(SNEK.DB.Get().minimapAngle or 220)
    local x = math.cos(angle) * RADIUS
    local y = math.sin(angle) * RADIUS
    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

function M.UpdateVisibility()
    if not button then return end
    if SNEK.DB.Get().showMinimap then
        button:Show()
        UpdatePosition()
    else
        button:Hide()
    end
end

function M.Create()
    if button then return end

    button = CreateFrame("Button", "SNEKMinimapButton", Minimap)
    button:SetSize(32, 32)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(8)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:RegisterForDrag("LeftButton")
    button:SetClampedToScreen(true)

    local icon = button:CreateTexture(nil, "BACKGROUND")
    icon:SetSize(20, 20)
    icon:SetTexture("Interface\\AddOns\\SNEK\\media\\minimap.png")
    icon:SetPoint("TOPLEFT", 7, -5)
    icon:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask")

    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetSize(52, 52)
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetPoint("TOPLEFT", -1, 1)

    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    button:SetScript("OnClick", function(_, mouseButton)
        if mouseButton == "RightButton" then
            SNEK.DB.Get().showMinimap = false
            M.UpdateVisibility()
            print("|cff00ff00S.N.E.K.:|r Minimap icon hidden.")
        else
            SNEK.Options.Toggle()
        end
    end)

    button:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", function()
            local mx, my = GetCursorPosition()
            local cx, cy = Minimap:GetCenter()
            local scale = Minimap:GetEffectiveScale()
            local angle = math.deg(math.atan2(my / scale - cy, mx / scale - cx))
            SNEK.DB.Get().minimapAngle = angle
            UpdatePosition()
        end)
    end)

    button:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
    end)

    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("S.N.E.K.", 0, 1, 0)
        GameTooltip:AddLine("Left-click: Open options", 1, 1, 1)
        GameTooltip:AddLine("Right-click: Hide icon", 1, 1, 1)
        GameTooltip:AddLine("Drag to move", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)

    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    M.UpdateVisibility()
end