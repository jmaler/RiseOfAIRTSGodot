extends Control
## Main menu scene

@onready var new_game_button = $MarginContainer/VBoxContainer/NewGameButton
@onready var load_game_button = $MarginContainer/VBoxContainer/LoadGameButton
@onready var exit_button = $MarginContainer/VBoxContainer/ExitButton

func _ready():
	# Check if save file exists
	if not SaveManager.has_save_file():
		load_game_button.disabled = true

	# Connect signals
	new_game_button.pressed.connect(_on_new_game_pressed)
	load_game_button.pressed.connect(_on_load_game_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

func _on_new_game_pressed():
	print("Starting new game")
	ResourceManager.reset_resources()
	GameManager.start_new_game()

func _on_load_game_pressed():
	print("Loading game")
	var save_data = SaveManager.load_game()
	if save_data.is_empty():
		print("Failed to load game")
		return

	# Restore game state
	ResourceManager.load_save_data(save_data.get("resources", {}))
	GameManager.load_game(save_data)

func _on_exit_pressed():
	print("Exiting game")
	GameManager.quit_game()
