extends CanvasLayer

@onready var overlay: Control = $Overlay
@onready var yes_button: Button = $Overlay/PopupContainer/VBoxContainer/ButtonRow/YesButton
@onready var no_button: Button = $Overlay/PopupContainer/VBoxContainer/ButtonRow/NoButton

var _previous_focus: Control = null

func _ready() -> void:
	overlay.hide()
	_setup_button_effects([yes_button, no_button])

func _setup_button_effects(buttons: Array) -> void:
	for btn in buttons:
		btn.focus_entered.connect(func(): _button_grow(btn))
		btn.focus_exited.connect(func(): _button_shrink(btn))
		btn.mouse_entered.connect(func(): _button_grow(btn))
		btn.mouse_exited.connect(func(): _button_shrink(btn))

func _button_grow(btn: Control) -> void:
	btn.pivot_offset = btn.size / 2.0
	create_tween().tween_property(btn, "scale", Vector2(1.1, 1.1), 0.08)

func _button_shrink(btn: Control) -> void:
	create_tween().tween_property(btn, "scale", Vector2(1.0, 1.0), 0.08)

func _input(event: InputEvent) -> void:
	if overlay.visible:
		var is_cancel = event.is_action_pressed("ui_cancel") or \
			(event is InputEventJoypadButton and event.button_index == JOY_BUTTON_B and event.pressed)
		var is_select = event is InputEventJoypadButton and event.button_index == JOY_BUTTON_BACK and event.pressed
		var is_confirm = event is InputEventJoypadButton and event.button_index == JOY_BUTTON_A and event.pressed
		if is_cancel or is_select:
			_dismiss()
			get_viewport().set_input_as_handled()
		elif is_confirm:
			if yes_button.has_focus():
				_on_yes_pressed()
			else:
				_on_no_pressed()
			get_viewport().set_input_as_handled()
	else:
		var is_open = event.is_action_pressed("ui_cancel") or \
			(event is InputEventJoypadButton and event.button_index == JOY_BUTTON_BACK and event.pressed)
		if is_open:
			_show_overlay()
			get_viewport().set_input_as_handled()

func _show_overlay() -> void:
	_previous_focus = get_viewport().gui_get_focus_owner()
	overlay.show()
	no_button.grab_focus()
	get_tree().paused = true

func _dismiss() -> void:
	overlay.hide()
	get_tree().paused = false
	if is_instance_valid(_previous_focus):
		_previous_focus.grab_focus()

func _on_yes_pressed() -> void:
	get_tree().quit()

func _on_no_pressed() -> void:
	_dismiss()
