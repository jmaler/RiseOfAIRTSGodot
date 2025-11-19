extends Node
## GameManager - Singleton for managing global game state

signal game_started
signal game_loaded
signal game_saved

var map_seed: int = 0
var current_scene: String = "menu"
var game_time: float = 0.0

func _ready():
	print("GameManager initialized")

func _process(delta: float):
	if current_scene == "game":
		game_time += delta

func start_new_game():
	# Generate random seed for map
	randomize()
	map_seed = randi()
	game_time = 0.0
	current_scene = "game"
	emit_signal("game_started")
	get_tree().change_scene_to_file("res://scenes/GameScene.tscn")

func load_game(save_data: Dictionary):
	map_seed = save_data.get("map_seed", 0)
	game_time = save_data.get("game_time", 0.0)
	current_scene = "game"
	emit_signal("game_loaded")
	get_tree().change_scene_to_file("res://scenes/GameScene.tscn")

func return_to_menu():
	current_scene = "menu"
	get_tree().change_scene_to_file("res://scenes/MenuScene.tscn")

func quit_game():
	get_tree().quit()
