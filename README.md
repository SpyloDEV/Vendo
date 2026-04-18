# Vendo

Vendo is a lightweight World of Warcraft addon for vendor automation.

When you open a merchant window, the addon can automatically repair your gear, sell gray items and print a short gold summary to chat. It also keeps simple sold and repair statistics per character.

## Features

- automatic gear repair at vendors
- guild bank repair support when available
- automatic selling of gray items
- stack-aware gold calculation
- optional chat output
- per-character saved settings
- simple session and daily money stats
- in-game options panel

## Slash commands

Vendo works without manual setup. The slash command is only there if you want to toggle features quickly.

```text
/kt on
/kt off
/kt repair
/kt sell
/kt chat
/kt stats
```

## Installation

1. Download or clone the repository.
2. Place the `Vendo` folder inside your WoW `AddOns` directory.
3. Restart the game or reload the UI.
4. Enable the addon in the AddOns menu if needed.

## Files

- `Vendo.lua` main merchant logic and slash commands
- `Vendo_Stats.lua` session and daily money tracking
- `Vendo_Options.lua` interface options panel
- `Vendo.toc` addon metadata

## Notes

- settings are stored per character through `VendoDBPC`
- the current command prefix is `/kt`
- the addon is intentionally small and focused on vendor interactions only

## License

MIT
