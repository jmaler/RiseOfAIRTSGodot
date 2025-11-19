extends Camera2D
## Camera controller for pan and zoom

const MIN_ZOOM = 0.3
const MAX_ZOOM = 2.0
const ZOOM_SPEED = 0.1
const PAN_SPEED = 500

# Map bounds (in pixels)
const MAP_SIZE = 128 * 64  # 128 tiles * 64 pixels

var is_panning = false
var pan_start_pos = Vector2.ZERO

func _ready():
	# Set initial zoom
	zoom = Vector2(1.0, 1.0)

	# Limit camera to map bounds
	limit_left = 0
	limit_top = 0
	limit_right = MAP_SIZE
	limit_bottom = MAP_SIZE

func _process(delta: float):
	# Keyboard panning
	var pan_direction = Vector2.ZERO

	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		pan_direction.y -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		pan_direction.y += 1
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		pan_direction.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		pan_direction.x += 1

	if pan_direction != Vector2.ZERO:
		position += pan_direction.normalized() * PAN_SPEED * delta / zoom.x

func _input(event: InputEvent):
	# Mouse wheel zoom
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_camera(1.0 + ZOOM_SPEED)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_camera(1.0 - ZOOM_SPEED)

		# Middle mouse button pan
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				is_panning = true
				pan_start_pos = get_global_mouse_position()
			else:
				is_panning = false

	# Mouse motion for panning
	if event is InputEventMouseMotion and is_panning:
		var current_mouse_pos = get_global_mouse_position()
		var pan_delta = pan_start_pos - current_mouse_pos
		position += pan_delta
		pan_start_pos = get_global_mouse_position()

func zoom_camera(factor: float):
	var new_zoom = zoom * factor
	new_zoom.x = clamp(new_zoom.x, MIN_ZOOM, MAX_ZOOM)
	new_zoom.y = clamp(new_zoom.y, MIN_ZOOM, MAX_ZOOM)
	zoom = new_zoom
