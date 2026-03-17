TwitchDropsWatcher = TwitchDropsWatcher or {}
TwitchDropsWatcher.Settings = TwitchDropsWatcher.Settings or {}

-- ============================================================
-- Helpers (duplicated locally to keep Settings self-contained)
-- ============================================================

local function AddPixelBorder(frame, r, g, b, a, thickness)
    thickness = thickness or 1
    local border = frame:CreateTexture(nil, "BORDER")
    border:SetColorTexture(r, g, b, a or 1)
    border:SetPoint("TOPLEFT",     frame, "TOPLEFT",     -thickness,  thickness)
    border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT",  thickness, -thickness)
    return border
end

local function CreateBg(frame, r, g, b, a)
    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(frame)
    bg:SetColorTexture(r, g, b, a or 1)
    return bg
end

-- ============================================================
-- Toggle row builder
-- ============================================================

local function CreateToggleRow(parent, yOffset, label, description, getFunc, setFunc)
    local row = CreateFrame("Frame", nil, parent)
    row:SetSize(340, 52)
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, yOffset)
    CreateBg(row, 0.10, 0.10, 0.10, 1)
    AddPixelBorder(row, 0.20, 0.20, 0.20, 1, 1)

    -- Left purple stripe
    local stripe = row:CreateTexture(nil, "BORDER")
    stripe:SetWidth(3)
    stripe:SetPoint("TOPLEFT",    row, "TOPLEFT",   0, 0)
    stripe:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 0, 0)
    stripe:SetColorTexture(0.57, 0.27, 0.96, 1)

    -- Label
    local labelText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    labelText:SetPoint("TOPLEFT", row, "TOPLEFT", 14, -8)
    labelText:SetTextColor(0.95, 0.95, 1.0)
    labelText:SetText(label)

    -- Description
    local descText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    descText:SetPoint("TOPLEFT", labelText, "BOTTOMLEFT", 0, -3)
    descText:SetTextColor(0.55, 0.55, 0.60)
    descText:SetText(description)

    -- Checkbox (right side)
    local checkbox = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
    checkbox:SetSize(22, 22)
    checkbox:SetPoint("RIGHT", row, "RIGHT", -10, 0)
    checkbox:SetChecked(getFunc())
    checkbox:SetScript("OnClick", function(self)
        setFunc(self:GetChecked())
    end)

    return row
end

-- ============================================================
-- Create settings frame
-- ============================================================

function TwitchDropsWatcher.Settings:Create()
    local frame = CreateFrame("Frame", "TwitchDropsWatcherSettings", UIParent)
    frame:SetSize(370, 240)
    frame:SetPoint("TOPLEFT", TwitchDropsWatcherFrame or UIParent, "TOPRIGHT", 8, 0)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetFrameStrata("DIALOG")
    frame:Hide()
    tinsert(UISpecialFrames, "TwitchDropsWatcherSettings")

    -- Background
    CreateBg(frame, 0.08, 0.08, 0.08, 0.97)
    AddPixelBorder(frame, 0.20, 0.20, 0.20, 1, 2)

    -- Header
    local header = CreateFrame("Frame", nil, frame)
    header:SetHeight(38)
    header:SetPoint("TOPLEFT",  frame, "TOPLEFT",   2, -2)
    header:SetPoint("TOPRIGHT", frame, "TOPRIGHT",  -2,  0)
    CreateBg(header, 0.13, 0.13, 0.13, 1)

    local headerLine = header:CreateTexture(nil, "OVERLAY")
    headerLine:SetHeight(1)
    headerLine:SetPoint("BOTTOMLEFT",  header, "BOTTOMLEFT")
    headerLine:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT")
    headerLine:SetColorTexture(0.57, 0.27, 0.96, 0.6)

    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("LEFT", header, "LEFT", 12, 0)
    title:SetText("|cffffffffSettings|r")

    -- Close button
    local closeBtn = CreateFrame("Button", nil, header)
    closeBtn:SetSize(26, 26)
    closeBtn:SetPoint("TOPRIGHT", header, "TOPRIGHT", -8, -6)

    local closeIcon = closeBtn:CreateTexture(nil, "ARTWORK")
    closeIcon:SetAllPoints(closeBtn)
    closeIcon:SetTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
    closeIcon:SetVertexColor(0.65, 0.65, 0.65, 1)

    closeBtn:SetScript("OnEnter", function(self)
        closeIcon:SetVertexColor(1, 0.3, 0.3, 1)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
        GameTooltip:SetText("Close", 1, 1, 1)
        GameTooltip:Show()
    end)
    closeBtn:SetScript("OnLeave", function()
        closeIcon:SetVertexColor(0.65, 0.65, 0.65, 1)
        GameTooltip:Hide()
    end)
    closeBtn:SetScript("OnClick", function() frame:Hide() end)

    -- Toggle rows
    local content = CreateFrame("Frame", nil, frame)
    content:SetPoint("TOPLEFT",     frame, "TOPLEFT",    10, -48)
    content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10,  10)

    CreateToggleRow(content, -0,
        "Notify on Login",
        "Print active campaigns to chat when logging in.",
        function() return TwitchDropsWatcherDB.notifyOnLogin end,
        function(val) TwitchDropsWatcherDB.notifyOnLogin = val end
    )

    CreateToggleRow(content, -60,
        "Play Sound",
        "Play an alert sound when active campaigns are found.",
        function() return TwitchDropsWatcherDB.playSound end,
        function(val) TwitchDropsWatcherDB.playSound = val end
    )

    CreateToggleRow(content, -120,
        "Auto-Open UI",
        "Automatically open the drops window on login.",
        function() return TwitchDropsWatcherDB.autoOpenUI end,
        function(val) TwitchDropsWatcherDB.autoOpenUI = val end
    )

    self.frame = frame
    return frame
end

-- ============================================================
-- Toggle
-- ============================================================

function TwitchDropsWatcher.Settings:Toggle()
    if not self.frame then
        self.frame = self:Create()
    end
    self.frame:SetShown(not self.frame:IsShown())
end
