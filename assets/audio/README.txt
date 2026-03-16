Alien Farm Audio Pack
=====================

Theme:
- Playful spooky sci-fi / retro farm defense
- Built from scratch with procedural synthesis
- Intended as a starter pack you can drop into Godot and tweak

Included music
--------------
1. music_farm_defense_loop.wav / .ogg
   - Main gameplay loop
   - Duration: 30.48 seconds
   - Suggested use: main combat / wave gameplay
   - Suggested loop setting: enable looping in Godot

2. music_wave_warning_sting.wav / .ogg
   - Short alert cue for incoming waves or boss arrivals

Included SFX
------------
Weapons:
- sfx_weapon_laser_pew.wav      : light / fast weapon, laser turret, raygun
- sfx_weapon_heavy_blast.wav    : heavy gun, cannon, explosive hit
- sfx_weapon_rocket_launch.wav  : rocket, missile, artillery launch

Dog:
- sfx_dog_bark_alert.wav        : alert bark when aliens approach
- sfx_dog_growl_guard.wav       : defensive growl / nearby threat

Aliens:
- sfx_alien_chitter_idle.wav    : scout chatter / ambient enemy vocal
- sfx_alien_hurt.wav            : hit reaction
- sfx_alien_death.wav           : death / splat / collapse
- sfx_alien_brute_roar.wav      : large alien warning or boss vocal

Godot tips
----------
- Import music_loop as a streaming track for lower memory use.
- Keep SFX mono if you want easier 3D/2D positional placement.
- Add light pitch randomization (+/- 3% to 6%) to repeated SFX.
- For extra variety, layer alien_chitter with alien_hurt at low volume for stronger reactions.
- The music loop is written to work as a repeating combat bed; if you hear a seam, trim a few ms at the boundary or use a tiny crossfade in the editor.

Created for:
- Alien invasion farm tower defense game