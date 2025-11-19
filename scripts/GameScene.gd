extends Node2D
## Main game scene

@onready var tilemap: TileMap = $TileMap
@onready var camera: Camera2D = $Camera2D
@onready var units_container: Node2D = $UnitsContainer
@onready var hud: CanvasLayer = $HUD
@onready var selection_box: ColorRect = $SelectionBox

var map_generator: MapGenerator
var unit_manager: Node

# Selection
var is_selecting: bool = false
var selection_start: Vector2 = Vector2.ZERO
var selected_units: Array[BaseUnit] = []

# Grid occupation (one unit per tile)
var grid_occupation: Dictionary = {}  # Vector2i -> BaseUnit

func _ready():
	# Initialize map generator
	map_generator = MapGenerator.new()
	add_child(map_generator)

	# Create unit manager
	unit_manager = Node.new()
	unit_manager.name = "UnitManager"
	add_child(unit_manager)

	# Setup tilemap
	setup_tilemap()

	# Generate map
	var seed_value = GameManager.map_seed
	map_generator.generate_map(tilemap, seed_value)

	# Setup camera
	setup_camera()

	# Add groups
	tilemap.add_to_group("tilemap")
	units_container.add_to_group("units_container")

	# Hide selection box initially
	selection_box.visible = false

	# Load units if loading a saved game
	if GameManager.current_scene == "game":
		load_saved_units()

	print("GameScene ready")

func _process(_delta: float):
	# Update selection box
	if is_selecting:
		update_selection_box()

func _input(event: InputEvent):
	# Camera panning
	if event is InputEventKey:
		handle_camera_keys(event)

	# Mouse input
	if event is InputEventMouseButton:
		handle_mouse_button(event)

	if event is InputEventMouseMotion:
		handle_mouse_motion(event)

func handle_camera_keys(event: InputEventKey):
	var camera_script = camera.get_script()
	# Camera movement handled in CameraController script

func handle_mouse_button(event: InputEventMouseButton):
	var mouse_pos = get_global_mouse_position()

	# Left click - selection
	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# Start selection
			selection_start = mouse_pos
			is_selecting = true

			# Check if clicking on a unit
			var clicked_unit = get_unit_at_position(mouse_pos)
			if clicked_unit and not Input.is_key_pressed(KEY_CTRL):
				deselect_all_units()

		else:  # Released
			if is_selecting:
				finish_selection()
				is_selecting = false
				selection_box.visible = false

	# Right click - move or attack
	elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		handle_right_click(mouse_pos)

	# Mouse wheel - zoom (handled in camera script)

func handle_mouse_motion(event: InputEventMouseMotion):
	if is_selecting:
		update_selection_box()

func update_selection_box():
	var current_mouse = get_global_mouse_position()
	var rect_pos = Vector2(
		min(selection_start.x, current_mouse.x),
		min(selection_start.y, current_mouse.y)
	)
	var rect_size = Vector2(
		abs(current_mouse.x - selection_start.x),
		abs(current_mouse.y - selection_start.y)
	)

	selection_box.global_position = rect_pos
	selection_box.size = rect_size
	selection_box.visible = true

func finish_selection():
	var current_mouse = get_global_mouse_position()
	var selection_rect = Rect2(
		Vector2(min(selection_start.x, current_mouse.x),
				min(selection_start.y, current_mouse.y)),
		Vector2(abs(current_mouse.x - selection_start.x),
				abs(current_mouse.y - selection_start.y))
	)

	# If very small selection, treat as single click
	if selection_rect.size.length() < 10:
		var clicked_unit = get_unit_at_position(selection_start)
		if clicked_unit:
			if not Input.is_key_pressed(KEY_CTRL):
				deselect_all_units()
			select_unit(clicked_unit)
		else:
			if not Input.is_key_pressed(KEY_CTRL):
				deselect_all_units()
	else:
		# Multi-select
		if not Input.is_key_pressed(KEY_CTRL):
			deselect_all_units()

		for unit in get_tree().get_nodes_in_group("units"):
			if selection_rect.has_point(unit.global_position):
				select_unit(unit)

func handle_right_click(mouse_pos: Vector2):
	if selected_units.is_empty():
		return

	# Check if clicking on enemy unit
	var target_unit = get_unit_at_position(mouse_pos)
	if target_unit and target_unit not in selected_units:
		# Attack command
		for unit in selected_units:
			unit.attack_unit(target_unit)
	else:
		# Move command
		for unit in selected_units:
			unit.move_to(mouse_pos)

func get_unit_at_position(pos: Vector2) -> BaseUnit:
	for unit in get_tree().get_nodes_in_group("units"):
		if unit.global_position.distance_to(pos) < 30:
			return unit
	return null

func select_unit(unit: BaseUnit):
	if unit not in selected_units:
		selected_units.append(unit)
		unit.select()

func deselect_all_units():
	for unit in selected_units:
		unit.deselect()
	selected_units.clear()

func spawn_unit(unit_type: String, spawn_pos: Vector2) -> BaseUnit:
	var stats = preload("res://data/unit_stats.gd").get_unit_stats(unit_type)
	if stats.is_empty():
		print("Invalid unit type: ", unit_type)
		return null

	# Check if can afford
	if not ResourceManager.can_afford(stats.cost):
		print("Cannot afford unit: ", unit_type)
		return null

	# Create unit instance
	var unit_scene = preload("res://scenes/units/BaseUnit.tscn")
	var unit: BaseUnit = unit_scene.instantiate()

	# For Worker, set the script to Worker.gd
	if unit_type == "Worker":
		unit.set_script(preload("res://scripts/units/Worker.gd"))

	unit.initialize(unit_type, stats)
	unit.global_position = spawn_pos

	# Deduct resources
	ResourceManager.deduct_resources(stats.cost)

	# Add to scene
	units_container.add_child(unit)

	print("Spawned ", unit_type, " at ", spawn_pos)
	return unit

func setup_tilemap():
	# Tileset is already configured in the scene file
	# Nothing needed here
	pass

func setup_camera():
	camera.position = Vector2(128 * 64 / 2, 128 * 64 / 2)  # Center of map

func load_saved_units():
	# This will be called by SaveManager when loading
	pass

func _on_hud_spawn_unit_requested(unit_type: String):
	# Spawn at camera center
	var spawn_pos = camera.global_position
	spawn_unit(unit_type, spawn_pos)

func _on_hud_behavior_changed(behavior: String):
	for unit in selected_units:
		unit.set_behavior(behavior)

func _on_hud_save_requested():
	SaveManager.save_game()

func _on_hud_menu_requested():
	GameManager.return_to_menu()
