extends Node2D

#@onready var head = $Head
@onready var trail = $Trail

var velocity = Vector2.ZERO
var margin = 32.0  # Optional buffer zone beyond screen edges

func _ready():
	hide()
	random_trigger()

func _process(delta):
	if visible:
		position += velocity * delta

		var camera = get_viewport().get_camera_2d()
		if camera:
			var view_size = get_viewport_rect().size
			var half_view = view_size * 0.5
			var visible_rect = Rect2(camera.global_position - half_view, view_size)
			var expanded_rect = visible_rect.grow(margin)

			if not expanded_rect.has_point(global_position):
				finish_star()

func random_trigger():
	await get_tree().create_timer(randf_range(3.0, 8.0)).timeout
	spawn_star()

func spawn_star():
	var camera = get_viewport().get_camera_2d()
	if camera == null:
		return

	var view_size = get_viewport_rect().size
	var half_view = view_size * 0.5
	var top_left = camera.global_position - half_view

	# Spawn just off the left/top edge of screen
	var spawn_x = randf_range(top_left.x - 200, top_left.x - 50)
	var spawn_y = randf_range(top_left.y, top_left.y + view_size.y * 0.5)
	global_position = Vector2(spawn_x, spawn_y)

	var angle = deg_to_rad(randf_range(20, 40))  # slight downward arc
	var speed = randf_range(300, 500)
	velocity = Vector2.RIGHT.rotated(angle) * speed

	trail.emitting = true
	#head.modulate = Color(1, 1, 1, 1)
	show()

func finish_star():
	hide()
	trail.emitting = false
	random_trigger()
