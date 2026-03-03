```
██╗     ██╗  ██╗██████╗        ██╗  ██╗██╗   ██╗███╗   ██╗████████╗██╗███╗   ██╗ ██████╗
██║     ╚██╗██╔╝██╔══██╗      ██║  ██║██║   ██║████╗  ██║╚══██╔══╝██║████╗  ██║██╔════╝
██║      ╚███╔╝ ██████╔╝█████╗███████║██║   ██║██╔██╗ ██║   ██║   ██║██╔██╗ ██║██║  ███╗
██║      ██╔██╗ ██╔══██╗╚════╝██╔══██║██║   ██║██║╚██╗██║   ██║   ██║██║╚██╗██║██║   ██║
███████╗██╔╝ ██╗██║  ██║      ██║  ██║╚██████╔╝██║ ╚████║   ██║   ██║██║ ╚████║╚██████╔╝
╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝      ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚═╝╚═╝  ╚═══╝ ╚═════╝
```

# 🐺 LXR Hunting — Advanced Hunting System for RedM

> **The Land of Wolves** | [wolves.land](https://www.wolves.land) | [Discord](https://discord.gg/CrKcWdfd3A) | [Store](https://theluxempire.tebex.io)

═══════════════════════════════════════════════════════════════════

**Developer:** iBoss21 / The Lux Empire  
**Website:** https://www.wolves.land  
**Discord:** https://discord.gg/CrKcWdfd3A  
**Store:** https://theluxempire.tebex.io  
**GitHub:** https://github.com/iBoss21  

© 2026 iBoss21 / The Lux Empire | wolves.land | All Rights Reserved

═══════════════════════════════════════════════════════════════════

## Overview

LXR Hunting is an immersive and dynamic hunting system built for RedM, designed in the **Land of Wolves / LXR codebase style**. It allows players to hunt animals, skin carcasses, butcher resources, and sell goods at configurable butcher locations across the map.

## Framework Support

| Framework   | Status              |
|-------------|---------------------|
| LXR-Core    | ✅ Primary           |
| RSG-Core    | ✅ Primary           |
| VORP Core   | ✅ Supported/Legacy  |
| Standalone  | ✅ Fallback          |

Set `Config.Framework = 'auto'` (default) and the resource will detect the active framework automatically, or set it manually to one of: `'lxr-core'`, `'rsg-core'`, `'vorp_core'`, `'standalone'`.

## Features

- **Animal Skinning** — Loot killed animals for pelts, meat, and other resources
- **Carry & Trade** — Carry small animals to the butcher and trade or sell them
- **Inventory Selling** — Sell inventory items (skins, pelts, etc.) at any butcher
- **Butcher NPCs** — Configurable NPC peds at multiple butcher locations across the map
- **Map Blips** — Automatic blips added for all butcher locations
- **Proximity Prompts** — Context-sensitive prompts to interact with butchers
- **Multi-Framework** — Automatic detection of LXR-Core, RSG-Core, VORP Core, or Standalone

## Installation

1. **Download / Clone** the resource:
   ```bash
   git clone https://github.com/LXRCore/lxr-hunting.git
   ```

2. **Place** the `lxr-hunting` folder in your server's `resources` directory.  
   > ⚠️ The resource folder **must** be named `lxr-hunting` exactly — a runtime name check enforces this.

3. **Add to `server.cfg`**:
   ```
   ensure lxr-hunting
   ```

4. **Configure** `config.lua` to your server's needs (items, prices, butcher locations, framework).

5. **Restart** your server.

## Configuration

Open `config.lua` to customize:

- **`Config.Framework`** — Set to `'auto'` or a specific framework name
- **`Config.Items['Inv']`** — Items that can be sold from inventory with their cash value per unit
- **`Config.Items['Pickup']`** — Animal entity models with skin/butcher rewards
- **`Config.Butchers`** — Butcher NPC locations, ped model, and blip sprite

### Example: Adding a New Animal

```lua
[1234567890] = {
    name = 'My Animal',
    skin = {item = 'animal_pelt'},
    butcher = {cash = 5, items = {animal_meat = 2}}
},
```

### Example: Adding a New Butcher Location

```lua
['My Town Butcher'] = vector4(0.0, 0.0, 0.0, 0.0),
```

## Requirements

- **RedM** — Compatible with RedM servers
- **Framework** — LXR-Core, RSG-Core, VORP Core, or Standalone

## Support

- **Discord:** https://discord.gg/CrKcWdfd3A  
- **Issues:** [GitHub Issues](https://github.com/LXRCore/lxr-hunting/issues)  
- **Store:** https://theluxempire.tebex.io
