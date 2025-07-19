TwitchDropsWatcher = TwitchDropsWatcher or {}
TwitchDropsWatcher.UI = {}

-- Create main frame
function TwitchDropsWatcher.UI:Create()
    local frame = CreateFrame("Frame", "TwitchDropsWatcherFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(450, 350) -- Increased size for better layout
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()

    -- Title
    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    frame.title:SetPoint("TOP", 0, -4)
    frame.title:SetText("|cff00ff00Twitch Drops Watcher|r")

    -- Scroll frame for campaign list
    local scrollFrame = CreateFrame("ScrollFrame", "TwitchDropsWatcherScroll", frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 10, -40)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)

    local content = CreateFrame("Frame", "TwitchDropsWatcherContent", scrollFrame)
    content:SetSize(410, 300)
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
    for _, campaign in ipairs(TwitchDropsWatcher.Data.Campaigns) do
        if campaign.isActive then
            table.insert(activeCampaigns, campaign)
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
        local button = CreateFrame("Button", nil, content)
        button:SetSize(390, 70)
        button:SetPoint("TOPLEFT", 0, -((i-1)*80))

        -- Highlight for interactivity
        button:SetHighlightTexture("Interface\\Buttons\\UI-Panel-Button-Highlight")
        button:GetHighlightTexture():SetBlendMode("ADD")

        -- Icon
        local icon = button:CreateTexture(nil, "ARTWORK")
        icon:SetSize(40, 40)
        icon:SetPoint("LEFT", 10, 0)
        icon:SetTexture(campaign.icon or "Interface\\Icons\\INV_Misc_QuestionMark") -- Fallback icon

        -- Campaign text
        local text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("LEFT", icon, "RIGHT", 10, 0)
        text:SetJustifyH("LEFT")
        text:SetWidth(200)
        text:SetText(string.format("|cff00ff00%s|r\nReward: %s\n%s",
            campaign.name,
            campaign.reward,
            campaign.requirement))

        -- Countdown timer
        local timerText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        timerText:SetPoint("RIGHT", -10, 0)
        timerText:SetJustifyH("RIGHT")
        button.timerText = timerText
        button.endTime = TwitchDropsWatcher.Data:ParseDate(campaign.endDate)

        -- -- Click to open link - http request do not really work? wow client wont let you click links ingame?
        -- button:SetScript("OnClick", function()
        --     StaticPopupDialogs["TWITCHDROPSWATCHER_LINK"] = {
        --         text = "Open Twitch link for this campaign?",
        --         button1 = "Yes",
        --         button2 = "No",
        --         OnAccept = function() ShowTwitchLink(campaign.link) end,
        --         timeout = 0,
        --         whileDead = true,
        --         hideOnEscape = true
        --     }
        --     StaticPopup_Show("TWITCHDROPSWATCHER_LINK")
        -- end)

        lastButton = button
    end

    content:SetHeight(#activeCampaigns * 80)
end

-- Update countdown timers
function TwitchDropsWatcher.UI:UpdateTimers(frame, elapsed)
    if not frame:IsShown() then return end
    local currentTime = time()
    for _, button in ipairs({frame.content:GetChildren()}) do
        if button.timerText and button.endTime then
            local secondsLeft = button.endTime - currentTime
            button.timerText:SetText("Ends in: " .. FormatTimeRemaining(secondsLeft))
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