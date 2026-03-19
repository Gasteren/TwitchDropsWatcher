TwitchDropsWatcher = TwitchDropsWatcher or {}
TwitchDropsWatcher.UI = TwitchDropsWatcher.UI or {}

-- ============================================================
-- Helpers
-- ============================================================

local function AddPixelBorder(frame, r, g, b, a, thickness)
    thickness = thickness or 1
    a = a or 1
    local border = frame:CreateTexture(nil, "BORDER")
    border:SetColorTexture(r, g, b, a)
    border:SetPoint("TOPLEFT",     frame, "TOPLEFT",     -thickness,  thickness)
    border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT",  thickness, -thickness)
    return border
end

local function CreateBackground(frame, r, g, b, a)
    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(frame)
    bg:SetColorTexture(r, g, b, a or 1)
    return bg
end

-- ============================================================
-- Time formatting
-- ============================================================

local function FormatTimeRemaining(seconds)
    if seconds <= 0 then return "|cffff4444Ended|r" end
    local days    = floor(seconds / 86400)
    seconds = seconds % 86400
    local hours   = floor(seconds / 3600)
    seconds = seconds % 3600
    local minutes = floor(seconds / 60)
    if days > 0 then
        return string.format("|cffffffff%dd|r |cffaaaaaa%dh %dm|r", days, hours, minutes)
    elseif hours > 0 then
        return string.format("|cffffffff%dh|r |cffaaaaaa%dm|r", hours, minutes)
    else
        return string.format("|cffff4444%dm|r", minutes)
    end
end

-- ============================================================
-- Main frame creation
-- ============================================================

function TwitchDropsWatcher.UI:Create()
    -- Outer frame: fully custom, no WoW template
    local frame = CreateFrame("Frame", "TwitchDropsWatcherFrame", UIParent)
    frame:SetSize(520, 440)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetFrameStrata("DIALOG")
    frame:Hide()
    tinsert(UISpecialFrames, "TwitchDropsWatcherFrame")

    -- Main dark background (#141414 dark mode)
    CreateBackground(frame, 0.08, 0.08, 0.08, 0.97)
    -- Subtle dark border
    AddPixelBorder(frame, 0.20, 0.20, 0.20, 1, 2)

    -- ── Header bar ──────────────────────────────────────────
    local header = CreateFrame("Frame", nil, frame)
    header:SetHeight(38)
    header:SetPoint("TOPLEFT",  frame, "TOPLEFT",   2,  -2)
    header:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2,   0)
    CreateBackground(header, 0.13, 0.13, 0.13, 1)

    -- Thin purple accent line under header (only purple touch on the frame)
    local headerLine = header:CreateTexture(nil, "OVERLAY")
    headerLine:SetHeight(1)
    headerLine:SetPoint("BOTTOMLEFT",  header, "BOTTOMLEFT")
    headerLine:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT")
    headerLine:SetColorTexture(0.57, 0.27, 0.96, 0.6)

    -- Twitch glitch logo
    local logoTex = header:CreateTexture(nil, "ARTWORK")
    logoTex:SetSize(28, 28)
    logoTex:SetPoint("LEFT", header, "LEFT", 10, 0)
    logoTex:SetTexture("Interface\\AddOns\\TwitchDropsWatcher\\icons\\twitch")
    logoTex:SetTexCoord(0, 1, 0, 1)

    -- Title
    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("LEFT", logoTex, "RIGHT", 8, 0)
    title:SetText("|cff9146ffTwitch|r |cffffffffDrops Watcher|r")

    -- Settings button (gear icon, left of close button)
    local settingsBtn = CreateFrame("Button", nil, header)
    settingsBtn:SetSize(26, 26)
    settingsBtn:SetPoint("TOPRIGHT", header, "TOPRIGHT", -42, -6)

    local settingsBg = settingsBtn:CreateTexture(nil, "BACKGROUND")
    settingsBg:SetAllPoints(settingsBtn)
    settingsBg:SetColorTexture(0, 0, 0, 0)

    local gearIcon = settingsBtn:CreateTexture(nil, "ARTWORK")
    gearIcon:SetSize(18, 18)
    gearIcon:SetPoint("CENTER", settingsBtn, "CENTER", 0, 0)
    gearIcon:SetTexture("Interface\\Buttons\\UI-OptionsButton")
    gearIcon:SetVertexColor(0.65, 0.65, 0.65, 1)

    settingsBtn:SetScript("OnEnter", function(self)
        gearIcon:SetVertexColor(1, 1, 1, 1)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
        GameTooltip:SetText("Settings", 1, 1, 1)
        GameTooltip:Show()
    end)
    settingsBtn:SetScript("OnLeave", function()
        gearIcon:SetVertexColor(0.65, 0.65, 0.65, 1)
        GameTooltip:Hide()
    end)
    settingsBtn:SetScript("OnClick", function()
        TwitchDropsWatcher.Settings:Toggle()
    end)

    -- Custom close button — flush right in the header
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

    -- Close settings whenever the main frame hides (button or ESC)
    frame:SetScript("OnHide", function()
        if TwitchDropsWatcher.Settings.frame then
            TwitchDropsWatcher.Settings.frame:Hide()
        end
    end)

    -- ── Tab bar ──────────────────────────────────────────────
    local tabBar = CreateFrame("Frame", nil, frame)
    tabBar:SetHeight(30)
    tabBar:SetPoint("BOTTOMLEFT",  frame, "BOTTOMLEFT",   2,  2)
    tabBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2,  0)
    CreateBackground(tabBar, 0.10, 0.10, 0.10, 1)

    local tabLine = tabBar:CreateTexture(nil, "OVERLAY")
    tabLine:SetHeight(1)
    tabLine:SetPoint("TOPLEFT",  tabBar, "TOPLEFT")
    tabLine:SetPoint("TOPRIGHT", tabBar, "TOPRIGHT")
    tabLine:SetColorTexture(0.20, 0.20, 0.20, 1)

    frame.activeTab = "active"

    local function CreateTab(label, tabKey, anchorPoint, anchorX)
        local tab = CreateFrame("Button", nil, tabBar)
        tab:SetSize(120, 30)
        tab:SetPoint(anchorPoint, tabBar, anchorPoint, anchorX, 0)

        local tabBg = tab:CreateTexture(nil, "BACKGROUND")
        tabBg:SetAllPoints(tab)
        tabBg:SetColorTexture(0, 0, 0, 0)
        tab.bg = tabBg

        local tabText = tab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        tabText:SetAllPoints(tab)
        tabText:SetJustifyH("CENTER")
        tabText:SetJustifyV("MIDDLE")
        tab.text = tabText

        local tabUnderline = tab:CreateTexture(nil, "OVERLAY")
        tabUnderline:SetHeight(2)
        tabUnderline:SetPoint("BOTTOMLEFT",  tab, "BOTTOMLEFT")
        tabUnderline:SetPoint("BOTTOMRIGHT", tab, "BOTTOMRIGHT")
        tabUnderline:SetColorTexture(0.57, 0.27, 0.96, 0)
        tab.underline = tabUnderline

        tab:SetScript("OnEnter", function()
            if frame.activeTab ~= tabKey then
                tabBg:SetColorTexture(0.15, 0.15, 0.15, 1)
            end
        end)
        tab:SetScript("OnLeave", function()
            if frame.activeTab ~= tabKey then
                tabBg:SetColorTexture(0, 0, 0, 0)
            end
        end)
        tab:SetScript("OnClick", function()
            frame.activeTab = tabKey
            TwitchDropsWatcher.UI:Update()
        end)

        return tab
    end

    frame.tabActive    = CreateTab("Active",    "active",    "LEFT",  0)
    frame.tabCompleted = CreateTab("Completed", "completed", "LEFT",  120)
    frame.tabExpired   = CreateTab("Expired",   "expired",   "LEFT",  240)

    local function RefreshTabs()
        local tabs = {
            {frame.tabActive,    "active"},
            {frame.tabCompleted, "completed"},
            {frame.tabExpired,   "expired"},
        }
        for _, pair in ipairs(tabs) do
            local tab, key = pair[1], pair[2]
            if frame.activeTab == key then
                tab.bg:SetColorTexture(0.13, 0.13, 0.13, 1)
                tab.text:SetTextColor(1, 1, 1)
                tab.underline:SetColorTexture(0.57, 0.27, 0.96, 1)
            else
                tab.bg:SetColorTexture(0, 0, 0, 0)
                tab.text:SetTextColor(0.55, 0.55, 0.60)
                tab.underline:SetColorTexture(0.57, 0.27, 0.96, 0)
            end
        end
    end
    frame.tabActive.text:SetText("Active")
    frame.tabCompleted.text:SetText("Completed")
    frame.tabExpired.text:SetText("Expired")
    frame.RefreshTabs = RefreshTabs

    -- ── Scroll area (no scrollbar, mousewheel only) ──────────
    local scrollFrame = CreateFrame("ScrollFrame", "TwitchDropsWatcherScroll", frame)
    scrollFrame:SetPoint("TOPLEFT",     frame, "TOPLEFT",     8, -48)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -8,  34)
    scrollFrame:EnableMouseWheel(true)
    scrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local current = self:GetVerticalScroll()
        local max     = self:GetVerticalScrollRange()
        local step    = 30
        local new     = math.max(0, math.min(max, current - delta * step))
        self:SetVerticalScroll(new)
    end)

    local content = CreateFrame("Frame", "TwitchDropsWatcherContent", scrollFrame)
    content:SetSize(504, 380)
    content:SetPoint("TOP", scrollFrame, "TOP", 0, 0)
    scrollFrame:SetScrollChild(content)

    frame.content = content

    -- Timer updater
    frame:SetScript("OnUpdate", function(self, elapsed)
        TwitchDropsWatcher.UI:UpdateTimers(self, elapsed)
    end)

    self.frame = frame
    return frame
end

-- ============================================================
-- Campaign card builder
-- ============================================================

local CARD_H   = 120
local CARD_PAD = 8

local function CreateCampaignCard(parent, campaign, index)
    local card = CreateFrame("Frame", nil, parent)
    card:SetSize(504, CARD_H)
    card:SetPoint("TOP", parent, "TOP", 4, -((index - 1) * (CARD_H + CARD_PAD)))

    -- Alternating card backgrounds (dark mode: #1a1a1a / #1f1f1f)
    local bgR, bgG, bgB = 0.105, 0.105, 0.105
    if index % 2 == 0 then bgR, bgG, bgB = 0.125, 0.125, 0.125 end
    CreateBackground(card, bgR, bgG, bgB, 1)

    -- Left purple accent stripe
    local stripe = card:CreateTexture(nil, "BORDER")
    stripe:SetWidth(3)
    stripe:SetPoint("TOPLEFT",    card, "TOPLEFT",   0, 0)
    stripe:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", 0, 0)
    stripe:SetColorTexture(0.57, 0.27, 0.96, 1)

    -- Bottom separator
    local sep = card:CreateTexture(nil, "OVERLAY")
    sep:SetHeight(1)
    sep:SetPoint("BOTTOMLEFT",  card, "BOTTOMLEFT",  3, 0)
    sep:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT",  0, 0)
    sep:SetColorTexture(0.57, 0.27, 0.96, 0.20)

    -- ── Icon ──────────────────────────────────────────────
    local iconBg = CreateFrame("Frame", nil, card)
    iconBg:SetSize(52, 52)
    iconBg:SetPoint("LEFT", card, "LEFT", 12, 0)
    CreateBackground(iconBg, 0.0, 0.0, 0.0, 0.6)
    AddPixelBorder(iconBg, 0.57, 0.27, 0.96, 0.7, 1)

    local iconBtn = CreateFrame("Button", nil, iconBg)
    iconBtn:SetAllPoints(iconBg)

    local icon = iconBtn:CreateTexture(nil, "ARTWORK")
    icon:SetPoint("TOPLEFT",     iconBg, "TOPLEFT",     2,  -2)
    icon:SetPoint("BOTTOMRIGHT", iconBg, "BOTTOMRIGHT", -2,   2)
    icon:SetTexture(campaign.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    if campaign.itemID then
        iconBtn:SetScript("OnClick", function(self, btn)
            if btn == "LeftButton" and IsControlKeyDown() then
                local link = "|Hitem:" .. campaign.itemID .. "|h[" .. campaign.reward .. "]|h"
                DressUpItemLink(link)
            end
        end)
        iconBtn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText("Ctrl+Click to preview in Dressing Room", 1, 1, 1)
            GameTooltip:Show()
        end)
        iconBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    end

    -- ── Text: left/center column ──────────────────────────
    local textX = 72

    local nameText = card:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    nameText:SetPoint("TOPLEFT", card, "TOPLEFT", textX, -10)
    nameText:SetWidth(235)
    nameText:SetJustifyH("LEFT")
    nameText:SetTextColor(1.0, 0.95, 0.95) -- set by ApplyCollectedStyle or upcoming below
    nameText:SetText(campaign.name)

    local rewardLabel = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    rewardLabel:SetPoint("TOPLEFT", nameText, "BOTTOMLEFT", 0, -6)
    rewardLabel:SetTextColor(0.57, 0.27, 0.96)
    rewardLabel:SetText("REWARD")

    local rewardText = card:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    rewardText:SetPoint("TOPLEFT", rewardLabel, "BOTTOMLEFT", 0, -2)
    rewardText:SetWidth(235)
    rewardText:SetJustifyH("LEFT")
    rewardText:SetTextColor(0.85, 0.85, 0.85)
    rewardText:SetText(campaign.reward)

    local reqLabel = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    reqLabel:SetPoint("TOPLEFT", rewardText, "BOTTOMLEFT", 0, -4)
    reqLabel:SetTextColor(0.57, 0.27, 0.96)
    reqLabel:SetText("REQUIREMENT")

    local reqText = card:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    reqText:SetPoint("TOPLEFT", reqLabel, "BOTTOMLEFT", 0, -2)
    reqText:SetWidth(235)
    reqText:SetJustifyH("LEFT")
    reqText:SetTextColor(1, 0.72, 0.2)
    reqText:SetText(campaign.requirement)

    -- ── Right column: timer ────────────────────────────────
    local isUpcoming = not campaign.isActive and campaign.isUpcoming
    local isExpired  = campaign.isExpired and not campaign.isActive

    local timerLabel = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    timerLabel:SetPoint("TOPRIGHT", card, "TOPRIGHT", -10, -10)
    timerLabel:SetJustifyH("RIGHT")
    timerLabel:SetTextColor(0.57, 0.27, 0.96)
    if isExpired then
        timerLabel:SetText("ENDED")
    elseif isUpcoming then
        timerLabel:SetText("STARTS IN")
    else
        timerLabel:SetText("ENDS IN")
    end

    local timerText = card:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    timerText:SetPoint("TOPRIGHT", timerLabel, "BOTTOMRIGHT", 0, -3)
    timerText:SetJustifyH("RIGHT")
    card.timerText  = timerText
    card.isUpcoming = isUpcoming
    if isExpired then
        timerText:SetText("|cff555555Expired|r")
        card.endTime = nil
    elseif isUpcoming then
        card.endTime = TwitchDropsWatcher.Data:ParseDate(campaign.startDate)
        timerText:SetText(FormatTimeRemaining(card.endTime - time()))
    else
        card.endTime = TwitchDropsWatcher.Data:ParseDate(campaign.endDate)
        timerText:SetText(FormatTimeRemaining(card.endTime - time()))
    end

    -- ── "I have this drop" pill checkbox ──────────────────
    if isUpcoming then
        -- Orange = coming soon
        nameText:SetTextColor(1.0, 0.60, 0.10)
        stripe:SetColorTexture(1.0, 0.60, 0.10, 1)
        local soonLabel = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        soonLabel:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -10, 10)
        soonLabel:SetJustifyH("RIGHT")
        soonLabel:SetTextColor(1.0, 0.60, 0.10, 0.7)
        soonLabel:SetText("Coming soon")
    else
        local isCollected = TwitchDropsWatcherDB.collectedDrops[campaign.name] and true or false

    local checkPill = CreateFrame("Frame", nil, card)
    checkPill:SetSize(160, 26)
    checkPill:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -10, 8)
    CreateBackground(checkPill, 0.18, 0.18, 0.18, 1)
    AddPixelBorder(checkPill, 0.30, 0.30, 0.30, 1, 1)

    local checkbox = CreateFrame("CheckButton", nil, card, "UICheckButtonTemplate")
    checkbox:SetSize(24, 24)
    checkbox:SetPoint("LEFT", checkPill, "LEFT", 2, 0)
    checkbox:SetChecked(isCollected)
    checkbox.campaign = campaign

    local checkLabel = checkPill:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    checkLabel:SetPoint("LEFT", checkPill, "LEFT", 28, 0)
    checkLabel:SetTextColor(0.65, 0.65, 0.65)
    checkLabel:SetText("I have this drop")

    -- Expired: grey. Active: red = available, green = collected
    local function ApplyCollectedStyle(collected)
        if isExpired then
            nameText:SetTextColor(0.50, 0.50, 0.50)
            stripe:SetColorTexture(0.35, 0.35, 0.35, 1)
        elseif collected then
            nameText:SetTextColor(0.20, 0.85, 0.20)
            stripe:SetColorTexture(0.20, 0.85, 0.20, 1)
        else
            nameText:SetTextColor(1.0, 0.25, 0.25)
            stripe:SetColorTexture(1.0, 0.25, 0.25, 1)
        end
    end
    ApplyCollectedStyle(isCollected)

    checkbox:SetScript("OnClick", function(self)
        local name    = self.campaign.name
        local checked = self:GetChecked() and true or false
        TwitchDropsWatcherDB.collectedDrops[name] = checked or nil
        ApplyCollectedStyle(checked)
        -- Refresh the whole UI so active/expired/completed tabs stay in sync
        TwitchDropsWatcher.UI:Update()
        if checked then
            print(string.format("|cff9146ffTwitch Drops Watcher:|r Marked |cffffd700%s|r as collected.", name))
        else
            print(string.format("|cff9146ffTwitch Drops Watcher:|r Unmarked |cffffd700%s|r.", name))
        end
    end)

    checkbox:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine("I have this drop", 0.57, 0.27, 0.96)
        GameTooltip:AddLine("Check this if you already own this reward.", 1, 1, 1)
        GameTooltip:AddLine("This campaign will no longer trigger auto-open or login notifications.", 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)
    checkbox:SetScript("OnLeave", function() GameTooltip:Hide() end)
    end -- end if isUpcoming else

    return card
end

-- ============================================================
-- Update / populate content
-- ============================================================

function TwitchDropsWatcher.UI:Update()
    if not self.frame or not self.frame.content then
        self.frame = self:Create()
    end

    local content = self.frame.content

    for _, child in ipairs({content:GetChildren()}) do
        child:Hide()
        child:SetParent(nil)
    end

    if self.frame.RefreshTabs then
        self.frame.RefreshTabs()
    end

    local activeTab = self.frame.activeTab or "active"

    -- ── Helper: empty state text ──
    local function ShowEmpty(msg)
        content:SetHeight(80)
        local empty = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        empty:SetPoint("CENTER", content, "CENTER", 0, 0)
        empty:SetTextColor(0.5, 0.5, 0.6)
        empty:SetText(msg)
    end

    if activeTab == "completed" then
        local list = {}
        if TwitchDropsWatcher.Data and TwitchDropsWatcher.Data.Campaigns then
            for _, campaign in ipairs(TwitchDropsWatcher.Data.Campaigns) do
                if TwitchDropsWatcherDB.collectedDrops[campaign.name] and not campaign.isUpcoming then
                    table.insert(list, campaign)
                end
            end
        end
        if #list == 0 then ShowEmpty("No completed drops yet.") return end
        for i, campaign in ipairs(list) do CreateCampaignCard(content, campaign, i) end
        content:SetHeight(#list * (CARD_H + CARD_PAD))

    elseif activeTab == "expired" then
        local list = {}
        if TwitchDropsWatcher.Data and TwitchDropsWatcher.Data.Campaigns then
            for _, campaign in ipairs(TwitchDropsWatcher.Data.Campaigns) do
                if campaign.isExpired and not TwitchDropsWatcherDB.collectedDrops[campaign.name] then
                    table.insert(list, campaign)
                end
            end
        end
        if #list == 0 then ShowEmpty("No expired drops.") return end
        for i, campaign in ipairs(list) do CreateCampaignCard(content, campaign, i) end
        content:SetHeight(#list * (CARD_H + CARD_PAD))

    else
        -- Active tab: skip collected campaigns
        local activeCampaigns   = {}
        local upcomingCampaigns = {}
        if TwitchDropsWatcher.Data and TwitchDropsWatcher.Data.Campaigns then
            for _, campaign in ipairs(TwitchDropsWatcher.Data.Campaigns) do
                if campaign.isActive and not TwitchDropsWatcherDB.collectedDrops[campaign.name] then
                    table.insert(activeCampaigns, campaign)
                elseif campaign.isUpcoming then
                    table.insert(upcomingCampaigns, campaign)
                end
            end
        end
        if #activeCampaigns == 0 and #upcomingCampaigns == 0 then
            ShowEmpty("No active Twitch Drop campaigns right now.")
            return
        end
        local index = 1
        for _, campaign in ipairs(activeCampaigns) do
            CreateCampaignCard(content, campaign, index)
            index = index + 1
        end
        for _, campaign in ipairs(upcomingCampaigns) do
            CreateCampaignCard(content, campaign, index)
            index = index + 1
        end
        content:SetHeight((index - 1) * (CARD_H + CARD_PAD))
    end
end

-- ============================================================
-- Timer updater (called every frame via OnUpdate)
-- ============================================================

function TwitchDropsWatcher.UI:UpdateTimers(frame, elapsed)
    if not frame:IsShown() or not frame.content then return end
    local currentTime = time()
    for _, card in ipairs({frame.content:GetChildren()}) do
        if card.timerText and card.endTime then
            card.timerText:SetText(FormatTimeRemaining(card.endTime - currentTime))
        end
    end
end

-- ============================================================
-- Show / Toggle
-- ============================================================

function TwitchDropsWatcher.UI:Toggle()
    if not self.frame then
        self.frame = self:Create()
    end
    self:Update()
    self.frame:SetShown(not self.frame:IsShown())
end

function TwitchDropsWatcher.UI:Show()
    if not self.frame then
        self.frame = self:Create()
    end
    self:Update()
    self.frame:Show()
end
