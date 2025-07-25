print("Loading TwitchDropsWatcher UI.lua") -- Debug print to confirm loading

TwitchDropsWatcher = TwitchDropsWatcher or {}
TwitchDropsWatcher.UI = TwitchDropsWatcher.UI or {}

-- Create main frame
function TwitchDropsWatcher.UI:Create()
    local frame = CreateFrame("Frame", "TwitchDropsWatcherFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(500, 400)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()

    -- Title
    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    frame.title:SetPoint("TOP", 0, -5)
    frame.title:SetText("|cff00ff00Twitch Drops Watcher|r")

    -- Scroll frame for campaign list
    local scrollFrame = CreateFrame("ScrollFrame", "TwitchDropsWatcherScroll", frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 10, -40)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)

    local content = CreateFrame("Frame", "TwitchDropsWatcherContent", scrollFrame)
    content:SetSize(460, 350)
    scrollFrame:SetScrollChild(content)

    -- Store content frame for updating
    frame.content = content

    -- Timer for updating countdowns
    frame:SetScript("OnUpdate", function(self, elapsed)
        TwitchDropsWatcher.UI:UpdateTimers(self, elapsed)
    end)

    return frame
end

-- Format time remaining (e.g., "2d 3h 15m")
local function FormatTimeRemaining(seconds)
    if seconds <= 0 then return "|cffff0000Ended|r" end
    local days = floor(seconds / 86400)
    seconds = seconds % 86400
    local hours = floor(seconds / 3600)
    seconds = seconds % 3600
    local minutes = floor(seconds / 60)
    if days > 0 then
        return string.format("%dd %dh %dm", days, hours, minutes)
    elseif hours > 0 then
        return string.format("%dh %dm", hours, minutes)
    else
        return string.format("%dm", minutes)
    end
end

-- Update campaign list
function TwitchDropsWatcher.UI:Update()
    if not self.frame or not self.frame.content then
        self.frame = self:Create()
    end

    local content = self.frame.content

    -- Clear existing buttons
    for _, child in ipairs({content:GetChildren()}) do
        child:Hide()
        child:SetParent(nil)
    end

    -- Filter active campaigns
    local activeCampaigns = {}
    if TwitchDropsWatcher.Data and TwitchDropsWatcher.Data.Campaigns then
        for _, campaign in ipairs(TwitchDropsWatcher.Data.Campaigns) do
            if campaign.isActive then
                table.insert(activeCampaigns, campaign)
            end
        end
    end

    -- Show message if no active campaigns
    if #activeCampaigns == 0 then
        content:SetHeight(70)
        local noCampaignText = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        noCampaignText:SetPoint("TOPLEFT", 10, -10)
        noCampaignText:SetText("No active Twitch Drop campaigns available.")
        return
    end

    -- Populate active campaigns
    local lastButton
    for i, campaign in ipairs(activeCampaigns) do
        local button = CreateFrame("Frame", nil, content)
        button:SetSize(440, 110)
        button:SetPoint("TOPLEFT", 0, -((i-1)*120))

        -- Icon (as a button for Ctrl+Left-Click)
        local iconButton = CreateFrame("Button", nil, button)
        iconButton:SetSize(40, 40)
        iconButton:SetPoint("LEFT", 10, 0)
        local icon = iconButton:CreateTexture(nil, "ARTWORK")
        icon:SetSize(40, 40)
        icon:SetPoint("CENTER")
        icon:SetTexture(campaign.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
        icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        -- Add white square outline
        local border = iconButton:CreateTexture(nil, "BORDER")
        border:SetTexture("Interface\\Buttons\\WHITE8X8")
        border:SetPoint("TOPLEFT", -3, 3) -- Adjusted to move outline further out
        border:SetPoint("BOTTOMRIGHT", 3, -3) -- Adjusted to move outline further out
        border:SetVertexColor(1, 1, 1, 0.8) -- White with slight transparency
        -- Ctrl+Left-Click to open Dressing Room
        if campaign.itemID then
            iconButton:SetScript("OnClick", function(self, clickButton, down)
                if clickButton == "LeftButton" and IsControlKeyDown() then
                    local itemLink = "|Hitem:" .. campaign.itemID .. "|h[" .. campaign.reward .. "]|h"
                    DressUpItemLink(itemLink)
                end
            end)
        end

        -- Indicator for Ctrl+Left-Click
        local clickIndicator = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        clickIndicator:SetPoint("TOPLEFT", iconButton, "TOPRIGHT", 10, -5)
        clickIndicator:SetJustifyH("LEFT")
        clickIndicator:SetTextColor(0.8, 0.8, 0.8)
        clickIndicator:SetText("Ctrl+Click to preview")

        -- Campaign name (prominent)
        local nameText = button:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        nameText:SetPoint("TOPLEFT", iconButton, "TOPRIGHT", 10, -20)
        nameText:SetJustifyH("LEFT")
        nameText:SetWidth(250)
        nameText:SetTextColor(0, 1, 0)
        nameText:SetText(campaign.name)

        -- Reward
        local rewardText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        rewardText:SetPoint("TOPLEFT", nameText, "BOTTOMLEFT", 0, -5)
        rewardText:SetJustifyH("LEFT")
        rewardText:SetWidth(250)
        rewardText:SetText("Reward: " .. campaign.reward)

        -- Requirement (stand out)
        local reqText = button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        reqText:SetPoint("TOPLEFT", rewardText, "BOTTOMLEFT", 0, -5)
        reqText:SetJustifyH("LEFT")
        reqText:SetWidth(250)
        reqText:SetTextColor(1, 0.5, 0)
        reqText:SetText("Req: " .. campaign.requirement)

        -- Countdown timer (stand out)
        local timerText = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
        timerText:SetPoint("TOPRIGHT", -10, -10)
        timerText:SetJustifyH("RIGHT")
        button.timerText = timerText
        button.endTime = TwitchDropsWatcher.Data:ParseDate(campaign.endDate)
        local secondsLeft = button.endTime - time()
        timerText:SetText("Ends in: " .. FormatTimeRemaining(secondsLeft))
        if secondsLeft < 3600 then
            timerText:SetTextColor(1, 0, 0)
        else
            timerText:SetTextColor(1, 1, 0)
        end

        lastButton = button
    end

    content:SetHeight(#activeCampaigns * 120)
end

-- Update countdown timers
function TwitchDropsWatcher.UI:UpdateTimers(frame, elapsed)
    if not frame:IsShown() then return end
    local currentTime = time()
    for _, button in ipairs({frame.content:GetChildren()}) do
        if button.timerText and button.endTime then
            local secondsLeft = button.endTime - currentTime
            button.timerText:SetText("Ends in: " .. FormatTimeRemaining(secondsLeft))
            if secondsLeft < 3600 then
                button.timerText:SetTextColor(1, 0, 0)
            else
                button.timerText:SetTextColor(1, 1, 0)
            end
        end
    end
end

-- Safety check on frame creation
function TwitchDropsWatcher.UI:UpdateTimers(frame, elapsed)
    if not frame:IsShown() or not frame.content then return end
    local currentTime = time()
    for _, button in ipairs({frame.content:GetChildren()}) do
        if button.timerText and button.endTime then
            local secondsLeft = button.endTime - currentTime
            button.timerText:SetText("Ends in: " .. FormatTimeRemaining(secondsLeft))
            if secondsLeft < 3600 then
                button.timerText:SetTextColor(1, 0, 0)
            else
                button.timerText:SetTextColor(1, 1, 0)
            end
        end
    end
end

-- Toggle UI
function TwitchDropsWatcher.UI:Toggle()
    if not self.frame then
        self.frame = self:Create()
    end
    self:Update()
    self.frame:SetShown(not self.frame:IsShown())
end

-- Show UI
function TwitchDropsWatcher.UI:Show()
    if not self.frame then
        self.frame = self:Create()
    end
    self:Update()
    self.frame:Show()
end