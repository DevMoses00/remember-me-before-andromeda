extends Node2D

@onready var hand = $Hand
@onready var swing_burst = $Hand/SwingBurst

var is_active : bool = false

var move_speed = 200.0
var swing_in_progress = false

func _ready():
	hand.play("idle")
	hand.frame = 1  # start with straight frame


func _process(delta):
	if not is_active or swing_in_progress:
		return

	var input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	hand.position.x += input * move_speed * delta

	# 🧭 Get screen and hand size
	var screen_width = get_viewport_rect().size.x
	var half_screen = screen_width / 2.0
	var margin = -550  # extra space from screen edge

	var hand_width = hand.sprite_frames.get_frame_texture("idle", hand.frame).get_size().x * hand.scale.x
	var half_hand = hand_width / 2.0

	# ✅ Clamp hand within visible screen + margin
	var min_x = -half_screen + half_hand + margin
	var max_x =  half_screen - half_hand - margin
	hand.global_position.x = clamp(hand.global_position.x, min_x, max_x)

	# 🌀 Change idle frame based on movement
	if input < -0.5:
		hand.frame = 0
	elif input > 0.5:
		hand.frame = 2
	else:
		hand.frame = 1

	# 🎯 Trigger swing
	if Input.is_action_just_pressed("swing"):
		start_swing()



func start_swing():
	swing_in_progress = true
	hand.play("swing")
	await hand.animation_finished
	
	# Emit particles
	#swing_burst.global_position = hand.global_position
	swing_burst.emitting = true
	SoundManager.play_sfx("Bowl")
	
	await get_tree().create_timer(1).timeout  # short pause
	
	hand.play("recover")
	await hand.animation_finished
	
	SoundManager.play_sfx("Strike")
	
	await get_tree().create_timer(1).timeout  # short pause
	hand.play("idle")
	hand.frame = 1 
	swing_in_progress = false

func activate():
	is_active = true
	visible = true
	set_process(true)

func deactivate():
	is_active = false
	visible = false
	set_process(false)
