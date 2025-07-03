extends Control


@export var REDRAW_INTERVAL : float


var targeting_rects = {}
var primary_target = null
var target_aquisition = 0.0
var target_aquisition_rect = Rect2()
var redraw_timer = 0.0


func _ready() -> void:
	SignalBus.targeting_rects_updated.connect(on_targeting_rects_updated)
	SignalBus.targeting_aquisition_rect_updated.connect(on_targeting_aquisition_rect_updated)


func _exit_tree() -> void:
	SignalBus.targeting_rects_updated.disconnect(on_targeting_rects_updated)
	SignalBus.targeting_aquisition_rect_updated.disconnect(on_targeting_aquisition_rect_updated)


func _process(delta: float) -> void:
	redraw_timer -= delta
	while (redraw_timer < 0):
		redraw_timer += REDRAW_INTERVAL
		queue_redraw()


func _draw():
	# reticle
	var viewport_center = get_viewport().get_visible_rect().get_center()
	draw_circle(viewport_center, 5, Color.YELLOW, true)
	
	# target aquisition area
	draw_rect(target_aquisition_rect, Color.WHITE, false, 1, false)

	# targeting rects
	# TODO parameterize numbers and colors
	for target in targeting_rects.keys():
		var rect = targeting_rects[target]
		var rect_center = rect.get_center()
		var color = Color.WHITE
		var thickness = 1.0
		var length = 10

		# extras for primary target
		if (target == primary_target):
			color = Color.YELLOW
			thickness = 3.0
			length = 30

			# target aquisition X
			var x1 = rect.position.x
			var y1 = rect.position.y
			var x2 = x1 + rect.size.x
			var y2 = y1 + rect.size.y
			draw_line_of_percentage(Vector2(x1, y1), rect_center, target_aquisition, color, thickness)
			draw_line_of_percentage(Vector2(x1, y2), rect_center, target_aquisition, color, thickness)
			draw_line_of_percentage(Vector2(x2, y1), rect_center, target_aquisition, color, thickness)
			draw_line_of_percentage(Vector2(x2, y2), rect_center, target_aquisition, color, thickness)

			# line that points toward target
			#draw_line_of_length(viewport_center, rect_center, length, color, thickness)
			draw_line_of_percentage(viewport_center, rect_center, target_aquisition, color, thickness)

		# targeting rect
		draw_rect(rect, color, false, thickness, false)


# draw line from a to b, constrained to a maximum length
func draw_line_of_length(a: Vector2, b: Vector2, max_length: float, color: Color, thickness: float):
		var difference = b - a
		if (difference.length() > max_length):
			difference = difference.normalized() * max_length
		draw_line(a, a + difference, color, thickness, false)


func draw_line_of_percentage(a: Vector2, b: Vector2, percentage: float, color: Color, thickness: float):
		var difference = b - a
		difference *= percentage
		draw_line(a, a + difference, color, thickness, false)


func on_targeting_rects_updated(rects: Dictionary, primary: CollisionShape3D, aquisition: float):
	targeting_rects = rects
	primary_target = primary
	target_aquisition = aquisition
	
	
func on_targeting_aquisition_rect_updated(rect : Rect2):
	target_aquisition_rect = rect
