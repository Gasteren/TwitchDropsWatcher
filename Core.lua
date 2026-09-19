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

    -- Register events.
    -- Optional collection events vary between game versions, so register them
    -- defensively: an event this client doesn't know is skipped, not fatal.
    self:RegisterEvent("PLAYER_LOGIN",          "OnPlayerLogin")
    -- Also fires on /reload, where PLAYER_LOGIN does not
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnPlayerEnteringWorld")

    local optionalEvents = {
        "PET_JOURNAL_LIST_UPDATE",          -- pets
        "TRANSMOG_COLLECTION_SOURCE_ADDED", -- transmog and ensembles
        "NEW_MOUNT_ADDED",                  -- mounts
        "NEW_TOY_ADDED",                    -- toys
        "TOYS_UPDATED",                     -- toys (older clients)
        "MAIL_INBOX_UPDATE",                -- drops arriving by mail
    }
    for _, event in ipairs(optionalEvents) do
        pcall(function()
            self:RegisterEvent(event, "OnCollectionChanged")
        end)
    end
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
        if not (C_PetJournal and C_PetJournal.GetPetInfoByItemID
                and C_PetJournal.GetNumCollectedInfo) then return nil end
        -- GetPetInfoByItemID returns speciesID as 13th return value
        local speciesID = select(13, C_PetJournal.GetPetInfoByItemID(itemID))
        if not speciesID then return nil end -- not cached yet, trigger retry
        local numCollected = C_PetJournal.GetNumCollectedInfo(speciesID)
        return numCollected and numCollected > 0

    elseif rType == "toy" then
        -- PlayerHasToy may also move into C_ToyBox on newer clients
        local hasToy = _G.PlayerHasToy or (C_ToyBox and C_ToyBox.PlayerHasToy)
        if not hasToy then return nil end
        return hasToy(itemID) and true or false

    elseif rType == "mount" then
        if not (C_MountJournal and C_MountJournal.GetMountFromItem
                and C_MountJournal.GetMountInfoByID) then return nil end
        -- Item teaches a mount; resolve the mountID first
        local mountID = C_MountJournal.GetMountFromItem(itemID)
        if not mountID then return nil end -- not cached yet, trigger retry
        -- isCollected is the 11th return of GetMountInfoByID
        local isCollected = select(11, C_MountJournal.GetMountInfoByID(mountID))
        if isCollected == nil then return nil end
        return isCollected and true or false

    elseif rType == "transmog" or rType == "ensemble" then
        if not (C_TransmogCollection and C_TransmogCollection.PlayerHasTransmog) then return nil end
        -- For ensembles the original itemID is consumed on use — check appearance pieces instead
        -- appearanceItemIDs is a table; any one matching = owned. Single appearanceItemID also supported.
        local checkIDs
        if rType == "ensemble" then
            checkIDs = campaign.appearanceItemIDs
                    or (campaign.appearanceItemID and { campaign.appearanceItemID })
                    or { itemID }
        else
            checkIDs = { itemID }
        end
        for _, checkID in ipairs(checkIDs) do
            local hasTransmog = C_TransmogCollection.PlayerHasTransmog(checkID)
            if hasTransmog == true then return true end
            if hasTransmog == nil then return nil end -- not cached yet, trigger retry
        end
        return false

    elseif rType == "decor" then
        -- Still in bags or bank means owned but not yet placed.
        -- GetItemCount moved into the C_Item namespace; the old global is gone
        -- in newer clients, so resolve whichever this client provides.
        local getCount = (C_Item and C_Item.GetItemCount) or _G.GetItemCount
        local count = getCount and getCount(itemID, true)
        if count and count > 0 then return true end

        -- Once placed in the house chest the item leaves your inventory, but the
        -- tooltip still shows an owned count. Build the match pattern from
        -- Blizzard's own format string so this works in every client locale.
        if not (C_TooltipInfo and C_TooltipInfo.GetItemByID) then return nil end
        local tooltipData = C_TooltipInfo.GetItemByID(itemID)
        if not tooltipData then return nil end

        local pattern
        if _G.HOUSING_DECOR_OWNED_COUNT_FORMAT then
            pattern = _G.HOUSING_DECOR_OWNED_COUNT_FORMAT
                :gsub("([%(%)%[%]%.%+%-%*%?%^%$%%])", "%%%1")
                :gsub("%%d", "(%%d+)")
        end

        for _, line in ipairs(tooltipData.lines or {}) do
            local text = line.leftText or ""
            if pattern then
                local n = text:match(pattern)
                if n and tonumber(n) > 0 then return true end
            end
            -- Fallback for English clients if the global is missing
            if text:find("Owned") or text:find("owned") then
                local n = text:match("(%d+)")
                if n and tonumber(n) > 0 then return true end
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

    for _, campaign in ipairs(TwitchDropsWatcher.Data:GetCampaigns()) do
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
-- The delayed rescan catches items whose data had not cached on the first pass
function addon:OnPlayerLogin()
    TwitchDropsWatcher.AutoDetectOwnership()
    addon:CheckForActiveCampaigns()
    C_Timer.After(10, function()
        TwitchDropsWatcher.AutoDetectOwnership()
    end)
end

-- Fires on /reload as well as login; skip the login case since OnPlayerLogin covers it
function addon:OnPlayerEnteringWorld(isInitialLogin)
    if isInitialLogin then return end
    TwitchDropsWatcher.AutoDetectOwnership()
end

-- A pet, mount, toy, transmog, decor or mail change happened.
-- These events often fire several times in a row, so debounce for 1 second.
local collectionScanPending = false
function addon:OnCollectionChanged()
    if collectionScanPending then return end
    collectionScanPending = true
    C_Timer.After(1, function()
        collectionScanPending = false
        TwitchDropsWatcher.AutoDetectOwnership()
    end)
end

function addon:CheckForActiveCampaigns()
    local activeCampaigns = {}
    local uncollectedCampaigns = {}

    if TwitchDropsWatcher.Data and TwitchDropsWatcher.Data.Campaigns then
        for _, campaign in ipairs(TwitchDropsWatcher.Data:GetCampaigns()) do
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
-- Slash command to report the detected client flavor
SLASH_TWITCHDROPSFLAVOR1 = "/tdwflavor"
SlashCmdList["TWITCHDROPSFLAVOR"] = function()
    local flavor, iv = TwitchDropsWatcher.Data:GetClientFlavor()
    local shown = #TwitchDropsWatcher.Data:GetCampaigns()
    local total = #TwitchDropsWatcher.Data.Campaigns
    print(string.format(
        "|cff9146ffTwitch Drops Watcher:|r client flavor |cffffd700%s|r (interface %s), showing |cffffd700%d|r of %d campaigns.",
        flavor, tostring(iv or "unknown"), shown, total))
end
