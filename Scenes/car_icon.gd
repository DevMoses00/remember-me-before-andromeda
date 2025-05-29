extends Area2D

@onready var sprite = $AnimatedSprite2D

var is_hovered = false
var base_position = Vector2.ZERO
var wiggle_amplitude = 1.5
var wiggle_speed = 4.0
var glow_strength = 0.9 # how much to boost brightness

func _ready():
	base_position = sprite.position
	connect("mouse_entered", _on_mouse_entered)
	connect("mouse_exited", _on_mouse_exited)

func _on_mouse_entered():
	is_hovered = true

func _on_mouse_exited():
	is_hovered = false

func _process(delta):
	var t = Time.get_ticks_msec() / 1000.0

	if is_hovered:
		# Gentle wiggle
		sprite.position = base_position + Vector2(sin(t * wiggle_speed) * wiggle_amplitude, 0)

		# Soft glow using modulate (additive feel)
		sprite.modulate = Color(1.0 + glow_strength, 1.0 + glow_strength, 1.0 + glow_strength)
		
		sprite.rotation = deg_to_rad(sin(t * wiggle_speed) * 5.0)

	else:
		# Return to base state
		sprite.position = sprite.position.lerp(base_position, 5.0 * delta)
		sprite.modulate = sprite.modulate.lerp(Color(1, 1, 1), 5.0 * delta)
