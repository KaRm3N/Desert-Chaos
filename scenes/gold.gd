extends Area2D

@export var textures: Array[Texture2D]    
@export var target_px: float = 32.0       
@export var collision_ratio: float = 0.45 

@onready var sprite: Sprite2D = $Sprite
@onready var shape: CollisionShape2D = $CollisionShape2D

signal picked

var _consumed: bool = false

func _ready() -> void:
	add_to_group("gold")
	randomize()

	if textures.size() > 0:
		var idx: int = randi() % textures.size()
		var tex: Texture2D = textures[idx]
		sprite.texture = tex
		if tex != null:
			var sz: Vector2i = tex.get_size()
			var largest: float = max(float(sz.x), float(sz.y))
			if largest > 0.0:
				var k: float = target_px / largest
				sprite.scale = Vector2(k, k)

	if shape.shape is CircleShape2D:
		var circle: CircleShape2D = shape.shape
		circle.radius = target_px * collision_ratio

	self.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if _consumed:
		return
	if not body.is_in_group("player"):
		return

	_consumed = true
	monitoring = false  

	var fx_scene: PackedScene = preload("res://scenes/PickupFX.tscn")
	var fx = fx_scene.instantiate()
	fx.global_position = global_position
	get_tree().current_scene.add_child(fx)


	picked.emit()

	queue_free()
