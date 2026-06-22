extends Node2D

@onready var hand = $Hand
@onready var card = $Card
@onready var glow = $Glow
@onready var particles = $FlickParticles

var is_active = false
var flick_ready = true
var flick_charging = false
var flick_started = false

var charge_time = 0.0
var max_charge = 1.5  # seconds
var min_power = 1.0
var max_power = 3.0

func activate():
	is_active = true
	visible = true
	flick_ready = true
	flick_charging = false
	flick_started = false
	card.visible = false
	hand.frame = 0
	hand.stop()
	glow.visible = false
	particles.emitting = false
	set_process(true)

func deactivate():
	is_active = false
	visible = false
	set_process(false)
	hand.stop()
	card.visible = false
	glow.visible = false
	particles.emitting = false
	#tween.kill()

func _process(delta):
	if not is_active:
		return

	var z_held = Input.is_action_pressed("flick")
	var z_released = Input.is_action_just_released("flick")

	# Hold begins
	if z_held and flick_ready and not flick_charging:
		flick_charging = true
		charge_time = 0.0
		glow.visible = true
		hand.frame = 1
		hand.pause()

	# Holding → continue charging
	if flick_charging:
		charge_time = min(charge_time + delta, max_charge)
		#glow.scale = Vector2.ONE * (1.0 + charge_time)  # Optional glow grow effect

	# Release → flick
	if z_released and flick_charging:
		flick_charging = false
		flick_ready = false
		flick_started = true
		glow.visible = false
		hand.play("flick")  # full animation
		var flick = ["Card1","Card2","Card3"].pick_random()
		SoundManager.play_sfx(flick,0,-15)

	# When anim reaches end
	if flick_started and hand.frame == 3 and hand.is_playing():
		flick_started = false
		hand.pause()
		show_and_flick_card()

func show_and_flick_card():
	card.visible = true
	card.global_position = hand.global_position + Vector2(30, 0)
	card.scale = Vector2.ONE
	#particles.global_position = card.global_position
	particles.emitting = true

	# Power = how strong the flick is
	var power = lerp(min_power, max_power, charge_time / max_charge)

	# Flick direction with random offset
	var angle = deg_to_rad(randf_range(-20, 20))
	var direction = Vector2.RIGHT.rotated(angle).normalized()
	var target_pos = card.global_position + direction * power * 300.0
	var shrink_scale = Vector2(0.2, 0.2)

	var tween = create_tween()
	tween.tween_property(card, "global_position", target_pos, 0.4).set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(card, "scale", shrink_scale, 0.4).set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(card, "rotation_degrees", 360, 0.5).as_relative()
	tween.tween_property(card, "modulate:a", 0.0, 0.2)
	await tween.finished
	card.visible = false
	card.modulate.a = 1.0
	flick_ready = true
	hand.stop()
