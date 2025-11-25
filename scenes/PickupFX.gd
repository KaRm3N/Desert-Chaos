extends Node2D

@onready var sfx: AudioStreamPlayer2D = $SFX
@onready var fx: CPUParticles2D = $Sparkles

func _ready() -> void:
	sfx.play()
	fx.emitting = true
	await get_tree().create_timer(1.0).timeout
	queue_free()
