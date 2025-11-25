
extends "res://scripts/EnemyBase.gd"

@export var patrol_left: float  = -120.0
@export var patrol_right: float = 120.0
@export var patrol_speed: float = 60.0
@export var scale_factor: float = 0.6
@export var hitbox_radius_px: float = 16.0  

var base_x: float
var dir: int = 1
var _last_rot: float = 0.0

@onready var sprite: Sprite2D = $Sprite
@onready var hitbox: Area2D = $Hitbox
@onready var body_shape: CollisionShape2D = $CollisionShape2D
@onready var hitbox_shape: CollisionShape2D = $Hitbox/CollisionShape2D if has_node("Hitbox/CollisionShape2D") else null

func _ready() -> void:
	scale = Vector2(scale_factor, scale_factor)
	collision_layer = 4   
	collision_mask  = 2   
	if hitbox:
		hitbox.collision_mask = 1
		if hitbox_shape == null:
			hitbox_shape = CollisionShape2D.new()
			hitbox.add_child(hitbox_shape)
		if hitbox_shape.shape == null or not (hitbox_shape.shape is CircleShape2D):
			hitbox_shape.shape = CircleShape2D.new()
		(hitbox_shape.shape as CircleShape2D).radius = hitbox_radius_px
		if not hitbox.body_entered.is_connected(_on_hitbox_body_entered):
			hitbox.body_entered.connect(_on_hitbox_body_entered)

	super._ready()
	base_x = global_position.x

func _physics_process(delta: float) -> void:
	if player == null:
		velocity = Vector2(dir * patrol_speed, 0)
		move_and_slide()
		_check_patrol_turn()
		_after_move_update()
		return

	var to_player := player.global_position - global_position
	if to_player.length() <= aggro_range:
		var d := to_player.normalized()
		velocity = d * speed
		move_and_slide()
	else:
		velocity = Vector2(dir * patrol_speed, 0)
		move_and_slide()
		_check_patrol_turn()

	_after_move_update()

func _check_patrol_turn() -> void:
	if global_position.x > base_x + patrol_right:
		dir = -1
	elif global_position.x < base_x + patrol_left:
		dir = 1

func _after_move_update() -> void:
	var v := velocity
	if v.length() < 1.0:
		sprite.rotation = _last_rot
		return

	var rot: float
	if abs(v.x) > abs(v.y):
		rot = PI/2 if v.x > 0.0 else -PI/2   
	else:
		rot = 0.0 if v.y < 0.0 else PI       

	sprite.rotation = rot
	_last_rot = rot

func _on_hitbox_body_entered(b: Node) -> void:
	if b.is_in_group("player"):
		on_hit_player(b)
