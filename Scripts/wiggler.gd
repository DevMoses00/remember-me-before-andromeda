extends Node2D  # Or Sprite2D if you're applying directly

@export var wiggle_amplitude := Vector2(1.5, 1.5)
@export var wiggle_speed := 1.5
@export var rotation_wiggle := 2.0

var base_position := Vector2.ZERO
var base_rotation := 0.0

func _ready():
	base_position = position
	base_rotation = rotation

func _process(delta):
	var t = Time.get_ticks_msec() / 1000.0
	var offset = Vector2(
		sin(t * wiggle_speed) * wiggle_amplitude.x,
		sin(t * wiggle_speed * 1.2) * wiggle_amplitude.y
	)
	position = base_position + offset
	rotation = base_rotation + deg_to_rad(sin(t * wiggle_speed * 0.8) * rotation_wiggle)
