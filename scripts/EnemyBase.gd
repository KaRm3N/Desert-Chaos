extends CharacterBody2D

@export var speed: float       = 90.0
@export var damage: int        = 1
@export var aggro_range: float = 380.0
@export var stop_range: float  = 16.0

var player: Node2D = null

func _ready() -> void:
	add_to_group("enemy")
	var plist := get_tree().get_nodes_in_group("player")
	if plist.size() > 0:
		player = plist[0] as Node2D

func _physics_process(delta: float) -> void:
	if player == null:
		return
	var to_player := player.global_position - global_position
	var dist := to_player.length()

	if dist <= aggro_range and dist > stop_range:
		var dir := to_player.normalized()
		velocity = dir * speed
		move_and_slide()
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed * delta)

	_after_move_update()

func on_hit_player(body: Node) -> void:
	if body and body.has_method("hurt"):
		body.hurt(damage, global_position)

func _after_move_update() -> void:
	pass
