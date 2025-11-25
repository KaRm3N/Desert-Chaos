extends Control

@export var level_scene: PackedScene = preload("res://scenes/level_desert_01.tscn")

@onready var start_btn: TextureButton = $Center/StartBtn

func _ready() -> void:
	get_tree().paused = false

	if start_btn and not start_btn.pressed.is_connected(_on_start_pressed):
		start_btn.pressed.connect(_on_start_pressed)

	if start_btn:
		start_btn.focus_mode = Control.FOCUS_ALL
		start_btn.grab_focus()

	if not gui_input.is_connected(_on_gui_input):
		gui_input.connect(_on_gui_input)

func _on_start_pressed() -> void:
	if level_scene:
		get_tree().change_scene_to_packed(level_scene)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and level_scene:
		get_tree().change_scene_to_packed(level_scene)

func _unhandled_input(event: InputEvent) -> void:
	
	if event.is_action_pressed("ui_accept"):
		_on_start_pressed()
		return

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			_on_start_pressed()
			return
