TwitchDropsWatcher = TwitchDropsWatcher or {}

-- Define settings options
TwitchDropsWatcher.options = {
    type = "group",
    name = "Twitch Drops Watcher",
    args = {
        notifyOnLogin = {
            type = "toggle",
            name = "Notify on Login",
            desc = "Show notifications about active campaigns when logging in.",
            get = function() return TwitchDropsWatcherDB.notifyOnLogin end,
            set = function(_, value) TwitchDropsWatcherDB.notifyOnLogin = value end,
        },
        playSound = {
            type = "toggle",
            name = "Play Sound",
            desc = "Play a sound when notifying about active campaigns.",
            get = function() return TwitchDropsWatcherDB.playSound end,
            set = function(_, value) TwitchDropsWatcherDB.playSound = value end,
        },
        autoOpenUI = {
            type = "toggle",
            name = "Auto-Open UI",
            desc = "Automatically open the UI on login if campaigns are active.",
            get = function() return TwitchDropsWatcherDB.autoOpenUI end,
            set = function(_, value) TwitchDropsWatcherDB.autoOpenUI = value end,
        },
    },
}