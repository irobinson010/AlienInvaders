# AlienInvaders

`AlienInvaders` is a 2D Godot game about Eli Miller, a farm kid who turns scrap, farm hardware, and alien wreckage into weapons while defending his family's land from an invasion.

The current prototype is a top-down Act 1 defense loop built and validated on Godot 4.6.1 with the Compatibility renderer so it stays on a web-safe path.

## Premise

Alien scouts start landing over Miller Farm.

Eli holds the line with a homemade gun, coil turrets built from salvage, and his dog Patch. Patch is not just a companion. The player chooses how Patch develops:

- `Scrap Hound`: better salvage and stronger scrap economy.
- `Guard Dog`: stun barks and stronger lane control.
- `Scout Nose`: hidden finds, cheaper builds, and upgrades Eli cannot get otherwise.

## Current State

The project currently includes:

- A playable top-down farm defense prototype.
- A 6-wave Act 1 mission flow with story briefings between waves.
- Patch path selection after the first wave, with follow-up upgrades later in the act.
- Placeable coil turrets, unlockable shock posts, alien rushes, salvage collection, fail/restart flow, and an Act 1 completion state.
- Workshop unlocks for Eli's scrap blaster and other between-wave inventions.
- Drill-rig objectives, harrier enemies, and a visible buried field signal in the north-field waves.
- Integrated combat music and positional SFX for Eli, Patch, weapons, and alien events.

## Controls

- `WASD` or arrow keys: move Eli
- Mouse or `Space`: fire
- `Q`: swap Eli's weapon after the scrap blaster is unlocked
- `1`: select the coil turret build
- `2`: select the shock post build after it is unlocked
- Left click on a build pad: place the selected defense
- `R`: restart the run after failure or Act 1 completion

## Project Layout

- `project.godot`: Godot project config
- `scenes/`: main scene and gameplay scenes
- `scripts/`: gameplay logic

## Running Locally

Open the project in Godot 4.6.x or run it directly with the local binary from the parent directory:

```bash
../godot.x86_64 --path .
```

Headless validation:

```bash
XDG_DATA_HOME="$(pwd)/.xdg-data" \
XDG_CONFIG_HOME="$(pwd)/.xdg-config" \
../godot.x86_64 --headless --path . --quit
```

The XDG overrides keep Godot's generated state inside the repo directory instead of writing to a user profile path.

## Web Export Notes

This project is intended to export to HTML5 and be hosted from S3 behind CloudFront.

Current design constraints:

- Keep using Godot's `Compatibility` renderer for the web build path.
- Prefer a non-threaded web export unless we explicitly add cross-origin isolation headers.
- If threaded web export is ever enabled, CloudFront must send `Cross-Origin-Opener-Policy: same-origin` and `Cross-Origin-Embedder-Policy: require-corp`.
- Serve `.wasm` files with `application/wasm`.
- Serve the export as static files, with `index.html` as the default root object.

Current status:

- `export_presets.cfg` now includes a non-threaded `Web` preset.
- The preset is wired to local custom templates under `export_templates/4.6.1.stable/`.
- A release export succeeds with Godot `4.6.1` and writes the site to `build/web/`.

Export command:

```bash
XDG_DATA_HOME="$(pwd)/.xdg-data" \
XDG_CONFIG_HOME="$(pwd)/.xdg-config" \
../godot.x86_64 --headless --path . --export-release Web build/web/index.html
```

The `export_templates/` directory is ignored by git, so another machine will need the same local web templates or a standard Godot export-template install before exporting.

## Next Steps

- Run a browser smoke test against the exported `build/web/` files from a local static server.
- Trim what gets packed into the Web export if the `.pck` grows too quickly.
- Add a second map objective or mid-wave event so late Act 1 waves are not only stronger versions of the same defense shape.
- Build Act 2 around what the aliens are trying to extract from the north field.
