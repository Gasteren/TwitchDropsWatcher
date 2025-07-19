TwitchDropsWatcher = TwitchDropsWatcher or {}

-- Initialize Ace3 addon
local addonName = "TwitchDropsWatcher"
local addon = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceEvent-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

-- Initialize addon
function addon:OnInitialize()
    -- Load saved variables
    TwitchDropsWatcherDB = TwitchDropsWatcherDB or {
        notifyOnLogin = true,
        playSound = true,
        autoOpenUI = true,
    }

    -- Register settings with AceConfig (only once)
    if not AceConfigDialog.BlizOptions[addonName] then
        AceConfig:RegisterOptionsTable(addonName, TwitchDropsWatcher.options)
        AceConfigDialog:AddToBlizOptions(addonName, "Twitch Drops Watcher")
    end

    -- Update campaign status
    if TwitchDropsWatcher.Data then
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
    end -- should always be found because libdatabroker is stored locally

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

    LibStub("LibDBIcon-1.0"):Register("TwitchDropsWatcher", ldb, TwitchDropsWatcherDB)
end

-- Check for active campaigns and notify
function addon:CheckForActiveCampaigns()
    if not TwitchDropsWatcherDB.notifyOnLogin then return end

    local activeCampaigns = {}
    for _, campaign in ipairs(TwitchDropsWatcher.Data.Campaigns) do
        if campaign.isActive then
            table.insert(activeCampaigns, campaign)
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