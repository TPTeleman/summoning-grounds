extends AREA_ATTACK

@export var particles: GPUParticles2D


func _ready() -> void:
	particles.emitting = true
	super._ready()
