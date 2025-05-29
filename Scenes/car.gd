extends Node2D  # Or CharacterBody2D if using physics

@onready var sprite = $AnimatedSprite2D

var is_active = false

var speed = 150.0
var velocity = Vector2.ZERO

var bob_amplitude = 0.03  # How much to squash horizontally
var bob_speed = 35.0      # How fast it pulses
var base_scale = Vector2.ONE  # Original scale of the sprite
var time_accum = 0.0


func _process(delta):
	if not is_active:
		SoundManager.stop("Car")
		return 
	else:
		if SoundManager.is_playing("Car") == false:
			SoundManager.play_sfx("Car",0,-10)
		get_input()
		move_car(delta)
		update_animation()
		time_accum += delta
		apply_engine_bob(delta)
		handle_screen_wrap()

func activate():
	is_active = true
	visible = true
	set_process(true)

func deactivate():
	is_active = false
	visible = false
	set_process(false)

func get_input():
	velocity = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	velocity = velocity.normalized()

func move_car(delta):
	position += velocity * speed * delta  # For Node2D
	# OR use: move_and_slide() if using CharacterBody2D


func update_animation():
	if velocity == Vector2.ZERO:
		sprite.stop()
		return

	# Determine direction name
	var angle = velocity.angle()
	var deg = rad_to_deg(angle)
	var anim = ""

	if deg > -22.5 and deg <= 22.5:
		anim = "right"
	elif deg > 22.5 and deg <= 67.5:
		anim = "down_right"
	elif deg > 67.5 and deg <= 112.5:
		anim = "down"
	elif deg > 112.5 and deg <= 157.5:
		anim = "down_left"
	elif deg > 157.5 or deg <= -157.5:
		anim = "left"
	elif deg > -157.5 and deg <= -112.5:
		anim = "up_left"
	elif deg > -112.5 and deg <= -67.5:
		anim = "up"
	elif deg > -67.5 and deg <= -22.5:
		anim = "up_right"

	# Map to your actual animations and flipping
	match anim:
		"right":
			sprite.animation = "left"
			sprite.flip_h = true
		"down_right":
			sprite.animation = "down_left"
			sprite.flip_h = true
		"down":
			sprite.animation = "down"
			sprite.flip_h = false
		"down_left":
			sprite.animation = "down_left"
			sprite.flip_h = false
		"left":
			sprite.animation = "left"
			sprite.flip_h = false
		"up_left":
			sprite.animation = "up_left"
			sprite.flip_h = false
		"up":
			sprite.animation = "up"
			sprite.flip_h = false
		"up_right":
			sprite.animation = "up_left"
			sprite.flip_h = true

	if not sprite.is_playing():
		sprite.play()

func apply_engine_bob(delta):
	time_accum += delta

	var is_moving = velocity.length() > 0

	var speed = bob_speed
	var amplitude = bob_amplitude

	if not is_moving:
		speed *= 0.5
		amplitude *= 0.4


	var pulse = sin(time_accum * speed) * amplitude
	sprite.scale.x = base_scale.x - pulse
	sprite.scale.y = base_scale.y + pulse

func handle_screen_wrap():
	var screen_size = get_viewport_rect().size
	var margin = 70

	var half_width = screen_size.x * 0.5
	var half_height = screen_size.y * 0.5

	var new_pos = global_position

	if new_pos.x < -half_width - margin:
		new_pos.x = half_width + margin
	elif new_pos.x > half_width + margin:
		new_pos.x = -half_width - margin

	if new_pos.y < -half_height - margin:
		new_pos.y = half_height + margin
	elif new_pos.y > half_height + margin:
		new_pos.y = -half_height - margin

	global_position = new_pos
