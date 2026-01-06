# Gdmodegame
Project Isola: Ascendance (Godot 4.x)

## Overview
This repository contains a prototype simulation game inspired by the Isola series. It includes:
- Procedural, chunked tilemap generation
- Villagers with AI tasks (gathering, building, events, romance)
- Resource storage and delivery-based construction
- HUD, save/load, and basic progression hooks

## Requirements
- **Godot Engine 4.x** (4.2+ recommended)
- No external dependencies required

## How to Open the Project
1. Install **Godot 4.x** from https://godotengine.org/download.
2. Open Godot and click **Import**.
3. Select the project folder (`/workspace/Gdmodegame` or your cloned path).
4. Godot will load `project.godot` automatically.

## How to Run
1. In Godot, open the project.
2. Press **F5** or click **Play**.
3. The main scene is `scenes/Game.tscn`.

## Controls
- **Left click**: Drag villagers (click and hold), or select villagers/construction sites.
- **Right click**: Place a construction site.
- **Mouse wheel**: Zoom in/out.
- **WASD / Arrow keys**: Move camera.
- **Ctrl+S**: Save game.
- **Ctrl+L**: Load game.

## Gameplay Notes
- Villagers gather food, wood, and stone, deliver resources, and build structures.
- Construction requires **delivered resources** before progress advances.
- Events spawn over time and can reward food.
- Romance can lead to births; traits are inherited with a chance of mutation.
- Objectives and tech unlocks are shown in the HUD.

## Save/Load
Save data is stored at `user://savegame.json` (Godot user data directory).

## Project Structure
- `scenes/` — Godot scenes (main scene: `Game.tscn`)
- `scripts/` — GDScript systems (AI, world, tasks, UI, save/load)
- `project.godot` — Godot project config

## Troubleshooting
- If the project fails to open, confirm you are using **Godot 4.x**.
- If input isn’t responding, click the game window to focus it.

## Credits
- **Kenney assets** (placeholder guidance): https://kenney.nl/assets (CC0)
