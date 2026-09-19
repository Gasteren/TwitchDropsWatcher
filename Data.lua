TwitchDropsWatcher = TwitchDropsWatcher or {}
TwitchDropsWatcher.Data = TwitchDropsWatcher.Data or {}

-- All dates are in UTC. Use 24-hour format: "YYYY-MM-DD HH:MM"
-- Conversion tip: PDT = UTC-7, PST = UTC-8
-- e.g. 03:00 PDT = 10:00 UTC, 10:00 PST = 18:00 UTC

-- rewardType: decor, transmog, ensemble, pet, mount, toy
-- ensemble also needs appearanceItemIDs = { id1, id2 } (the pieces it teaches)
--
-- flavors: which clients a campaign applies to — "retail", "forever", "classic".
-- Omit the field entirely to show a campaign on every client.
-- Run /tdwflavor in game to see what the current client reports.
TwitchDropsWatcher.Data.Campaigns = {
    {
        name = "BlizzCon 2026 - Decor Reward",
        reward = "Cuddly Blue Grrgle",
        requirement = "Watch 4 hours of BlizzCon 2026",
        startDate = "2026-09-12 18:30",
        endDate = "2026-09-27 19:00",
        link = "https://www.twitch.tv/directory/game/World%20of%20Warcraft",
        icon = "7497415",
        itemID = 263303,
        rewardType = "decor",
        flavors = { "retail" },
    },
    {
        name = "BlizzCon 2026 - Mount Reward",
        reward = "Fluffy Comfy Flying Quilt",
        requirement = "Watch 8 hours of BlizzCon 2026",
        startDate = "2026-09-12 18:30",
        endDate = "2026-09-27 19:00",
        link = "https://www.twitch.tv/directory/game/World%20of%20Warcraft",
        icon = "Interface\\Icons\\inv_flyingcarpetmount4",
        itemID = 263449,
        rewardType = "mount",
        flavors = { "retail" },
    },
    {
        name = "BlizzCon 2026 - Toy Reward",
        reward = "Venomous Champion's Illustrious Banner",
        requirement = "Watch 12 hours of BlizzCon 2026",
        startDate = "2026-09-12 18:30",
        endDate = "2026-09-27 19:00",
        link = "https://www.twitch.tv/directory/game/World%20of%20Warcraft",
        icon = "Interface\\Icons\\inv_12xp_mdi_awv_banner02",
        itemID = 279590,
        rewardType = "toy",
        flavors = { "retail" },
    },
    {
        name = "Patch 12.1.0 - Transmog Reward",
        reward = "Sorcerer's Grassy Garb",
        requirement = "Watch 4 hours of WoW streams",
        startDate = "2026-08-11 17:00",
        endDate = "2026-09-8 17:00",
        link = "https://www.twitch.tv/directory/game/World%20of%20Warcraft",
        icon = "7291736",
        itemID = 257974,
        rewardType = "ensemble",
        flavors = { "retail" },
        appearanceItemIDs = { 257762, 257782 }, -- Sorcerer's Grassy Cowl & Sorcerer's Grassy Cape
    },
    {
        name = "Patch 12.0.7 - Decor Reward",
        reward = "Cuddly Cotton Candy Grrgle",
        requirement = "Watch 4 hours of WoW streams",
        startDate = "2026-06-16 17:00",
        endDate = "2026-07-14 17:00",
        link = "https://www.twitch.tv/directory/game/World%20of%20Warcraft",
        icon = "7531429",
        itemID = 265389,
        rewardType = "decor",
        flavors = { "retail" },
    },
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
        flavors = { "retail" },
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
        flavors = { "retail" },
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
        flavors = { "retail" },
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
        flavors = { "retail" },
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
        flavors = { "retail" },
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
        flavors = { "retail" },
        appearanceItemIDs = { 242421, 242450 }, -- Violet Sweatshirt (chest), Violet Sweatpants (legs)
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
        flavors = { "retail" },
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
        flavors = { "retail" },
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
        flavors = { "retail" },
    },
}

-- ============================================================
-- Client flavor detection
-- ============================================================
-- Campaigns can declare which clients they apply to via a `flavors` table,
-- e.g. flavors = { "retail" } or flavors = { "retail", "forever" }.
-- A campaign with no `flavors` field is shown on every client.

-- Interface number bands. GetBuildInfo's 4th return is the interface version,
-- e.g. 120100 on retail Midnight, 10601 on WoW Forever.
local FLAVOR_RANGES = {
    { min = 100000, max = 999999, flavor = "retail"  },
    { min =  10500, max =  10999, flavor = "forever" },
    { min =  11000, max =  19999, flavor = "classic" },
}

function TwitchDropsWatcher.Data:GetInterfaceVersion()
    if not GetBuildInfo then return nil end
    local _, _, _, interfaceVersion = GetBuildInfo()
    return tonumber(interfaceVersion)
end

function TwitchDropsWatcher.Data:GetClientFlavor()
    local iv = self:GetInterfaceVersion()
    if not iv then return "unknown", nil end
    for _, range in ipairs(FLAVOR_RANGES) do
        if iv >= range.min and iv <= range.max then
            return range.flavor, iv
        end
    end
    return "unknown", iv
end

-- Does this campaign apply to the client we're running on?
function TwitchDropsWatcher.Data:IsForThisClient(campaign)
    -- No flavors field means "all clients"
    if not campaign.flavors then return true end
    local flavor = self:GetClientFlavor()
    -- On an unrecognised client, show everything rather than an empty list
    if flavor == "unknown" then return true end
    for _, f in ipairs(campaign.flavors) do
        if f == flavor then return true end
    end
    return false
end

-- Campaigns that apply to this client. Use this everywhere instead of
-- iterating Data.Campaigns directly.
function TwitchDropsWatcher.Data:GetCampaigns()
    local list = {}
    for _, campaign in ipairs(self.Campaigns) do
        if self:IsForThisClient(campaign) then
            table.insert(list, campaign)
        end
    end
    return list
end

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