# Spawn System

This is a modular spawn system following SOLID principles to manage spawning of roads, humans/NPCs, and powerups in the game.

## Architecture

The system follows a hierarchy:

1. `SpawnManager` - Main coordinator that manages all spawner types
2. `ISpawner` - Base interface that all spawners implement
3. Individual spawners:
   - `RoadSpawner` - Handles road segment creation and management
   - `HumanSpawner` - Handles NPC spawning and lifecycle 
   - `PowerupSpawner` - Handles powerup spawning and collection

## Usage

### Adding to a Scene

The easiest way to add the spawn system to your scene is to instance the `SpawnManager` scene:

```gdscript
var spawn_manager = preload("res://src/core/spawners/spawn_manager.tscn").instantiate()
add_child(spawn_manager)

# Configure the manager
spawn_manager.set_player($Player)
spawn_manager.set_camera($Camera)
```

### Configuring Spawners

You can enable/disable individual spawners:

```gdscript
# Enable only road and humans, but no powerups
spawn_manager.set_road_enabled(true)
spawn_manager.set_humans_enabled(true)
spawn_manager.set_powerups_enabled(false)
```

And update parameters for each:

```gdscript
# Configure human spawner
var human_params = {
    "npc_limit": 30,
    "base_speed": 60.0,
    "spawn_chance": 0.8
}
spawn_manager.update_human_parameters(human_params)

# Configure powerup spawner
var powerup_params = {
    "spawn_interval_min": 5.0,
    "spawn_interval_max": 10.0,
    "spawn_chance": 0.4
}
spawn_manager.update_powerup_parameters(powerup_params)
```

### Direct Spawning

For manual spawning:

```gdscript
# Spawn a human at a position
spawn_manager.spawn_human_at(Vector2(500, 300))

# Spawn a random powerup at a position
spawn_manager.spawn_powerup_at(Vector2(400, 200))

# Spawn a specific powerup
var powerup_type = powerup_manager.PowerUpType.SPEED
spawn_manager.spawn_powerup_at(Vector2(400, 200), powerup_type)
```

## Extending

To add a new type of spawner:

1. Create a new class that extends `ISpawner`
2. Implement all the required methods
3. Add references and initialization to `SpawnManager` 