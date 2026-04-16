TwitchDropsWatcher = TwitchDropsWatcher or {}
TwitchDropsWatcher.Data = TwitchDropsWatcher.Data or {}

-- All dates are in UTC. Use 24-hour format: "YYYY-MM-DD HH:MM"
-- Conversion tip: PDT = UTC-7, PST = UTC-8
-- e.g. 03:00 PDT = 10:00 UTC, 10:00 PST = 18:00 UTC

-- Decor, transmog, ensemble, pet
TwitchDropsWatcher.Data.Campaigns = {
    {
        name = "Patch 12.0.5 - Decor Reward",
        reward = "Cuddly Pearl Grrgle",
        requirement = "Watch 4 hours of WoW streams",
        startDate = "2026-04-23 15:00",
        endDate = "2026-05-21 15:00",
        link = "https://www.twitch.tv/directory/game/World%20of%20Warcraft",
        icon = "7531451",
        itemID = 265394,
        rewardType = "decor",
    },
    {
        name = "Patch 12.0.1 - Decor Reward",
        reward = "Cuddly Void Grrgle",
        requirement = "Watch 4 hours of WoW streams",
        startDate = "2026-03-26 10:00",
        endDate = "2026-04-23 10:00",
        link = "https://www.twitch.tv/directory/game/World%20of%20Warcraft",
        icon = "7537089",
        itemID = 265545,
        rewardType = "decor",
    },
    {
        name = "Patch 12.0.1 - Decor Reward",
        reward = "Cuddly Alliance/Horde Grrgle",
        requirement = "Watch 4 hours of WoW streams",
        startDate = "2026-02-26 18:00",
        endDate = "2026-03-24 16:00",
        link = "https://www.twitch.tv/directory/game/World%20of%20Warcraft",
        icon = "7497419",
        itemID = 263298,
        rewardType = "decor",
    },
    {
        name = "Patch 12.0.0 - Decor Reward",
        reward = "Cuddly Green Grrgle",
        requirement = "Watch 4 hours of WoW streams",
        startDate = "2026-01-20 18:00",
        endDate = "2026-02-17 18:00",
        link = "https://www.twitch.tv/directory/game/World%20of%20Warcraft",
        icon = "7496714",
        itemID = 263301,
        rewardType = "decor",
    },
    {
        name = "Patch 11.2.7 - Transmog Reward",
        reward = "Topsy Turvy Joker's Mask",
        requirement = "Watch 4 hours of WoW streams",
        startDate = "2025-12-02 18:00",
        endDate = "2025-12-30 18:00",
        link = "https://www.twitch.tv/directory/game/World%20of%20Warcraft",
        icon = "6369206",
        itemID = 235343,
        rewardType = "transmog",
    },
    {
        name = "Patch 11.2.5 - Transmog Reward",
        reward = "Violet Sweatsuit",
        requirement = "Watch 4 hours of WoW streams",
        startDate = "2025-11-11 17:00",
        endDate = "2025-12-02 17:00",
        link = "https://www.twitch.tv/directory/game/World%20of%20Warcraft",
        icon = "Interface\\Icons\\inv_shirt_purple_01",
        itemID = 242480,
        rewardType = "ensemble",
        appearanceItemID = 242421, -- Violet Sweatshirt (chest piece from the ensemble)
    },
    {
        name = "Patch 11.2 - Pet Reward",
        reward = "Lil' Coalee",
        requirement = "Watch 4 hours of WoW streams",
        startDate = "2025-10-01 16:00",
        endDate = "2025-10-29 16:00",
        link = "https://www.twitch.tv/directory/game/World%20of%20Warcraft",
        icon = "Interface\\Icons\\inv_pitlordpet_black",
        itemID = 257515,
        rewardType = "pet",
    },
    {
        name = "Patch 11.1.7 - Transmog Reward",
        reward = "Adorned Half Shell",
        requirement = "Watch 4 hours of WoW streams",
        startDate = "2025-07-14 17:00",
        endDate = "2025-08-11 17:00",
        link = "https://www.twitch.tv/directory/game/World%20of%20Warcraft",
        icon = "Interface\\Icons\\inv_cape_special_turtleshell_c_03",
        itemID = 235987,
        rewardType = "transmog",
    },
    {
        name = "11.2 - Pet Reward",
        reward = "Shadefur Brewthief",
        requirement = "Watch 4 hours of WoW streams",
        startDate = "2025-08-05 17:00",
        endDate = "2025-09-02 17:00",
        link = "https://www.twitch.tv/directory/game/World%20of%20Warcraft",
        icon = "Interface\\Icons\\inv_redpandapet_violet",
        itemID = 246451,
        rewardType = "pet",
    },
}

-- Parse UTC date strings ("YYYY-MM-DD HH:MM") to timestamps
function TwitchDropsWatcher.Data:ParseDate(dateStr)
    local year, month, day, hour, minute = dateStr:match("(%d+)-(%d+)-(%d+) (%d+):(%d+)")
    year, month, day, hour, minute = tonumber(year), tonumber(month), tonumber(day), tonumber(hour), tonumber(minute)
    -- time() in WoW uses local time, so we get the UTC offset and compensate
    local localTime = time({year=year, month=month, day=day, hour=hour, min=minute, sec=0})
    local utcOffset = time() - time(date("!*t"))
    return localTime + utcOffset
end

-- Update campaign status based on current time
function TwitchDropsWatcher.Data:UpdateCampaignStatus()
    local currentTime = time()
    for _, campaign in ipairs(self.Campaigns) do
        local startTime = self:ParseDate(campaign.startDate)
        local endTime   = self:ParseDate(campaign.endDate)
        campaign.isActive   = currentTime >= startTime and currentTime <= endTime
        campaign.isUpcoming = currentTime < startTime
        campaign.isExpired  = currentTime > endTime
    end
end