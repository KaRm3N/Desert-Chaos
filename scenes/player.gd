extends CharacterBody2D

# --- Movement ---
@export var MAX_SPEED: float    = 400.0
@export var ACCEL: float        = 2000.0
@export var FRICTION: float     = 1800.0

# --- Health / Damage ---
@export var MAX_HP: int         = 3
@export var invuln_time: float  = 0.8
@export var knockback_force: float = 260.0
@export var flash_count: int = 5             
@export var flash_interval: float = 0.1      

var hp: int = 3
var invulnerable: bool = false
var last_dir: Vector2 = Vector2.RIGHT

@onready var sprite_right: Sprite2D = $Sprite2D     
@onready var sprite_down:  Sprite2D = $Sprite2D2    
@onready var sprite_up:    Sprite2D = $Sprite2D3    
@onready var sprite_left:  Sprite2D = $Sprite2D4    

func _ready() -> void:
	hp = MAX_HP
	add_to_group("player")

func _physics_process(delta: float) -> void:
	var input_vec := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var target_vel := input_vec * MAX_SPEED

	if input_vec.length() > 0.0:
		velocity = velocity.move_toward(target_vel, ACCEL * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	move_and_slide()

	
	if input_vec.length() > 0.0:
		last_dir = input_vec

	var dir: Vector2 = input_vec if input_vec.length() > 0.0 else last_dir

	if abs(dir.y) > abs(dir.x):
		if dir.y > 0.0:
			_set_visible(false, true, false, false)  
		else:
			_set_visible(false, false, true, false)   
	else:
		if dir.x > 0.0:
			_set_visible(true, false, false, false)  
		else:
			_set_visible(false, false, false, true)  

func _set_visible(right_on: bool, down_on: bool, up_on: bool, left_on: bool) -> void:
	sprite_right.visible = right_on
	sprite_down.visible  = down_on
	sprite_up.visible    = up_on
	sprite_left.visible  = left_on

func hurt(dmg: int, from_pos: Vector2) -> void:
	if invulnerable:
		return

	hp -= max(1, dmg)
	invulnerable = true

	
	var dir := (global_position - from_pos).normalized()
	velocity = dir * knockback_force

	var lvl := get_tree().current_scene
	if lvl and lvl.has_method("_on_player_hp_changed"):
		lvl._on_player_hp_changed(hp, MAX_HP)

	await _flash_invulnerability()

	await get_tree().create_timer(invuln_time).timeout
	invulnerable = false
	_reset_opacity()

	if hp <= 0:
		_die()

func _flash_invulnerability() -> void:
	for i in range(flash_count):
		_set_opacity(0.3)
		await get_tree().create_timer(flash_interval).timeout
		_set_opacity(1.0)
		await get_tree().create_timer(flash_interval).timeout

func _set_opacity(value: float) -> void:
	sprite_right.modulate.a = value
	sprite_down.modulate.a  = value
	sprite_up.modulate.a    = value
	sprite_left.modulate.a  = value

func _reset_opacity() -> void:
	_set_opacity(1.0)

# -------------------------------------------------------
func _die() -> void:
	get_tree().paused = true
