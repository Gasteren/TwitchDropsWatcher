print("Loading TwitchDropsWatcher Data.lua") -- Debug print to confirm loading

TwitchDropsWatcher = TwitchDropsWatcher or {}
TwitchDropsWatcher.Data = TwitchDropsWatcher.Data or {}

-- Sample campaign data
TwitchDropsWatcher.Data.Campaigns = {
    {
        name = "Patch 11.1.7 - Adorned Half Shell",
        reward = "Adorned Half Shell",
        requirement = "Watch 4 hours of WoW streams",
        startDate = "2025-07-14 17:00 UTC",
        endDate   = "2025-08-11 16:59 UTC",
        link = "https://www.twitch.tv/directory/game/World%20of%20Warcraft",
        icon = "Interface\\Icons\\inv_cape_special_turtleshell_c_03",
        itemID = 235987, -- itemid for ctrl click
        isActive = true,
    },
    {
        name = "Watcher of the Huntress",
        reward = "Watcher of the Huntress",
        requirement = "Watch 2 hours of WoW streams",
        startDate = "2025-06-02 10:00 PDT",
        endDate = "2025-06-30 10:00 PDT",
        link = "https://www.twitch.tv/directory/game/World%20of%20Warcraft",
        icon = "Interface\\Icons\\INV_Misc_QuestionMark",
        itemID = 123457, -- itemid for ctrl click
        isActive = false,
    },
}

-- Parse date strings to timestamps
function TwitchDropsWatcher.Data:ParseDate(dateStr)
    local year, month, day, hour, minute = dateStr:match("(%d+)-(%d+)-(%d+) (%d+):(%d+)")
    year, month, day, hour, minute = tonumber(year), tonumber(month), tonumber(day), tonumber(hour), tonumber(minute)
    local timeTable = {year = year, month = month, day = day, hour = hour, min = minute, sec = 0}
    return time(timeTable)
end

-- Update campaign status based on current time
function TwitchDropsWatcher.Data:UpdateCampaignStatus()
    local currentTime = time()
    for _, campaign in ipairs(self.Campaigns) do
        local startTime = self:ParseDate(campaign.startDate)
        local endTime = self:ParseDate(campaign.endDate)
        campaign.isActive = currentTime >= startTime and currentTime <= endTime
    end
end