extends Node2D

@onready var letter = $Letter

var is_active = false
var speed = 800.0
var flee_distance = 320.0
var max_push_distance = 400.0
var squash_scale = 0.2
var stretch_speed = 10.0
var velocity = Vector2.ZERO
var max_velocity = 100.0
var damping = 2  # slows float motion
var bounce_margin = 100.0
var bounce_damp = 0.6  # lose some energy on bounce


func _process(delta):
	if not is_active:
		return

	var mouse_pos = get_viewport().get_camera_2d().get_global_mouse_position()
	var to_mouse = letter.global_position.direction_to(mouse_pos)
	var dist = letter.global_position.distance_to(mouse_pos)

	# Cursor nearby → flee
	if dist < flee_distance:
		var push_strength = clamp(flee_distance - dist, 0.0, max_push_distance)
		velocity -= to_mouse * push_strength * delta
		apply_squash_and_stretch(to_mouse * push_strength, delta)

	## Mouse click → blast away
	#if Input.is_action_just_pressed("click"):
		#velocity += (letter.global_position.direction_to(mouse_pos)) * -max_push_distance * 1.2
		#apply_squash_and_stretch(velocity, delta)

	# Float gently even when idle
	velocity += Vector2(sin(Time.get_ticks_msec() / 400.0), cos(Time.get_ticks_msec() / 600.0)) * 5.0 * delta

	# Clamp and move
	velocity = velocity.limit_length(max_velocity)
	letter.global_position += velocity * delta

	# Bounce off screen edges
	bounce_from_camera_bounds()

	# Dampen over time
	velocity *= damping

	# Settle scale
	letter.scale = letter.scale.lerp(Vector2.ONE, stretch_speed * delta)

func bounce_from_camera_bounds():
	var camera = get_viewport().get_camera_2d()
	var screen_rect = Rect2(camera.global_position - get_viewport_rect().size * 0.5, get_viewport_rect().size)

	var letter_pos = letter.global_position
	var bounced = false

	if letter_pos.x < screen_rect.position.x + bounce_margin:
		letter_pos.x = screen_rect.position.x + bounce_margin
		velocity.x = abs(velocity.x) + randf_range(100.0, 200.0)
		bounced = true
	elif letter_pos.x > screen_rect.end.x - bounce_margin:
		letter_pos.x = screen_rect.end.x - bounce_margin
		velocity.x = -abs(velocity.x) - randf_range(100.0, 200.0)
		bounced = true

	if letter_pos.y < screen_rect.position.y + bounce_margin:
		letter_pos.y = screen_rect.position.y + bounce_margin
		velocity.y = abs(velocity.y) + randf_range(100.0, 200.0)
		bounced = true
	elif letter_pos.y > screen_rect.end.y - bounce_margin:
		letter_pos.y = screen_rect.end.y - bounce_margin
		velocity.y = -abs(velocity.y) - randf_range(100.0, 200.0)
		bounced = true

	if bounced:
		apply_squash_and_stretch(velocity, 1.0)

	letter.global_position = letter_pos


func apply_squash_and_stretch(velocity: Vector2, delta: float):
	var dir = velocity.normalized()
	var speed_mag = velocity.length()

	var stretch = clamp(speed_mag / 100.0, 0.0, 1.0)
	var squash_x = 1.0 - squash_scale * stretch
	var squash_y = 1.0 + squash_scale * stretch

	# Apply based on direction of motion (x/y)
	if abs(dir.x) > abs(dir.y):
		letter.scale = letter.scale.lerp(Vector2(squash_x, squash_y), stretch_speed * delta)
	else:
		letter.scale = letter.scale.lerp(Vector2(squash_y, squash_x), stretch_speed * delta)


func activate():
	is_active = true
	visible = true
	set_process(true)

func deactivate():
	is_active = false
	visible = false
	set_process(false)
