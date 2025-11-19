extends Node
## SaveManager - Singleton for handling save/load functionality

const SAVE_PATH = "user://savegame.save"

signal save_completed
signal load_completed
signal save_error(error_message)

func _ready():
	print("SaveManager initialized")

func save_game() -> bool:
	print("Saving game...")

	var save_data = {
		"version": "1.0",
		"timestamp": Time.get_unix_time_from_system(),
		"map_seed": GameManager.map_seed,
		"game_time": GameManager.game_time,
		"resources": ResourceManager.get_save_data(),
		"units": []
	}

	# Get all units in the game
	var units_node = get_tree().get_first_node_in_group("units_container")
	if units_node:
		for unit in units_node.get_children():
			if unit.has_method("get_save_data"):
				save_data.units.append(unit.get_save_data())

	# Save to file
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		var error = FileAccess.get_open_error()
		print("Failed to save game: ", error)
		emit_signal("save_error", "Failed to open save file")
		return false

	var json_string = JSON.stringify(save_data, "\t")
	file.store_string(json_string)
	file.close()

	print("Game saved successfully to: ", SAVE_PATH)
	emit_signal("save_completed")
	return true

func load_game() -> Dictionary:
	print("Loading game...")

	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found")
		emit_signal("save_error", "No save file found")
		return {}

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		var error = FileAccess.get_open_error()
		print("Failed to load game: ", error)
		emit_signal("save_error", "Failed to open save file")
		return {}

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		print("Failed to parse save file")
		emit_signal("save_error", "Save file is corrupted")
		return {}

	var save_data = json.data
	print("Game loaded successfully")
	emit_signal("load_completed")
	return save_data

func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func delete_save_file():
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
		print("Save file deleted")
