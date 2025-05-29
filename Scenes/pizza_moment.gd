extends Node2D

const SLICE_COUNT = 8
const CENTER_POS = Vector2.ZERO

@onready var slices := [
	$Slice0, $Slice1, $Slice2, $Slice3,
	$Slice4, $Slice5, $Slice6, $Slice7
]

var is_active = false
var directions = []
var speeds = []
var radii = []
var phase_offsets = []
var z_pressed = false
var rotation_speed = 2.0
var connected = false
@onready var connect_burst = $ConnectBurst
var snapped = false


func _ready():
	for i in SLICE_COUNT:
		var slice = slices[i]
		slice.global_position = CENTER_POS

		# Direction based on angle
		var angle = i * TAU / SLICE_COUNT
		directions.append(Vector2(cos(angle), sin(angle)).normalized())

		# Unique lerp speed (between 3 and 7)
		speeds.append(randf_range(3.0, 7.0))

		# Unique max distance (between 120 and 220 px)
		radii.append(randf_range(120.0, 220.0))

		# Random phase offset to desync motion
		phase_offsets.append(randf_range(0.0, TAU))


func _process(delta):
	if not is_active:
		return

	z_pressed = Input.is_action_pressed("swing")

	if z_pressed:
		if not snapped:
			move_slices_to_center(delta)
			rotate_slices(delta)

			if are_slices_connected() and not connected:
				snap_slices()
				connected = true
				connect_burst.global_position = CENTER_POS
				connect_burst.emitting = true
		else:
			rotate_slices(delta)
	else:
		connected = false
		snapped = false
		oscillate_slices(delta)



func move_slices_to_center(delta):
	for i in SLICE_COUNT:
		var slice = slices[i]
		var speed = speeds[i]
		slice.global_position = slice.global_position.lerp(CENTER_POS, speed * delta)


func oscillate_slices(delta):
	var time = Time.get_ticks_msec() / 1000.0
	for i in SLICE_COUNT:
		var slice = slices[i]
		var direction = directions[i]
		var speed = speeds[i]
		var radius = radii[i]
		var phase = phase_offsets[i]

		# Oscillate outward/inward based on sine wave
		var osc = 0.5 + 0.5 * sin(time * 2.0 + phase)  # [0..1] with offset
		var target_pos = CENTER_POS + direction * radius * osc

		slice.global_position = slice.global_position.lerp(target_pos, speed * delta)

func rotate_slices(delta):
	for slice in slices:
		slice.rotate(rotation_speed * delta)

func are_slices_connected(threshold := 12.0) -> bool:
	for slice in slices:
		if slice.global_position.distance_to(CENTER_POS) > threshold:
			return false
	return true

func snap_slices():
	for i in SLICE_COUNT:
		var slice = slices[i]
		slice.global_position = CENTER_POS
		#slice.rotation = 0  # Optional
	snapped = true
	SoundManager.play_sfx("Click")



func activate():
	is_active = true
	visible = true
	set_process(true)

func deactivate():
	is_active = false
	visible = false
	set_process(false)
	
