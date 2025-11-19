extends Node
## Unit definitions and stats

const UNITS = {
	"Worker": {
		"cost": {"coins": 40, "wood": 20},
		"hp": 50,
		"damage": 5,
		"shield": 0,
		"sight": 4,
		"range": 1,
		"speed": 100,
		"sprite": "res://assets/sprites/units/worker.png",
		"can_mine": true
	},
	"Soldier": {
		"cost": {"coins": 60, "wood": 40},
		"hp": 100,
		"damage": 15,
		"shield": 5,
		"sight": 5,
		"range": 1,
		"speed": 120,
		"sprite": "res://assets/sprites/units/soldier.png",
		"can_mine": false
	},
	"Knight": {
		"cost": {"coins": 80, "stone": 70},
		"hp": 150,
		"damage": 25,
		"shield": 15,
		"sight": 5,
		"range": 1,
		"speed": 90,
		"sprite": "res://assets/sprites/units/knight.png",
		"can_mine": false
	},
	"Mage": {
		"cost": {"coins": 120, "wood": 30},
		"hp": 60,
		"damage": 30,
		"shield": 0,
		"sight": 7,
		"range": 5,
		"speed": 80,
		"sprite": "res://assets/sprites/units/mage.png",
		"can_mine": false
	},
	"Archer": {
		"cost": {"coins": 50, "wood": 50},
		"hp": 70,
		"damage": 20,
		"shield": 0,
		"sight": 6,
		"range": 4,
		"speed": 110,
		"sprite": "res://assets/sprites/units/archer.png",
		"can_mine": false
	}
}

static func get_unit_stats(unit_type: String) -> Dictionary:
	return UNITS.get(unit_type, {})

static func get_all_unit_types() -> Array:
	return UNITS.keys()
