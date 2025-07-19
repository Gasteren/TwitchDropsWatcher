print("Loading TwitchDropsWatcher Data.lua") -- Debug print to confirm loading

TwitchDropsWatcher = TwitchDropsWatcher or {}
TwitchDropsWatcher.Data = TwitchDropsWatcher.Data or {}

TwitchDropsWatcher.Data.Campaigns = {
    {
        id = 1,
        name = "The War Within Launch - Ghastly Charger",
        reward = "Ghastly Charger Mount",
        startDate = "2024-08-26 15:00 PDT",
        endDate = "2024-09-19 10:00 PDT",
        requirement = "Watch 4 hours of WoW streams",
        isActive = false,
        link = "https://www.twitch.tv/directory/game/World%20of%20Warcraft",
        icon = "Interface\\Icons\\INV_Mount_GhastlyCharger"
    },
    {
        id = 2,
        name = "The War Within Launch - Watcher of the Huntress",
        reward = "Watcher of the Huntress Pet",
        startDate = "2024-08-26 15:00 PDT",
        endDate = "2024-09-26 10:00 PDT",
        requirement = "Gift 2 subscriptions to eligible WoW streamers",
        isActive = false,
        link = "https://www.twitch.tv/directory/game/World%20of%20Warcraft",
        icon = "Interface\\Icons\\INV_Pet_BabyDragon" 
    },
    {
        id = 3,
        name = "Patch 11.1.7 - Adorned Half Shell",
        reward = "Adorned Half Shell Transmog",
        startDate = "2025-07-14 10:00 PDT",
        endDate = "2025-08-11 19:00 CEST",
        requirement = "Watch 4 hours of WoW streams",
        isActive = true,
        link = "https://www.twitch.tv/directory/game/World%20of%20Warcraft",
        icon = "Interface\\Icons\\inv_cape_special_turtleshell_c_03" 
    }
}

-- Function to check if a campaign is active based on current time
function TwitchDropsWatcher.Data:UpdateCampaignStatus()
    local currentTime = time()
    for _, campaign in ipairs(self.Campaigns) do
        local startTime = self:ParseDate(campaign.startDate)
        local endTime = self:ParseDate(campaign.endDate)
        campaign.isActive = currentTime >= startTime and currentTime <= endTime
    end
end

-- Helper function to parse date strings
function TwitchDropsWatcher.Data:ParseDate(dateStr)
    local pattern = "(%d+)-(%d+)-(%d+) (%d+):(%d+) (%w+)"
    local year, month, day, hour, min, zone = dateStr:match(pattern)
    if not year then
        print("|cffFF0000TwitchDropsWatcher Error:|r Invalid date format: " .. dateStr)
        return time()
    end
    local timestamp = time({year = year, month = month, day = day, hour = hour, min = min})
    if zone == "PDT" then
        timestamp = timestamp + 7 * 3600 -- Convert to UTC
    elseif zone == "CEST" then
        timestamp = timestamp - 2 * 3600 -- Convert to UTC
    end
    return timestamp
end