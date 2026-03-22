# Twitch Drops Watcher

Tracks active Twitch Drop campaigns directly in-game, no more alt-tabbing to check what's available or whether you've already claimed a reward.

---

## Features

- Live countdown timers per campaign (ends in / starts in)
- Reward details, requirements, and icons per campaign
- Ctrl+Click the reward icon to preview it in the Dressing Room
- **Three tabs** — Active, Completed, and Expired
- **Automatic ownership detection** — on login the addon checks your pets, transmogs, and housing decor and marks any rewards you already own as collected
- **"I have this drop"** checkbox to manually mark rewards as collected
- Collected drops are hidden from Active and no longer trigger notifications
- Expired drops remain visible so you can retroactively mark ones you claimed
- Upcoming campaigns shown in the Active tab with a "Starts In" countdown
- Login notifications with optional sound alert
- Auto-open on login if there are uncollected active campaigns

---

## Commands

| Command | Action |
|---------|--------|
| `/tdw` | Open/close the main window |
| `/tdws` | Open/close settings |
| `/tdwcheck` | Manually re-run ownership detection |

---

## Preview

![Twitch Drops Watcher Preview](https://raw.githubusercontent.com/Gasteren/TwitchDropsWatcher/master/images/main.png)
![Options Menu](https://raw.githubusercontent.com/Gasteren/TwitchDropsWatcher/master/images/options.png)
![Minimap Icon](https://raw.githubusercontent.com/Gasteren/TwitchDropsWatcher/master/images/minimap.png)

---

## Install

Download from [CurseForge](https://www.curseforge.com/wow/addons/twitch-drops-watcher)

## Ownership Detection

On every login the addon automatically checks whether you already own each reward and marks it as collected if you do. This works for pets, transmog appearances, toys, and housing decor.

If a reward isn't being detected correctly, for example if the item data hadn't finished loading when the check ran — use `/tdwcheck` to manually trigger a re-scan at any time. You can also always tick the **"I have this drop"** checkbox on any card yourself.