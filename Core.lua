TwitchDropsWatcher = TwitchDropsWatcher or {}

-- Initialize Ace3 addon and more
local addonName = "TwitchDropsWatcher"
local addon = LibStub and LibStub("AceAddon-3.0", true) and LibStub("AceAddon-3.0"):NewAddon(addonName, "AceEvent-3.0")
if not addon then
    print("|cffFF0000TwitchDropsWatcher Error:|r AceAddon-3.0 not found! Addon disabled.")
    return
end

-- Initialize addon
function addon:OnInitialize()
    -- Load saved variables
    TwitchDropsWatcherDB = TwitchDropsWatcherDB or {
        notifyOnLogin = true,
        playSound     = true,
        autoOpenUI    = false,
        collectedDrops = {},
    }
    TwitchDropsWatcherDB.collectedDrops = TwitchDropsWatcherDB.collectedDrops or {}

    -- Update campaign status
    if TwitchDropsWatcher.Data and TwitchDropsWatcher.Data.UpdateCampaignStatus then
        TwitchDropsWatcher.Data:UpdateCampaignStatus()
    else
        print("|cffFF0000TwitchDropsWatcher Error:|r Data module not loaded!")
        return
    end

    -- Create minimap button
    if LibStub and LibStub:GetLibrary("LibDataBroker-1.1", true) then
        self:CreateMinimapButton()
    else
        print("|cffFF0000TwitchDropsWatcher Error:|r LibDataBroker-1.1 not found! Minimap button disabled.")
    end

    -- Register events
    self:RegisterEvent("PLAYER_LOGIN", "OnPlayerLogin")
end

-- Create minimap button
function addon:CreateMinimapButton()
    local ldb = LibStub("LibDataBroker-1.1"):NewDataObject("TwitchDropsWatcher", {
        type = "launcher",
        icon = "Interface\\Icons\\INV_Misc_Bag_10",
        OnClick = function(_, button)
            if button == "LeftButton" then
                TwitchDropsWatcher.UI:Toggle()
            end
        end,
        OnTooltipShow = function(tooltip)
            tooltip:AddLine("Twitch Drops Watcher")
            tooltip:AddLine("Click to view Twitch Drop campaigns.", 1, 1, 1)
        end,
    })

    if LibStub and LibStub:GetLibrary("LibDBIcon-1.0", true) then
        LibStub("LibDBIcon-1.0"):Register("TwitchDropsWatcher", ldb, TwitchDropsWatcherDB)
    else
        print("|cffFF0000TwitchDropsWatcher Error:|r LibDBIcon-1.0 not found! Minimap button disabled.")
    end
end

-- Detect if the player already owns a campaign reward
-- Returns true/false/nil (nil = unable to determine, e.g. data not cached yet)
function TwitchDropsWatcher.CheckOwnership(campaign)
    local itemID = campaign.itemID
    if not itemID then return nil end

    local rType = campaign.rewardType

    if rType == "pet" then
        if not C_PetJournal then return nil end
        -- GetPetInfoByItemID returns speciesID as 13th return value
        local speciesID = select(13, C_PetJournal.GetPetInfoByItemID(itemID))
        if not speciesID then return nil end -- not cached yet, trigger retry
        local numCollected = C_PetJournal.GetNumCollectedInfo(speciesID)
        return numCollected and numCollected > 0

    elseif rType == "toy" then
        return PlayerHasToy and PlayerHasToy(itemID) or nil

    elseif rType == "transmog" or rType == "ensemble" then
        if not C_TransmogCollection then return nil end
        -- For ensembles, the original itemID is consumed on use — check the appearance piece instead
        local checkID = (rType == "ensemble" and campaign.appearanceItemID) or itemID
        local hasTransmog = C_TransmogCollection.PlayerHasTransmog(checkID)
        if hasTransmog == nil then return nil end
        return hasTransmog

    elseif rType == "decor" then
        if not C_TooltipInfo then return nil end
        local tooltipData = C_TooltipInfo.GetItemByID(itemID)
        if not tooltipData then return nil end
        for _, line in ipairs(tooltipData.lines or {}) do
            local text = line.leftText or ""
            if text:find("Owned") or text:find("owned") then
                local count = text:match("(%d+)")
                return count and tonumber(count) > 0
            end
        end
        return false
    end

    return nil
end

-- Auto-detect ownership for all campaigns and update collectedDrops
function TwitchDropsWatcher.AutoDetectOwnership()
    if not TwitchDropsWatcher.Data or not TwitchDropsWatcher.Data.Campaigns then return end

    local detected = 0
    local needsRetry = {}

    for _, campaign in ipairs(TwitchDropsWatcher.Data.Campaigns) do
        if not TwitchDropsWatcherDB.collectedDrops[campaign.name] then
            local owned = TwitchDropsWatcher.CheckOwnership(campaign)
            if owned == true then
                TwitchDropsWatcherDB.collectedDrops[campaign.name] = true
                detected = detected + 1
            elseif owned == nil and campaign.itemID then
                -- Inconclusive — item data not cached yet, queue a retry
                table.insert(needsRetry, campaign)
                if C_Item and C_Item.RequestLoadItemDataByID then
                    C_Item.RequestLoadItemDataByID(campaign.itemID)
                end
            end
        end
    end

    if detected > 0 then
        print(string.format("|cff9146ffTwitch Drops Watcher:|r Auto-detected |cffffd700%d|r owned reward(s) and marked them as collected.", detected))
        TwitchDropsWatcher.UI:Update()
    end

    -- Retry inconclusive items after 3 seconds once item data has had time to cache
    if #needsRetry > 0 then
        C_Timer.After(3, function()
            local retryDetected = 0
            for _, campaign in ipairs(needsRetry) do
                if not TwitchDropsWatcherDB.collectedDrops[campaign.name] then
                    local owned = TwitchDropsWatcher.CheckOwnership(campaign)
                    if owned == true then
                        TwitchDropsWatcherDB.collectedDrops[campaign.name] = true
                        retryDetected = retryDetected + 1
                    end
                end
            end
            if retryDetected > 0 then
                print(string.format("|cff9146ffTwitch Drops Watcher:|r Auto-detected |cffffd700%d|r more owned reward(s) after cache load.", retryDetected))
                TwitchDropsWatcher.UI:Update()
            end
        end)
    end
end

-- On login: auto-detect ownership then check for notifications
function addon:OnPlayerLogin()
    TwitchDropsWatcher.AutoDetectOwnership()
    addon:CheckForActiveCampaigns()
end

function addon:CheckForActiveCampaigns()
    local activeCampaigns = {}
    local uncollectedCampaigns = {}

    if TwitchDropsWatcher.Data and TwitchDropsWatcher.Data.Campaigns then
        for _, campaign in ipairs(TwitchDropsWatcher.Data.Campaigns) do
            if campaign.isActive then
                table.insert(activeCampaigns, campaign)
                if not TwitchDropsWatcherDB.collectedDrops[campaign.name] then
                    table.insert(uncollectedCampaigns, campaign)
                end
            end
        end
    end

    if TwitchDropsWatcherDB.autoOpenUI and #uncollectedCampaigns > 0 then
        C_Timer.After(0, function()
            TwitchDropsWatcher.UI:Show()
        end)
    end

    -- Notifications only for uncollected campaigns
    if TwitchDropsWatcherDB.notifyOnLogin and #uncollectedCampaigns > 0 then
        print("|cff00ff00Twitch Drops Watcher:|r Active Twitch Drop campaigns available!")
        for _, campaign in ipairs(uncollectedCampaigns) do
            print(string.format("|cff00ff00%s:|r %s (%s - %s)", campaign.name, campaign.reward, campaign.startDate, campaign.endDate))
        end
        if TwitchDropsWatcherDB.playSound then
            PlaySound(567429)
        end
    end
end

-- Slash command to open UI
SLASH_TWITCHDROPSWATCHER1 = "/tdw"
SlashCmdList["TWITCHDROPSWATCHER"] = function()
    TwitchDropsWatcher.UI:Toggle()
end

-- Slash command to open settings
SLASH_TWITCHDROPSWATCH2 = "/tdws"
SlashCmdList["TWITCHDROPSWATCH"] = function()
    TwitchDropsWatcher.Settings:Toggle()
end

-- Slash command to manually re-run ownership detection
SLASH_TWITCHDROPSCHECK1 = "/tdwcheck"
SlashCmdList["TWITCHDROPSCHECK"] = function()
    TwitchDropsWatcher.AutoDetectOwnership()
    TwitchDropsWatcher.UI:Update()
    print("|cff9146ffTwitch Drops Watcher:|r Ownership check complete.")
end