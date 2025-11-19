# Rise of AI RTS - Phase 1

A 2D real-time strategy game inspired by Dune 2, built with Godot Engine.

## Features Implemented (Phase 1)

### Core Gameplay
- **Procedurally Generated Maps**: 128x128 tile grid (64x64px per tile) with:
  - ~20% forest coverage
  - ~10% stone areas
  - 4 gold mines
  - Seeded random generation for reproducible maps

### Units (5 Types)
All units have unique stats (HP, Damage, Shield, Sight, Range):

| Unit    | Cost           | HP  | DMG | Shield | Sight | Range | Speed |
|---------|----------------|-----|-----|--------|-------|-------|-------|
| Worker  | 40c + 20w      | 50  | 5   | 0      | 4     | 1     | 100   |
| Soldier | 60c + 40w      | 100 | 15  | 5      | 5     | 1     | 120   |
| Knight  | 80c + 70s      | 150 | 25  | 15     | 5     | 1     | 90    |
| Mage    | 120c + 30w     | 60  | 30  | 0      | 7     | 5     | 80    |
| Archer  | 50c + 50w      | 70  | 20  | 0      | 6     | 4     | 110   |

### Resource System
- **Starting Resources**: 1000 coins
- **Passive Income**: +1 coin/second (affected by game speed)
- **Resources**: Coins, Wood, Stone
- **Workers**: Mine resources at 1/second rate
  - Forest → Wood
  - Stone deposits → Stone
  - Gold mines → Coins (10x multiplier)

### Unit Controls
- **Selection**:
  - Left-click: Select single unit
  - Click + drag: Multi-select (selection box)
  - Ctrl+click: Add to selection
- **Movement**: Right-click to move selected units
- **Attack**: Right-click on enemy units (manual attack only)
- **Behaviors**: Aggressive, Defensive, Passive

### Camera Controls
- **Pan**: WASD or Arrow keys, or Middle-mouse drag
- **Zoom**: Mouse wheel (0.3x to 2.0x)
- **Bounds**: Limited to map edges

### Game Speed
- Toggle between 1x, 2x, and 3x speed
- Affects: Passive income, mining, movement, combat

### Menu System
- New Game
- Save Game (to browser localStorage)
- Load Game
- Exit

## Project Structure

```
RiseOfAIRTSGodot/
├── project.godot              # Godot project configuration
├── scenes/
│   ├── Main.tscn             # Entry point
│   ├── MenuScene.tscn        # Main menu
│   ├── GameScene.tscn        # Main gameplay
│   ├── UI/
│   │   └── HUD.tscn          # HUD overlay
│   └── units/
│       └── BaseUnit.tscn     # Base unit template
├── scripts/
│   ├── MenuScene.gd
│   ├── GameScene.gd
│   ├── HUD.gd
│   ├── CameraController.gd
│   ├── MapGenerator.gd
│   ├── autoload/             # Singleton scripts
│   │   ├── GameManager.gd
│   │   ├── ResourceManager.gd
│   │   └── SaveManager.gd
│   └── units/
│       ├── BaseUnit.gd       # Base unit logic
│       └── Worker.gd         # Worker-specific logic
├── data/
│   └── unit_stats.gd         # Unit definitions
└── assets/
    └── sprites/
        ├── units/            # 5 unit sprites
        ├── tiles/            # Tile sprites + atlas
        └── selection_circle.png
```

## How to Run

### Option 1: Godot Editor
1. Download and install [Godot 4.2+](https://godotengine.org/download)
2. Open Godot Project Manager
3. Click "Import" and select this folder
4. Click "Import & Edit"
5. Press F5 to run the game

### Option 2: Export to HTML5
1. Open project in Godot
2. Go to: Project → Export
3. Add HTML5 export template
4. Export project
5. Run on web server or locally

## Controls Summary

| Action           | Control                  |
|------------------|--------------------------|
| Pan Camera       | WASD / Arrow Keys        |
| Pan Camera       | Middle Mouse Drag        |
| Zoom In/Out      | Mouse Wheel              |
| Select Unit      | Left Click               |
| Multi-Select     | Left Click + Drag        |
| Add to Selection | Ctrl + Left Click        |
| Move Units       | Right Click (ground)     |
| Attack           | Right Click (enemy unit) |
| Spawn Unit       | Click unit button in HUD |

## Technical Details

### Technologies
- **Engine**: Godot 4.2
- **Language**: GDScript
- **Save System**: Browser localStorage (HTML5) or user:// folder
- **Map Generation**: FastNoiseLite (Perlin noise)

### Key Design Decisions
- One unit per tile (grid-based positioning)
- No pathfinding (direct movement) - ready for A* in future
- Manual attack only (no auto-attack unless aggressive behavior)
- Time-based systems scale with game speed
- Modular unit system (easy to add more units)

## Future Enhancements (Not in Phase 1)

- Buildings and construction
- Unit production queues
- Fog of war
- Enemy AI
- Multiple factions
- Unit experience/leveling
- Technology tree
- Multiplayer support

## Asset Credits

All sprites are procedurally generated placeholders created for this project. They should be replaced with proper art assets for production use.

## License

This is a prototype project for educational/demonstration purposes.

---

**Version**: Phase 1
**Date**: 2025
**Engine**: Godot 4.2+
