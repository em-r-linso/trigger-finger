extends SubViewport


@export var UI_OUTPUT : TextureRect
@export var CLEAR_INTERVAL : float


var clear_timer : float


func _process(delta: float) -> void:
	# TODO listen for window resize instead of doing this every frame
	resize()
	
	# probably a better way to do this but we're going fast n loose in here
	clear_timer -= delta
	if (clear_timer < 0):
		render_target_clear_mode = SubViewport.CLEAR_MODE_ONCE
		clear_timer += CLEAR_INTERVAL
	else:
		render_target_clear_mode = SubViewport.CLEAR_MODE_NEVER


func resize():
	var viewport_size = get_parent().get_viewport().get_visible_rect().size # scuffed maybe to get it from parent lol
	size = viewport_size
	UI_OUTPUT.size = viewport_size
