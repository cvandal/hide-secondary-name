# Hide Secondary Name

A small WoW Forever addon that hides secondary names on world player nameplates.

It enables names-only friendly player nameplates and displays the main name using the
ordinary overhead-name font, reaction colours and an approximate matching text size.
Party frames, raid frames, chat, NPCs and your own name are unchanged. Existing enemy
player nameplates also display main names; enemy plates are not enabled automatically.

## Install

Unzip `HideSecondaryName-0.1.0.zip` into your WoW Forever AddOns folder:

```
World of Warcraft/_forever_/Interface/AddOns/HideSecondaryName/HideSecondaryName.toc
```

Restart the game and enable **Hide Secondary Name** in the AddOns list. It is enabled
by default, with settings saved per character. Open **Options → AddOns → Hide Secondary
Name** or type `/hsn` to change it.

| Command                   | Action                                |
| ------------------------- | ------------------------------------- |
| `/hsn` or `/hsn settings` | Open settings                         |
| `/hsn on`                 | Enable                                |
| `/hsn off`                | Disable and restore previous settings |
| `/hsn toggle`             | Toggle                                |

`/hidesecondaryname` also works.

## Limitations

This changes nameplates, because ordinary overhead surnames are drawn by the client.
It requests at least 100 yards of player nameplate range, retaining any longer setting.
The game may cap that range: distant players can still show their full names until
their nameplates appear. Friendly plate customization may be restricted in instances.
Text size approximates world names; native perspective scaling differs.

Turning it off restores previous nameplate settings and text styling. Changes requested
during combat wait until combat ends. **Turn it off before disabling or uninstalling the
addon** so it can restore your settings. Disabling an addon in the game's AddOns list
does not run its cleanup code.

## Development and licence

See [CONTRIBUTING.md](CONTRIBUTING.md) for local development, tests and releases.
Licensed under [GPL-3.0](LICENSE). Game art and names belong to Blizzard
Entertainment. This project is not affiliated with Blizzard Entertainment.
