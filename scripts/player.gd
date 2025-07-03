extends CharacterBody3D


@export var CAMERA_ARM : Node3D
@export var SPEED : float
@export var NO_INPUT_SPEED : float
@export var JUMP_VELOCITY : float
@export var INITIAL_GRAVITY_MULTIPLIER : float
@export var FINAL_GRAVITY_MULTIPLIER : float
@export var GRAVITY_CHANGE_RATE : float


var gravity_multiplier


func _physics_process(delta: float) -> void:

	if (is_on_floor() && Input.is_action_just_pressed("jump")):
		velocity.y = JUMP_VELOCITY
		gravity_multiplier = INITIAL_GRAVITY_MULTIPLIER

	if (!is_on_floor()):

		# slowly increase gravity if holding jump button and not already falling
		if (Input.is_action_pressed("jump") && velocity.y > 0):
			gravity_multiplier = move_toward(gravity_multiplier, FINAL_GRAVITY_MULTIPLIER, GRAVITY_CHANGE_RATE)

		# snap to full gravity if released jump button of if already falling
		else:
			gravity_multiplier = FINAL_GRAVITY_MULTIPLIER

		velocity += get_gravity() * gravity_multiplier * delta

	var input_dir := Input.get_vector("moveLeft", "moveRight", "moveUp", "moveDown")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, NO_INPUT_SPEED)
		velocity.z = move_toward(velocity.z, 0, NO_INPUT_SPEED)

	move_and_slide()
