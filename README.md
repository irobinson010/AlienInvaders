# AlienInvaders

`AlienInvaders` is a 2D Godot game about Eli Miller, a farm kid who turns scrap, farm hardware, and alien wreckage into weapons while defending his family's land from an invasion.

The current prototype is a top-down Act 1 defense loop built for Godot 4.5 with the Compatibility renderer so it stays on a web-safe path.

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
- Placeable coil turrets, alien rushes, salvage collection, fail/restart flow, and an Act 1 completion state.

## Controls

- `WASD` or arrow keys: move Eli
- Mouse or `Space`: fire
- Left click on a build pad: place a turret
- `R`: restart the run after failure or Act 1 completion

## Project Layout

- `project.godot`: Godot project config
- `scenes/`: main scene and gameplay scenes
- `scripts/`: gameplay logic

## Running Locally

Open the project in Godot 4.5.x or run it directly with the local binary from the parent directory:

```bash
../Godot_v4.5.1-stable_linux.x86_64 --path .
```

Headless validation:

```bash
XDG_DATA_HOME="$(pwd)/.xdg-data" \
XDG_CONFIG_HOME="$(pwd)/.xdg-config" \
../Godot_v4.5.1-stable_linux.x86_64 --headless --path . --quit
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

## Next Steps

- Add a between-wave upgrade screen for Eli's inventions.
- Extend Act 1 enemy variety and drill-site behavior.
- Build Act 2 around what the aliens are trying to extract from the north field.
- Add and document the final export preset and deployment workflow.
