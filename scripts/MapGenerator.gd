extends Node
## MapGenerator - Procedural map generation using noise

const MAP_WIDTH = 128
const MAP_HEIGHT = 128
const TILE_SIZE = 64

# Tile type constants
enum TileType {
	GRASS = 0,
	FOREST = 1,
	STONE = 2,
	GOLD = 3
}

var noise: FastNoiseLite
var current_seed: int = 0

func _ready():
	setup_noise()

func setup_noise():
	noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 0.05

func generate_map(tilemap: TileMap, seed_value: int):
	current_seed = seed_value
	seed(seed_value)
	noise.seed = seed_value

	print("Generating map with seed: ", seed_value)

	# First pass: Base terrain (grass, forest, stone)
	for x in range(MAP_WIDTH):
		for y in range(MAP_HEIGHT):
			var tile_type = determine_tile_type(x, y)
			tilemap.set_cell(0, Vector2i(x, y), 0, Vector2i(tile_type, 0))

	# Second pass: Place gold mines (4 total)
	place_gold_mines(tilemap, 4)

	print("Map generation complete")

func determine_tile_type(x: int, y: int) -> int:
	var noise_value = noise.get_noise_2d(x, y)

	# Map noise values (-1 to 1) to tile types
	# Forest: ~20% (noise > 0.6)
	# Stone: ~10% (noise < -0.8)
	# Grass: rest (~70%)

	if noise_value > 0.6:
		return TileType.FOREST
	elif noise_value < -0.8:
		return TileType.STONE
	else:
		return TileType.GRASS

func place_gold_mines(tilemap: TileMap, count: int):
	var placed = 0
	var attempts = 0
	var max_attempts = 100

	while placed < count and attempts < max_attempts:
		var x = randi() % MAP_WIDTH
		var y = randi() % MAP_HEIGHT

		# Ensure gold mines are spaced apart (at least 20 tiles)
		if is_position_valid_for_gold(tilemap, x, y):
			tilemap.set_cell(0, Vector2i(x, y), 0, Vector2i(TileType.GOLD, 0))
			placed += 1
			print("Placed gold mine at: ", Vector2i(x, y))

		attempts += 1

	if placed < count:
		print("Warning: Only placed ", placed, " gold mines out of ", count)

func is_position_valid_for_gold(tilemap: TileMap, x: int, y: int) -> bool:
	# Check minimum distance from other gold mines
	for check_x in range(MAP_WIDTH):
		for check_y in range(MAP_HEIGHT):
			var tile_data = tilemap.get_cell_atlas_coords(0, Vector2i(check_x, check_y))
			if tile_data.x == TileType.GOLD:
				var distance = Vector2(x - check_x, y - check_y).length()
				if distance < 20:
					return false
	return true

func get_tile_type_at(tilemap: TileMap, grid_pos: Vector2i) -> int:
	var tile_data = tilemap.get_cell_atlas_coords(0, grid_pos)
	return tile_data.x if tile_data else TileType.GRASS

func world_to_grid(world_pos: Vector2) -> Vector2i:
	return Vector2i(
		int(world_pos.x / TILE_SIZE),
		int(world_pos.y / TILE_SIZE)
	)

func grid_to_world(grid_pos: Vector2i) -> Vector2:
	return Vector2(
		grid_pos.x * TILE_SIZE + TILE_SIZE / 2,
		grid_pos.y * TILE_SIZE + TILE_SIZE / 2
	)
