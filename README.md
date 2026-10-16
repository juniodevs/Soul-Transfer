# Soul Transfer

[![Repository](https://img.shields.io/badge/GitHub-juniodevs%2FSoul--Transfer-blue.svg)](https://github.com/juniodevs/Soul-Transfer)
[![Game](https://img.shields.io/badge/Garry's_Mod-Addon-orange.svg)](https://store.steampowered.com/app/4000/Garrys_Mod/)

> Available languages: **English** | [Português (README_PT.md)](README_PT.md)

Open source Garry's Mod addon that lets you possess a nearby NPC when you die.

Instead of going to a black screen or normal respawn, your soul detaches from your corpse in third person. You pick an NPC, dive straight into their body, and keep playing as them with their weapons, current health, model, and bodygroups.

Repository: [https://github.com/juniodevs/Soul-Transfer](https://github.com/juniodevs/Soul-Transfer)

---

## How it works

1. **Death:** You die anywhere on the map with living NPCs around.
2. **Astral View:** The camera pulls out of your ragdoll's head and elevates into third person.
3. **Void & Auras:** The world fades into a dark void. Living NPCs in range show up with glowing red outlines.
4. **Auto-Aim & Slow Motion:** In singleplayer, the game slows down to 0.2x speed, and the camera automatically rotates to face the nearest living soul.
5. **Dive & Possess:** Aim at any NPC and press **Left Click** or **E**. Your soul flies into the target at high speed.
6. **Takeover:** You wake up inside the NPC's body. Lighting snaps back to normal, and you take their model, skin, current HP, weapon, and ammo.

If there are no NPCs in range or the countdown timer ends, you die normally.

---

## Installation

Clone or download this repo into your Garry's Mod addons folder:

```bash
git clone https://github.com/juniodevs/Soul-Transfer.git "garrysmod/addons/Soul Transfer"
```

Or just drop the `Soul Transfer` folder directly into:
`Steam/steamapps/common/GarrysMod/garrysmod/addons/`

---

## Configuration

Open the options menu in-game:
**Spawnmenu (Q) > Utilities > Soul Transfer > Settings**

### Console Commands

| ConVar | Default | Description |
|---|---|---|
| `soultransfer_enabled` | `1` | Enable or disable the addon |
| `soultransfer_range` | `2500` | Max distance to detect NPCs |
| `soultransfer_time_limit` | `8` | Seconds you have to choose a soul |
| `soultransfer_slomo` | `1` | Slow motion during death (singleplayer only) |
| `soultransfer_preserve_health` | `1` | Keep the NPC's remaining health instead of 100 HP |
| `soultransfer_allow_hostiles` | `1` | Allow possessing hostiles (Combine, Zombies, etc.) |
| `soultransfer_transfer_duration`| `0.4` | Duration of the dive flight in seconds |

---

## Compatibility

* Works with default Valve NPCs (Half-Life 2, Combine, Resistance, Zombies).
* Works with NextBots.
* Tested alongside third-person death mods and realism packs.
