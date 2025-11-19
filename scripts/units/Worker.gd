extends BaseUnit
class_name Worker
## Worker unit that can mine resources

const MINING_RATE = 1.0  # Resources per second

func process_mining(delta: float):
	if mining_target == Vector2i(-1, -1):
		# Find nearest resource
		find_nearest_resource()
		return

	# Move to mining location if not there
	var target_world_pos = grid_to_world(mining_target)
	var distance = global_position.distance_to(target_world_pos)

	if distance > 70:  # Not at resource yet
		move_target = target_world_pos
		process_movement(delta)
		return

	# Mine the resource
	mining_timer += delta
	if mining_timer >= 1.0:
		mine_resource()
		mining_timer = 0.0

func find_nearest_resource():
	var tilemap = get_tree().get_first_node_in_group("tilemap")
	if not tilemap:
		return

	var my_grid_pos = world_to_grid(global_position)
	var search_radius = sight_range

	var nearest_resource = Vector2i(-1, -1)
	var nearest_distance = 999999.0

	# Search nearby tiles for resources
	for x in range(my_grid_pos.x - search_radius, my_grid_pos.x + search_radius):
		for y in range(my_grid_pos.y - search_radius, my_grid_pos.y + search_radius):
			var check_pos = Vector2i(x, y)
			var tile_coords = tilemap.get_cell_atlas_coords(0, check_pos)

			if tile_coords.x == 1 or tile_coords.x == 2 or tile_coords.x == 3:  # Forest, Stone, or Gold
				var distance = Vector2(my_grid_pos).distance_to(Vector2(check_pos))
				if distance < nearest_distance:
					nearest_distance = distance
					nearest_resource = check_pos

	if nearest_resource != Vector2i(-1, -1):
		mining_target = nearest_resource
		print("Worker found resource at: ", mining_target)

func mine_resource():
	var tilemap = get_tree().get_first_node_in_group("tilemap")
	if not tilemap:
		return

	var tile_coords = tilemap.get_cell_atlas_coords(0, mining_target)
	var tile_type = tile_coords.x

	match tile_type:
		1:  # Forest
			ResourceManager.add_resources("wood", int(MINING_RATE))
			print("Mined 1 wood")
		2:  # Stone
			ResourceManager.add_resources("stone", int(MINING_RATE))
			print("Mined 1 stone")
		3:  # Gold
			ResourceManager.add_resources("gold", int(MINING_RATE))
			print("Mined 1 gold (10 coins)")
		_:
			# Resource depleted or changed, find new one
			mining_target = Vector2i(-1, -1)

func world_to_grid(world_pos: Vector2) -> Vector2i:
	return Vector2i(int(world_pos.x / 64), int(world_pos.y / 64))

func grid_to_world(grid_pos: Vector2i) -> Vector2:
	return Vector2(grid_pos.x * 64 + 32, grid_pos.y * 64 + 32)
