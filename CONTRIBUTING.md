# Contributing

Hide Secondary Name targets WoW Forever, interface 16001 (client 1.60.1).

Keep the README current when behavior changes and use small local functions with comments explaining why.

## Local development

Symlink `src` into the game's AddOns folder:

```sh
ln -s "$PWD/src" "/Applications/World of Warcraft/_forever_/Interface/AddOns/HideSecondaryName"
```

Restart the game after installing or changing the TOC. `/reload` picks up Lua changes.

## Layout

```
src/HideSecondaryName.toc  metadata and load order
src/Core.lua               saved variables, lifecycle and slash commands
src/WorldNames.lua         world nameplate updates, styling and CVar restoration
src/Settings.lua           Blizzard AddOns settings panel
tools/world_names_test.lua focused world-name behavior tests
tools/smoke_test.lua       standalone loading and settings checks
tools/package.sh          validated installable ZIP in dist/
.github/workflows/curseforge.yml  version-triggered packaging and publication
```

## Tests and packaging

Requires Lua 5.1 or later, a POSIX shell and zip/unzip:

```sh
lua tools/smoke_test.lua
sh tools/package.sh
```

The ZIP contains only the addon TOC, Lua and licence under `HideSecondaryName/`.
`dist/` is generated and ignored by Git. The build checks matching versions in the TOC
and `HSN.version` in Core.lua before running tests.

Mock tests cover player-only changes, party/raid frame exclusion, own names and NPCs,
secret names, styling, plate recycling, settings restoration across reloads, longer
existing range, combat deferral, and the settings/slash entry points.
In game, check walking toward and away from players, PvP reaction colours, plate recycling,
settings on/off, reloads and instances. The range and text size need live verification.

## Implementation notes

`nameplateShowFriendlyPlayers` and `nameplateShowOnlyNameForFriendlyPlayerUnits` enable
names-only friendly plates. `nameplatePlayerMaxDistance` requests at least 100 yards;
the engine can clamp it. NPC distance is unchanged. Previous CVar values are saved per
character until the feature is disabled, so a reload does not overwrite the baseline.

The `CompactUnitFrame_UpdateName` hook verifies ownership using
`C_NamePlate.GetNamePlateForUnit` before changing player text to the first return from
`UnitName`. Party/raid unit tokens are excluded before that lookup because the client
rejects them, including pet tokens. It uses `UNIT_NAME_FONT`, size 14, a shadow, and extended
`UnitSelectionColor` reaction colours. Styles restore on removal and disabling.
Shared name APIs, party/raid frames and chat are never modified.

`UnitSurnameOwn` exists for native overhead surnames, but no other-player equivalent
was found in the installed client. Distant names are an accepted limitation.

## Releases

Use patch versions for fixes, minor versions for features, and a deliberate 1.0 milestone.
Bump once per release in `src/HideSecondaryName.toc` and `src/Core.lua`.

The reused CurseForge workflow runs on main pushes that change the TOC and publishes
only when its version differs from the previous main revision. Initial pushes skip
publication. For the initial release, push the workflow to main, then choose
**Actions → Publish to CurseForge → Run workflow → main**. Manual runs publish the
current version without comparing a previous revision. Confirm that version is not
already uploaded before using a manual run. Later version bumps publish automatically.
It is restricted to `cvandal/hide-secondary-name`; adjust the repository
guard if hosted elsewhere. It tests, packages and saves the ZIP as a workflow artifact.

Before publication, create a separate CurseForge project and set repository secrets:

- `CF_API_TOKEN`: CurseForge API token.
- `CF_PROJECT_ID`: the numeric ID of the **Hide Secondary Name** project.

The workflow targets game version 1.60.1 and automatic
publication after CurseForge approval. It does not create GitHub releases. For GitHub,
create a `v<version>` release and attach the ZIP from `dist/` or the workflow artifact.
Check CurseForge before rerunning a failed upload, because a response can be lost after
the upload succeeds. Keep tokens out of source control and protect main.
