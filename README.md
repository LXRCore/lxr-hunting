# LXR-Hunting

LXR-Hunting is an immersive and dynamic hunting system designed specifically for the LXRCore framework. This system allows players to engage in realistic hunting activities, track animals, harvest resources, and craft items from hunted animals. LXR-Hunting aims to enhance the roleplay experience on RedM servers by offering a highly configurable and interactive gameplay mechanic.

## Features

- **Animal Tracking**: Players can track different animals, follow their footprints, and identify hunting zones.
- **Realistic Hunting**: Includes realistic mechanics such as needing to be stealthy to approach animals and proper tools to take them down.
- **Animal Resources**: Hunted animals can be skinned and harvested for valuable resources such as meat, hides, and special crafting materials.
- **Crafting System Integration**: Allows the use of harvested resources for crafting items such as clothing, weapons, and other useful gear.
- **Job Integration**: Supports job roles like hunters, allowing players to specialize in hunting and selling animal resources.
- **Configurable**: Highly configurable settings for hunting zones, animal types, and rewards.

## Installation

1. **Download the resource**:
   - Clone or download the `lxr-hunting` repository from [GitHub](https://github.com/LXRCore/lxr-hunting).

   ```bash
   git clone https://github.com/LXRCore/lxr-hunting.git
   ```

2. **Add to your server configuration**:
   - Add `lxr-hunting` to your `server.cfg` to ensure it starts when your server launches.

   ```bash
   ensure lxr-hunting
   ```

3. **Configuration**:
   - Open the `config.lua` file in the resource folder to customize hunting settings, animal types, rewards, and more.

4. **Restart your server**:
   - After configuring the hunting system, restart your server to apply the changes.

## Configuration

The `config.lua` file provides various options for customizing the hunting experience:

- **Hunting Zones**: Define specific areas where players can hunt, with the ability to add multiple zones.
- **Animal Types**: Configure which animals can be hunted, the difficulty of tracking them, and the rewards they provide.
- **Rewards**: Set the type of resources that can be harvested from animals and the prices for selling them.
- **Job Permissions**: Integrate with specific job roles such as `hunter` to allow only authorized players to engage in hunting activities.

Example Configuration:

```lua
Config = {}

-- Hunting Zones
Config.HuntingZones = {
    [1] = {
        name = "Big Valley",
        coords = vector3(600, 800, 50),
        radius = 200.0,
        animals = {"deer", "bear", "boar"}
    },
    [2] = {
        name = "Grizzlies",
        coords = vector3(1200, -1000, 100),
        radius = 300.0,
        animals = {"wolf", "elk", "cougar"}
    }
}

-- Animal Rewards
Config.AnimalRewards = {
    deer = {meat = 5, hide = 2},
    bear = {meat = 10, hide = 5},
    boar = {meat = 3, hide = 1},
    wolf = {meat = 2, hide = 1},
    elk = {meat = 8, hide = 3},
    cougar = {meat = 6, hide = 4}
}

-- Job Permissions
Config.AuthorizedJobs = {"hunter", "ranger"}
```

## Keybindings

LXR-Hunting allows for customizable keybindings, allowing players to trigger actions like tracking or harvesting resources. These keybindings can be adjusted in the `config.lua` file.

## Requirements

- **LXRCore**: This script requires the LXRCore framework to function correctly.
- **RedM**: Compatible with RedM servers for enhanced roleplay experiences.

## Future Updates

- **Animal Behavior**: Future updates will introduce more complex animal behavior, including herding and fleeing from hunters.
- **Advanced Crafting**: Integration with an advanced crafting system for more detailed item creation from animal resources.
- **Dynamic Weather Impact**: Animals will react to changing weather conditions, affecting hunting success rates.

## Support

For any issues, feature requests, or contributions, please open an issue or a pull request on the [GitHub repository](https://github.com/LXRCore/lxr-hunting).

Join our [Discord community](https://discord.gg/5DGEv4kK7Q) for further discussions and support on LXR-Hunting and other LXRCore resources.
