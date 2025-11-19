extends Node
## ResourceManager - Singleton for managing player resources

signal resources_changed(coins, wood, stone)
signal insufficient_resources(required_resources)

var coins: int = 1000
var wood: int = 0
var stone: int = 0
var game_speed: float = 1.0  # 1x, 2x, 3x

var passive_income_timer: float = 0.0
const PASSIVE_INCOME_RATE: float = 1.0  # 1 coin per second

func _ready():
	print("ResourceManager initialized")
	emit_resources_changed()

func _process(delta: float):
	# Passive income (1 coin per second, affected by game speed)
	if GameManager.current_scene == "game":
		passive_income_timer += delta * game_speed
		if passive_income_timer >= 1.0:
			coins += int(passive_income_timer)
			passive_income_timer -= int(passive_income_timer)
			emit_resources_changed()

func can_afford(cost: Dictionary) -> bool:
	var required_coins = cost.get("coins", 0)
	var required_wood = cost.get("wood", 0)
	var required_stone = cost.get("stone", 0)

	return coins >= required_coins and wood >= required_wood and stone >= required_stone

func deduct_resources(cost: Dictionary) -> bool:
	if not can_afford(cost):
		emit_signal("insufficient_resources", cost)
		return false

	coins -= cost.get("coins", 0)
	wood -= cost.get("wood", 0)
	stone -= cost.get("stone", 0)

	emit_resources_changed()
	return true

func add_resources(resource_type: String, amount: int):
	match resource_type:
		"coins":
			coins += amount
		"wood":
			wood += amount
		"stone":
			stone += amount
		"gold":
			# Gold gives coins
			coins += amount * 10  # Gold is worth 10x

	emit_resources_changed()

func set_game_speed(speed: float):
	game_speed = clamp(speed, 1.0, 3.0)
	# Note: We don't use Engine.time_scale because it affects everything including UI
	# We'll manually scale time-dependent operations

func reset_resources():
	coins = 1000
	wood = 0
	stone = 0
	game_speed = 1.0
	passive_income_timer = 0.0
	emit_resources_changed()

func emit_resources_changed():
	emit_signal("resources_changed", coins, wood, stone)

func get_save_data() -> Dictionary:
	return {
		"coins": coins,
		"wood": wood,
		"stone": stone,
		"game_speed": game_speed
	}

func load_save_data(data: Dictionary):
	coins = data.get("coins", 1000)
	wood = data.get("wood", 0)
	stone = data.get("stone", 0)
	game_speed = data.get("game_speed", 1.0)
	emit_resources_changed()
