extends CharacterBody3D


@export var MODEL : MeshInstance3D


const SPEED = 2
const JUMP_VELOCITY = 8
const BODY_RADIUS = 0.5 # surely this can be detected from the collider but we'll do that later
const SKIN = 0.1 # added to radius (so they can actually find the wall) and removed from height (so they never find the floor)
const WALL_DETECTION_THRESHOLD = 0.7 # 45 degrees
const PARALLEL_DETECTION_THRESHOLD = 0.2 # idk, somewhere above 45 degrees lol


var player = null
var shape_query = PhysicsShapeQueryParameters3D.new()


func _ready():
	# is this jank? I don't know enough about Godot yet, but this feels like jank
	player = get_tree().get_first_node_in_group("Player")

	var shape = CapsuleShape3D.new()
	shape.radius = BODY_RADIUS + SKIN
	shape.height = 2 - SKIN

	shape_query.shape = shape
	shape_query.collision_mask = 128


func _physics_process(delta: float) -> void:
	var direction = direction_to_player()
	add_gravity(delta)
	move(direction)
	jump_if_necessary(direction)


func add_gravity(delta: float):
	if !is_on_floor():
		velocity += get_gravity() * delta


func direction_to_player() -> Vector3:
	var direction = global_position.direction_to(player.global_position)
	return Vector3(direction.x, 0, direction.z).normalized()


func move(direction: Vector3):
	velocity = Vector3(
		direction.x * SPEED,
		velocity.y, # we don't want to override jumping/falling
		direction.z * SPEED
	)
	move_and_slide()
	MODEL.look_at(MODEL.global_position + velocity)


func jump_if_necessary(direction: Vector3):
	# build shape cast
	var space_state = get_world_3d().direct_space_state
	shape_query.transform.origin = global_position
	shape_query.transform.basis = Basis.looking_at(direction, Vector3.UP)
	var shape_cast = space_state.collide_shape(shape_query)

	# check shape cast results
	if (shape_cast && is_on_floor()):
		for i in range(0, shape_cast.size(), 2):

			# we'll jump if we're hitting a wall
			var collision_position = shape_cast[i]
			var normal = shape_cast[i + 1].normalized() # wtf why isn't the normal already normalized lmao

			if (normal.dot(Vector3.UP) < WALL_DETECTION_THRESHOLD):

				# actually we'll only jump if we're not overly parallel with the wall
				var to_collision = (collision_position - global_position)
				to_collision.y = 0
				to_collision = to_collision.normalized()
				var angle_to_collision = direction.dot(to_collision)

				if (abs(angle_to_collision) > PARALLEL_DETECTION_THRESHOLD):

					velocity.y = JUMP_VELOCITY
					break


func _on_target_destroyed() -> void:
	queue_free()
