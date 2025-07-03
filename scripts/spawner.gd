extends StaticBody3D


@export var ENEMY_TO_SPAWN : PackedScene
@export var TIME_BETWEEN_SPAWNS = 5


var spawn_timer : float


func _ready():
	# random timer offset so they're not all going off on the same frame
	spawn_timer = randf_range(0, TIME_BETWEEN_SPAWNS)


func _process(delta: float) -> void:
	spawn_timer -= delta
	if (spawn_timer <= 0):
		spawn_timer += TIME_BETWEEN_SPAWNS
		spawn_enemy()


func spawn_enemy():
	var new_enemy = ENEMY_TO_SPAWN.instantiate()
	get_tree().root.add_child(new_enemy)
	new_enemy.global_position = global_position
