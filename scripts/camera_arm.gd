extends Node3D


@export var PLAYER : Node3D
@export var MOUSE_LOOK_VERTICAL_SENSITIVITY = 0.01
@export var MOUSE_LOOK_HORIZONTAL_SENSITIVITY = 0.01
@export var VERTICAL_MIN_ANGLE = -1.0
@export var VERTICAL_MAX_ANGLE = 1.0


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if (event is InputEventMouseMotion):
		var mouse_input = event.relative * Vector2(MOUSE_LOOK_HORIZONTAL_SENSITIVITY, MOUSE_LOOK_VERTICAL_SENSITIVITY)
		PLAYER.rotation.y -= mouse_input.x
		rotation.x -= mouse_input.y
		rotation.x = clamp(rotation.x, VERTICAL_MIN_ANGLE, VERTICAL_MAX_ANGLE)


	# TODO remove harcoded keycode jank
	if (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
