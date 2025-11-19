extends CharacterBody2D
class_name BaseUnit
## Base class for all units

signal died(unit)
signal health_changed(current_hp, max_hp)
signal selected_changed(is_selected)

# Unit stats
var unit_type: String = ""
var max_hp: int = 100
var current_hp: int = 100
var damage: int = 10
var shield: int = 0
var sight_range: int = 5
var attack_range: int = 1
var move_speed: int = 100

# State
var is_selected: bool = false
var move_target: Vector2 = Vector2.ZERO
var attack_target: BaseUnit = null
var behavior: String = "defensive"  # aggressive, defensive, passive
var grid_position: Vector2i = Vector2i.ZERO

# Mining (for workers)
var can_mine: bool = false
var mining_target: Vector2i = Vector2i(-1, -1)
var mining_timer: float = 0.0

# Combat
var attack_cooldown: float = 1.0
var attack_timer: float = 0.0

# References
@onready var sprite: Sprite2D = $Sprite2D
@onready var selection_circle: Sprite2D = $SelectionCircle
@onready var health_bar: ProgressBar = $HealthBar
@onready var detection_area: Area2D = $DetectionArea

func _ready():
	add_to_group("units")
	update_selection_visual()
	update_health_bar()

	# Setup detection area
	if detection_area:
		var collision_shape = detection_area.get_node_or_null("CollisionShape2D")
		if collision_shape and collision_shape.shape is CircleShape2D:
			collision_shape.shape.radius = sight_range * 64  # Convert to pixels

func _physics_process(delta: float):
	var game_speed = ResourceManager.game_speed

	# Update attack timer
	if attack_timer > 0:
		attack_timer -= delta * game_speed

	# Handle mining (for workers)
	if can_mine and mining_target != Vector2i(-1, -1):
		process_mining(delta * game_speed)
		return

	# Handle combat
	if attack_target and is_instance_valid(attack_target):
		process_combat(delta * game_speed)
		return

	# Handle movement
	if move_target != Vector2.ZERO:
		process_movement(delta * game_speed)

	# Auto-attack behavior
	if behavior == "aggressive" and attack_target == null:
		find_and_attack_enemies()

func process_movement(delta: float):
	var direction = (move_target - global_position).normalized()
	var distance = global_position.distance_to(move_target)

	if distance < 5:  # Close enough
		move_target = Vector2.ZERO
		velocity = Vector2.ZERO
	else:
		velocity = direction * move_speed
		move_and_slide()

func process_combat(delta: float):
	if not is_instance_valid(attack_target):
		attack_target = null
		return

	var distance = global_position.distance_to(attack_target.global_position)
	var attack_distance = attack_range * 64  # Convert to pixels

	# Move towards target if out of range
	if distance > attack_distance:
		move_target = attack_target.global_position
		process_movement(delta)
	else:
		# Stop and attack
		move_target = Vector2.ZERO
		velocity = Vector2.ZERO

		if attack_timer <= 0:
			perform_attack()

func perform_attack():
	if not is_instance_valid(attack_target):
		attack_target = null
		return

	var damage_dealt = max(1, damage - attack_target.shield)
	attack_target.take_damage(damage_dealt)
	attack_timer = attack_cooldown

	print(unit_type, " attacks for ", damage_dealt, " damage")

func find_and_attack_enemies():
	# Simple enemy detection - find nearest unit
	var nearest_enemy: BaseUnit = null
	var nearest_distance = sight_range * 64

	for unit in get_tree().get_nodes_in_group("units"):
		if unit == self or not is_instance_valid(unit):
			continue

		var distance = global_position.distance_to(unit.global_position)
		if distance < nearest_distance:
			nearest_enemy = unit
			nearest_distance = distance

	if nearest_enemy:
		attack_target = nearest_enemy

func process_mining(delta: float):
	# Implemented in Worker class
	pass

func move_to(target_pos: Vector2):
	move_target = target_pos
	attack_target = null
	mining_target = Vector2i(-1, -1)

func attack_unit(target: BaseUnit):
	if target and is_instance_valid(target):
		attack_target = target
		move_target = Vector2.ZERO
		mining_target = Vector2i(-1, -1)

func set_behavior(new_behavior: String):
	behavior = new_behavior
	print(unit_type, " behavior set to: ", behavior)

func select():
	is_selected = true
	update_selection_visual()
	emit_signal("selected_changed", true)

func deselect():
	is_selected = false
	update_selection_visual()
	emit_signal("selected_changed", false)

func update_selection_visual():
	if selection_circle:
		selection_circle.visible = is_selected

func take_damage(amount: int):
	current_hp -= amount
	current_hp = max(0, current_hp)

	update_health_bar()
	emit_signal("health_changed", current_hp, max_hp)

	if current_hp <= 0:
		die()
	elif behavior == "defensive" and attack_target == null:
		# Fight back when attacked in defensive mode
		var attacker = get_last_attacker()
		if attacker:
			attack_target = attacker

func get_last_attacker() -> BaseUnit:
	# Simplified - would need more complex tracking
	return null

func die():
	print(unit_type, " has died")
	emit_signal("died", self)
	queue_free()

func update_health_bar():
	if health_bar:
		health_bar.max_value = max_hp
		health_bar.value = current_hp

		# Color code health bar
		var health_percent = float(current_hp) / float(max_hp)
		if health_percent > 0.5:
			health_bar.modulate = Color.GREEN
		elif health_percent > 0.25:
			health_bar.modulate = Color.YELLOW
		else:
			health_bar.modulate = Color.RED

func initialize(type: String, stats: Dictionary):
	unit_type = type
	max_hp = stats.get("hp", 100)
	current_hp = max_hp
	damage = stats.get("damage", 10)
	shield = stats.get("shield", 0)
	sight_range = stats.get("sight", 5)
	attack_range = stats.get("range", 1)
	move_speed = stats.get("speed", 100)
	can_mine = stats.get("can_mine", false)

	# Load sprite
	var sprite_path = stats.get("sprite", "")
	if sprite_path and sprite:
		sprite.texture = load(sprite_path)

	update_health_bar()

func get_save_data() -> Dictionary:
	return {
		"type": unit_type,
		"position": global_position,
		"hp": current_hp,
		"behavior": behavior,
		"grid_position": grid_position
	}

func load_save_data(data: Dictionary):
	global_position = data.get("position", Vector2.ZERO)
	current_hp = data.get("hp", max_hp)
	behavior = data.get("behavior", "defensive")
	grid_position = data.get("grid_position", Vector2i.ZERO)
	update_health_bar()
