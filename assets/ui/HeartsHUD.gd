
extends HBoxContainer

@export var heart_texture: Texture2D

var heart_nodes: Array[TextureRect] = []

func build(max_hp: int) -> void:
	for c in get_children():
		c.queue_free()
	heart_nodes.clear()

	for i in range(max_hp):
		var tr := TextureRect.new()
		tr.stretch_mode = TextureRect.STRETCH_KEEP
		tr.custom_minimum_size = Vector2(32, 32)  
		tr.texture = heart_texture
		add_child(tr)
		heart_nodes.append(tr)

func set_hp(hp: int) -> void:
	for i in range(heart_nodes.size()):
		heart_nodes[i].visible = i < hp
