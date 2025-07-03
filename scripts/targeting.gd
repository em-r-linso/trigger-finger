extends Node3D


@export var CAMERA : Camera3D
@export var PLAYER : Node3D
@export var VIEW_ANGLE : int
@export var TARGET_AQUISITION_TIME : float
@export var TARGET_AQUISITION_AREA : float # percentage of screen space that can be fired at


var rects = {} # okay so we basically don't use the values of this AT ALL because we generate valid_rects
var target_aquisition = 0.0 # percentage 0.0-1.0
var primary_target = null
var target_aquisition_area = Rect2()


func _ready() -> void:
	SignalBus.target_spawned.connect(on_target_spawned)
	SignalBus.target_despawned.connect(on_target_despawned)
	
	get_tree().root.size_changed.connect(on_viewport_resize)
	on_viewport_resize()


func _exit_tree() -> void:
	SignalBus.target_spawned.disconnect(on_target_spawned)
	SignalBus.target_despawned.disconnect(on_target_despawned)


func on_target_spawned(target: CollisionShape3D):
	rects[target] = Rect2()


func on_target_despawned(target: CollisionShape3D):
	rects.erase(target)
	
	
func on_viewport_resize():
	var viewport = get_viewport().get_visible_rect()
	var center = viewport.get_center()
	var w = viewport.size.x * TARGET_AQUISITION_AREA
	var h = viewport.size.y * TARGET_AQUISITION_AREA
	var x = center.x - (w / 2.0)
	var y = center.y - (h / 2.0)
	
	target_aquisition_area = Rect2(x, y, w, h)
	
	print(target_aquisition_area)
	
	SignalBus.targeting_aquisition_rect_updated.emit(target_aquisition_area)


func _process(delta: float) -> void:
	# cull invalid targets
	var valid_rects = cull_invalid_targets(rects)
	
	# sort targets by distance for depth sorting
	var sorted_targets = valid_rects.keys()
	sorted_targets.sort_custom(sort_by_distance_to_player)

	# create rects for valid targets and cull again based on depth
	for target in sorted_targets:
		var rect = get_screen_rect(target)
		if (intersects_drawn_rect(rect, valid_rects)):
			valid_rects.erase(target)
		else:
			valid_rects[target] = rect

	# identify primary target
	var identified_target = null
	if (valid_rects.size() == 0):
		primary_target = null
	else:
		identified_target = identify_primary_target(valid_rects)

	# new target identified!
	if (identified_target != primary_target || identified_target == null):
		primary_target = identified_target
		target_aquisition = 0.0

	# incerment aquisition percentage
	target_aquisition += delta / TARGET_AQUISITION_TIME
	if (target_aquisition > 1.0):
		SignalBus.target_shot_at.emit(primary_target)
		target_aquisition = 0.0

	# send the rects off to be drawn :)
	SignalBus.targeting_rects_updated.emit(valid_rects, primary_target, target_aquisition)

# TODO might be able to mostly replace this with just checking for screen culling
# because we're in 1st person now
func cull_invalid_targets(targets_to_validate: Dictionary):
	var valid_targets = targets_to_validate.duplicate(true) # pretty sure this bitch was passing reference lol
	for target in targets_to_validate:
		if !is_in_front_of_player(target) || !is_in_player_line_of_sight(target):
			valid_targets.erase(target)
	return valid_targets


func sort_by_distance_to_player(a: CollisionShape3D, b: CollisionShape3D):
	var da = a.global_position.distance_to(PLAYER.global_position)
	var db = b.global_position.distance_to(PLAYER.global_position)
	return da < db


# identify which target's rect is closest to the reticle
func identify_primary_target(valid_rects: Dictionary):
	var viewport_center = get_viewport().get_visible_rect().get_center()
	var closest_target = null
	var closest_distance = 99999 # is there a max float value I can get in Godot?
	for target in valid_rects.keys():
		var rect = valid_rects[target]
		var distance = rect.get_center().distance_to(viewport_center)
		if (distance < closest_distance && target_aquisition_area.intersects(rect)):
			closest_target = target
			closest_distance = distance
	return closest_target


func intersects_drawn_rect(rect: Rect2, valid_rects: Dictionary) -> bool:
	for drawn_rect in valid_rects.values():
		if (rect.intersects(drawn_rect)):
			return true
	return false


# screen rect generated from AABB bounding box
# TODO make a more accurate rect generated from actual mesh data or something
func get_screen_rect(target: CollisionShape3D) -> Rect2:
	var bbox = target.shape.get_debug_mesh().get_aabb()
	var corners = []

	for i in range(8):
		var corner = bbox.get_endpoint(i)
		var world_pos = target.to_global(corner)
		if (CAMERA.is_position_behind(world_pos)):
			return Rect2()
		var screen_pos = CAMERA.unproject_position(world_pos)
		corners.append(screen_pos)

	var min_x = corners[0].x
	var max_x = corners[0].x
	var min_y = corners[0].y
	var max_y = corners[0].y
	for corner in corners:
		if corner.x < min_x:
			min_x = corner.x
		if corner.x > max_x:
			max_x = corner.x
		if corner.y < min_y:
			min_y = corner.y
		if corner.y > max_y:
			max_y = corner.y

	return Rect2(min_x, min_y, max_x - min_x, max_y - min_y)


func is_in_front_of_player(target: CollisionShape3D) -> bool:
	var to_target = (target.global_position - PLAYER.global_position).normalized()
	var forward = -PLAYER.global_transform.basis.z.normalized()
	var dot = forward.dot(to_target)
	var threshold = cos(deg_to_rad(VIEW_ANGLE))
	return dot >= threshold


func is_in_player_line_of_sight(target: CollisionShape3D) -> bool:
	var bbox = target.shape.get_debug_mesh().get_aabb()

	for i in range(8):
		var corner = bbox.get_endpoint(i)
		var world_pos = target.to_global(corner)
		var query = PhysicsRayQueryParameters3D.create(PLAYER.global_position, world_pos)
		query.exclude = [PLAYER]
		var collision = get_world_3d().direct_space_state.intersect_ray(query)
		if (!collision || collision.collider == target):
			return  true

	return false
