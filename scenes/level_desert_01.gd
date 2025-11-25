extends Node2D

const GOAL := 10
var score: int = 0
var rng := RandomNumberGenerator.new()

var current_gold: Node = null
var current_scorpion: Node = null
var current_snake: Node = null
var current_crab: Node = null
var _awaiting_gold_spawn: bool = false

@onready var score_label: Label = $UI_Layer/ScoreLabel
@onready var hp_label: Label    = $UI_Layer/HPLabel
@onready var hearts_hud         = $UI_Layer/Hearts

@onready var blur_rect: ColorRect          = $UI_Layer/BlurRect
@onready var win_overlay: Control          = $UI_Layer/WinOverlay
@onready var play_again_btn: TextureButton = $UI_Layer/WinOverlay/PlayAgainBtn
@onready var lose_overlay: Control         = $UI_Layer/GameOverOverlay
@onready var retry_btn: TextureButton      = $UI_Layer/GameOverOverlay/RetryBtn

@onready var gold_scene:     PackedScene = preload("res://scenes/Gold.tscn")
@onready var scorpion_scene: PackedScene = preload("res://scenes/Scorpion.tscn")
@onready var snake_scene:    PackedScene = preload("res://scenes/Snake.tscn")
@onready var crab_scene:     PackedScene = preload("res://scenes/Crab.tscn")

const VIEW_W := 1280
const VIEW_H := 720
const MARGIN_X := 48
const MARGIN_Y := 48

const OBSTACLE_LAYER_BIT := 2
const OBSTACLE_MASK := 1 << (OBSTACLE_LAYER_BIT - 1)  # = 2

func _ready() -> void:
	rng.randomize()

	_hide_overlays_and_blur()

	if $UI_Layer:
		$UI_Layer.process_mode = Node.PROCESS_MODE_ALWAYS
	if blur_rect:
		blur_rect.process_mode = Node.PROCESS_MODE_ALWAYS
	if win_overlay:
		win_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	if lose_overlay:
		lose_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	if play_again_btn:
		play_again_btn.process_mode = Node.PROCESS_MODE_ALWAYS
	if retry_btn:
		retry_btn.process_mode = Node.PROCESS_MODE_ALWAYS

	_clear_existing_gold_instances()
	score = 0
	_update_score()
	_spawn_gold()

	var p = get_node_or_null("Player")
	if p == null:
		p = get_node_or_null("/root/Node2D/Player")

	if p:
		var hp = null
		var max_hp = null
		if p.has_method("get"):
			hp = p.get("hp")
			max_hp = p.get("MAX_HP")
		if hp != null and max_hp != null:
			_on_player_hp_changed(hp, max_hp)
		else:
			_on_player_hp_changed(3, 3)
	else:
		_on_player_hp_changed(3, 3)

	if play_again_btn and not play_again_btn.pressed.is_connected(_on_play_again_pressed):
		play_again_btn.pressed.connect(_on_play_again_pressed)
	if retry_btn and not retry_btn.pressed.is_connected(_on_retry_pressed):
		retry_btn.pressed.connect(_on_retry_pressed)
	if play_again_btn:
		play_again_btn.focus_mode = Control.FOCUS_ALL
	if retry_btn:
		retry_btn.focus_mode = Control.FOCUS_ALL

	_spawn_scorpion_random_safe()
	_spawn_snake_random_safe()
	_spawn_crab_random_safe()

func _unhandled_input(event: InputEvent) -> void:
	if get_tree().paused:
		if event.is_action_pressed("ui_accept"):
			if win_overlay and win_overlay.visible:
				_on_play_again_pressed()
				return
			if lose_overlay and lose_overlay.visible:
				_on_retry_pressed()
				return

		if event is InputEventKey and event.pressed and not event.echo:
			if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
				if win_overlay and win_overlay.visible:
					_on_play_again_pressed()
					return
				if lose_overlay and lose_overlay.visible:
					_on_retry_pressed()
					return

# ---------- GOLD ----------
func _clear_existing_gold_instances() -> void:
	for g in get_tree().get_nodes_in_group("gold"):
		if is_instance_valid(g):
			g.queue_free()
	await get_tree().process_frame
	current_gold = null

func _spawn_gold() -> void:
	if _awaiting_gold_spawn and is_instance_valid(current_gold):
		return
	if is_instance_valid(current_gold):
		return
	var pos := _get_safe_random_pos(14.0)
	current_gold = gold_scene.instantiate()
	current_gold.position = pos
	add_child(current_gold)
	if current_gold.has_signal("picked"):
		current_gold.connect("picked", Callable(self, "_on_gold_picked"))
	_awaiting_gold_spawn = false

func _on_gold_picked() -> void:
	if _awaiting_gold_spawn:
		return
	_awaiting_gold_spawn = true
	score += 1
	_update_score()
	current_gold = null
	if score >= GOAL:
		_on_win()
	else:
		call_deferred("_spawn_gold")

# ---------- ENEMIES ----------
func _spawn_scorpion_random_safe() -> void:
	if is_instance_valid(current_scorpion):
		return
	var pos := _get_safe_random_pos(18.0)
	current_scorpion = scorpion_scene.instantiate()
	current_scorpion.position = pos
	add_child(current_scorpion)

func _spawn_snake_random_safe() -> void:
	if is_instance_valid(current_snake):
		return
	var pos := _get_safe_random_pos(18.0)
	current_snake = snake_scene.instantiate()
	current_snake.position = pos
	add_child(current_snake)

func _spawn_crab_random_safe() -> void:
	if is_instance_valid(current_crab):
		return
	var pos := _get_safe_random_pos(18.0)
	current_crab = crab_scene.instantiate()
	current_crab.position = pos
	add_child(current_crab)

# ---------- SAFE POS ----------
func _get_safe_random_pos(test_radius: float) -> Vector2:
	var space := get_world_2d().direct_space_state
	var shape := CircleShape2D.new()
	shape.radius = test_radius
	var params := PhysicsShapeQueryParameters2D.new()
	params.shape = shape
	params.collision_mask = OBSTACLE_MASK
	for i in range(40):
		var x := rng.randi_range(MARGIN_X, VIEW_W - MARGIN_X)
		var y := rng.randi_range(MARGIN_Y, VIEW_H - MARGIN_Y)
		params.transform = Transform2D(0.0, Vector2(x, y))
		var hits := space.intersect_shape(params, 1)
		if hits.is_empty():
			return Vector2(x, y)
	return Vector2(VIEW_W * 0.5, VIEW_H * 0.5)

# ---------- UI ----------
func _update_score() -> void:
	if score_label:
		score_label.text = "Score: %d / %d" % [score, GOAL]

func _on_player_hp_changed(hp: int, max_hp: int) -> void:
	# قلب‌های تصویری (Hearts): بچه‌های TextureRect را بر اساس hp visible کن
	if hearts_hud:
		var children := hearts_hud.get_children()
		for i in range(children.size()):
			children[i].visible = i < hp
	if hp_label:
		hp_label.text = ""
	if hp <= 0:
		_on_game_over()

# ---------- WIN / LOSE OVERLAYS ----------
func _on_win() -> void:
	_show_overlay(win_overlay, true)
	if play_again_btn:
		play_again_btn.grab_focus()

func _on_game_over() -> void:
	_show_overlay(lose_overlay, true)
	if retry_btn:
		retry_btn.grab_focus()

func _show_overlay(overlay: Control, do_pause: bool) -> void:
	if blur_rect:
		blur_rect.visible = true
	if overlay:
		overlay.visible = true
	if do_pause:
		get_tree().paused = true

func _hide_overlays_and_blur() -> void:
	if blur_rect:
		blur_rect.visible = false
	if win_overlay:
		win_overlay.visible = false
	if lose_overlay:
		lose_overlay.visible = false

func _on_play_again_pressed() -> void:
	get_tree().paused = false
	_hide_overlays_and_blur()
	get_tree().reload_current_scene()

func _on_retry_pressed() -> void:
	get_tree().paused = false
	_hide_overlays_and_blur()
	get_tree().reload_current_scene()
