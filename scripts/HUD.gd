extends CanvasLayer
## HUD - User interface overlay

signal spawn_unit_requested(unit_type)
signal behavior_changed(behavior)
signal save_requested
signal menu_requested

@onready var coins_label = $TopBar/ResourcesContainer/CoinsLabel
@onready var wood_label = $TopBar/ResourcesContainer/WoodLabel
@onready var stone_label = $TopBar/ResourcesContainer/StoneLabel

@onready var worker_button = $BottomPanel/UnitButtons/WorkerButton
@onready var soldier_button = $BottomPanel/UnitButtons/SoldierButton
@onready var knight_button = $BottomPanel/UnitButtons/KnightButton
@onready var mage_button = $BottomPanel/UnitButtons/MageButton
@onready var archer_button = $BottomPanel/UnitButtons/ArcherButton

@onready var speed_1x_button = $TopBar/SpeedButtons/Speed1xButton
@onready var speed_2x_button = $TopBar/SpeedButtons/Speed2xButton
@onready var speed_3x_button = $TopBar/SpeedButtons/Speed3xButton

@onready var save_button = $TopBar/MenuButtons/SaveButton
@onready var menu_button = $TopBar/MenuButtons/MenuButton

@onready var aggressive_button = $BottomPanel/BehaviorButtons/AggressiveButton
@onready var defensive_button = $BottomPanel/BehaviorButtons/DefensiveButton
@onready var passive_button = $BottomPanel/BehaviorButtons/PassiveButton

var unit_stats = preload("res://data/unit_stats.gd")

func _ready():
	# Connect resource updates
	ResourceManager.resources_changed.connect(_on_resources_changed)

	# Connect unit buttons
	worker_button.pressed.connect(func(): spawn_unit("Worker"))
	soldier_button.pressed.connect(func(): spawn_unit("Soldier"))
	knight_button.pressed.connect(func(): spawn_unit("Knight"))
	mage_button.pressed.connect(func(): spawn_unit("Mage"))
	archer_button.pressed.connect(func(): spawn_unit("Archer"))

	# Connect speed buttons
	speed_1x_button.pressed.connect(func(): set_game_speed(1.0))
	speed_2x_button.pressed.connect(func(): set_game_speed(2.0))
	speed_3x_button.pressed.connect(func(): set_game_speed(3.0))

	# Connect behavior buttons
	aggressive_button.pressed.connect(func(): emit_signal("behavior_changed", "aggressive"))
	defensive_button.pressed.connect(func(): emit_signal("behavior_changed", "defensive"))
	passive_button.pressed.connect(func(): emit_signal("behavior_changed", "passive"))

	# Connect menu buttons
	save_button.pressed.connect(func(): emit_signal("save_requested"))
	menu_button.pressed.connect(func(): emit_signal("menu_requested"))

	# Update initial display
	_on_resources_changed(ResourceManager.coins, ResourceManager.wood, ResourceManager.stone)

	# Setup button tooltips
	setup_button_tooltips()

func _on_resources_changed(coins: int, wood: int, stone: int):
	coins_label.text = "Coins: " + str(coins)
	wood_label.text = "Wood: " + str(wood)
	stone_label.text = "Stone: " + str(stone)

	# Update button states based on affordability
	update_button_affordability()

func spawn_unit(unit_type: String):
	emit_signal("spawn_unit_requested", unit_type)

func set_game_speed(speed: float):
	ResourceManager.set_game_speed(speed)
	update_speed_button_states(speed)

func update_speed_button_states(current_speed: float):
	speed_1x_button.button_pressed = (current_speed == 1.0)
	speed_2x_button.button_pressed = (current_speed == 2.0)
	speed_3x_button.button_pressed = (current_speed == 3.0)

func update_button_affordability():
	var buttons = [
		[worker_button, "Worker"],
		[soldier_button, "Soldier"],
		[knight_button, "Knight"],
		[mage_button, "Mage"],
		[archer_button, "Archer"]
	]

	for button_data in buttons:
		var button = button_data[0]
		var unit_type = button_data[1]
		var stats = unit_stats.get_unit_stats(unit_type)
		var can_afford = ResourceManager.can_afford(stats.cost)
		button.disabled = not can_afford

		# Update button color to show affordability
		if can_afford:
			button.modulate = Color.WHITE
		else:
			button.modulate = Color(0.5, 0.5, 0.5)

func setup_button_tooltips():
	# Set tooltips with cost information
	var unit_types = ["Worker", "Soldier", "Knight", "Mage", "Archer"]
	var buttons = [worker_button, soldier_button, knight_button, mage_button, archer_button]

	for i in range(unit_types.size()):
		var stats = unit_stats.get_unit_stats(unit_types[i])
		var cost_text = get_cost_text(stats.cost)
		var tooltip = "%s\n%s\nHP:%d DMG:%d Shield:%d Range:%d" % [
			unit_types[i],
			cost_text,
			stats.hp,
			stats.damage,
			stats.shield,
			stats.range
		]
		buttons[i].tooltip_text = tooltip

func get_cost_text(cost: Dictionary) -> String:
	var parts = []
	if cost.has("coins"):
		parts.append(str(cost.coins) + " coins")
	if cost.has("wood"):
		parts.append(str(cost.wood) + " wood")
	if cost.has("stone"):
		parts.append(str(cost.stone) + " stone")
	return "Cost: " + ", ".join(parts)
