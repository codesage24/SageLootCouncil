-- =========================
-- Main Frame
-- =========================
local frame = CreateFrame("Frame", "SageLootCouncilFrame", UIParent)
frame:SetSize(420, 430)
frame:SetPoint("CENTER")
frame:SetFrameStrata("DIALOG")
frame:SetFrameLevel(100)
frame:EnableMouse(true)
frame:SetMovable(true)
frame:RegisterForDrag("LeftButton")
frame:Hide()

-- Main panel background / border
frame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 32,
    insets = {
        left = 11,
        right = 12,
        top = 12,
        bottom = 11
    }
})

-- Built-in header/title texture
local header = frame:CreateTexture(nil, "ARTWORK")
header:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
header:SetWidth(256)
header:SetHeight(64)
header:SetPoint("TOP", frame, "TOP", 0, 12)

-- Title text
local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOP", frame, "TOP", 0, -3)
title:SetText("Sage Loot Council")

-- Close X Button
local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)

close:SetScript("OnClick", function()
    SLC:Clear()
    frame:Hide()
end)

-- Dragging
frame:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)

frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)

SLC.frame = frame

-- =========================
-- Toggle UI
-- =========================
function SLC:ToggleUI()
    if frame:IsShown() then
        frame:Hide()
        SLC:Clear()
    else
        frame:SetFrameStrata("DIALOG")
        frame:SetFrameLevel(100)
        frame:Show()
        self:BuildGrid()
    end
end

-- =========================
-- Bag Update Auto Refresh
-- =========================
frame:RegisterEvent("BAG_UPDATE")
frame:SetScript("OnEvent", function()
    if frame:IsShown() then
        SLC:BuildGrid()
    end
end)

-- =========================
-- Build Item Grid
-- =========================
function SLC:BuildGrid()

    -- Cleanup old buttons
    if frame.buttons then
        for _, b in pairs(frame.buttons) do
            b:Hide()
            b:SetParent(nil)
        end
    end

    frame.buttons = {}
    local index = 1

    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do

            local texture, count = GetContainerItemInfo(bag, slot)
            local link = GetContainerItemLink(bag, slot)

            if texture and link then

                local btn = CreateFrame("Button", nil, frame)
                btn:SetSize(32, 32)

                local row = math.floor((index - 1) / 10)
                local col = (index - 1) % 10

                btn:SetPoint("TOPLEFT", 25 + col * 36, -55 - row * 36)
                btn:SetFrameStrata("DIALOG")
                btn:SetFrameLevel(frame:GetFrameLevel() + 1)

                -- Icon
                local icon = btn:CreateTexture(nil, "BACKGROUND")
                icon:SetAllPoints()
                icon:SetTexture(texture)

                -- Strong border
                btn:SetBackdrop({
                    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                    edgeSize = 16,
                })
                btn:SetBackdropBorderColor(0, 0, 0, 0)

                -- Gold selection overlay
                local overlay = btn:CreateTexture(nil, "OVERLAY")
                overlay:SetAllPoints()
                overlay:SetTexture("Interface\\Buttons\\WHITE8x8")
                overlay:SetVertexColor(1, 0.85, 0, 0.35)
                overlay:Hide()
                btn.overlay = overlay

                -- Checkmark
                local check = btn:CreateTexture(nil, "OVERLAY")
                check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
                check:SetSize(24, 24)
                check:SetPoint("CENTER")
                check:Hide()
                btn.check = check

                -- Capture locals
                local b = bag
                local s = slot
                local l = link
                local key = b .. ":" .. s

                -- Restore selected appearance after rebuild
                if SLC.selectedItems[key] then
                    btn:SetBackdropBorderColor(1, 0.82, 0, 1)
                    btn.overlay:Show()
                    btn.check:Show()
                end

                -- Click handler
                btn:SetScript("OnClick", function()
                    SLC:ToggleItem(b, s, l)

                    local selected = SLC.selectedItems[key]

                    if selected then
                        btn:SetBackdropBorderColor(1, 0.82, 0, 1)
                        btn.overlay:Show()
                        btn.check:Show()
                    else
                        btn:SetBackdropBorderColor(0, 0, 0, 0)
                        btn.overlay:Hide()
                        btn.check:Hide()
                    end
                end)

                -- Tooltip
                btn:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetHyperlink(l)
                    GameTooltip:Show()
                end)

                btn:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)

                frame.buttons[index] = btn
                index = index + 1
            end
        end
    end
end

-- =========================
-- Bottom Buttons
-- =========================
local submit = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
submit:SetSize(90, 30)
submit:SetPoint("BOTTOM", frame, "BOTTOM", -100, 18)
submit:SetText("Submit")

submit:SetScript("OnClick", function()
    if SLC.Submit then
        SLC:Submit()
        frame:Hide()
        SLC:Clear()
    else
        print("SLC: Submit() not implemented.")
    end
end)

local clear = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
clear:SetSize(90, 30)
clear:SetPoint("LEFT", submit, "RIGHT", 10, 0)
clear:SetText("Clear")

clear:SetScript("OnClick", function()
    SLC:Clear()
    SLC:BuildGrid()
end)

local cancel = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
cancel:SetSize(90, 30)
cancel:SetPoint("LEFT", clear, "RIGHT", 10, 0)
cancel:SetText("Cancel")

cancel:SetScript("OnClick", function()
    frame:Hide()
    SLC:Clear()
end)
