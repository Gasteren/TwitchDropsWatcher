TwitchDropsWatcher = TwitchDropsWatcher or {}

-- Initialize Ace3 addon and more
local addonName = "TwitchDropsWatcher"
local addon = LibStub and LibStub("AceAddon-3.0", true) and LibStub("AceAddon-3.0"):NewAddon(addonName, "AceEvent-3.0")
if not addon then
    print("|cffFF0000TwitchDropsWatcher Error:|r AceAddon-3.0 not found! Addon disabled.")
    return
end

local AceConfig       = nil -- removed, settings now handled natively
local AceConfigDialog = nil -- removed, settings now handled natively

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
    self:RegisterEvent("PLAYER_LOGIN", "CheckForActiveCampaigns")
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

-- Check for active campaigns and notify
function addon:CheckForActiveCampaigns()
    if not TwitchDropsWatcherDB.notifyOnLogin then return end

    local activeCampaigns = {}
    if TwitchDropsWatcher.Data and TwitchDropsWatcher.Data.Campaigns then
        for _, campaign in ipairs(TwitchDropsWatcher.Data.Campaigns) do
            if campaign.isActive and not TwitchDropsWatcherDB.collectedDrops[campaign.name] then
                table.insert(activeCampaigns, campaign)
            end
        end
    end

    if #activeCampaigns > 0 then
        print("|cff00ff00Twitch Drops Watcher:|r Active Twitch Drop campaigns available!")
        for _, campaign in ipairs(activeCampaigns) do
            print(string.format("|cff00ff00%s:|r %s (%s - %s)", campaign.name, campaign.reward, campaign.startDate, campaign.endDate))
        end
        if TwitchDropsWatcherDB.playSound then
            PlaySound(567429) -- Alert sound (e.g., "Raid Warning")
        end
        if TwitchDropsWatcherDB.autoOpenUI then
            TwitchDropsWatcher.UI:Show()
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