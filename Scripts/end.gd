extends Node2D

var gamepad = false



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SoundManager.fade_in_bgm("BG_Title",2.0,0,-5)

func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouse:
		if gamepad == false: 
			return
		$Restart.release_focus()
		$Exit.release_focus()
		gamepad = false
		
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		if gamepad == false:
			$Restart.grab_focus()
			gamepad = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_restart_pressed() -> void:
	$Restart.hide()
	$Restart.disabled = true
	$Restart.focus_mode = Control.FOCUS_NONE
	$Exit.disabled = true
	$Exit.focus_mode = Control.FOCUS_NONE
	SoundManager.play_sfx("Select")
	await get_tree().create_timer(3.0).timeout
	SoundManager.stop_all()
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://Scenes/main.tscn")


func _on_exit_pressed() -> void:
	$Exit.hide()
	$Restart.disabled = true
	$Restart.focus_mode = Control.FOCUS_NONE
	$Exit.disabled = true
	$Exit.focus_mode = Control.FOCUS_NONE
	SoundManager.play_sfx("Select")
	await get_tree().create_timer(3.0).timeout
	SoundManager.stop_all()
	await get_tree().create_timer(0.3).timeout
	get_tree().quit()
