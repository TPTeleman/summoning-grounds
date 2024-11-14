extends SUMMON_BODY

const EXPLOSION = preload("res://scenes/particle_effects/sprout_effects/sprout_explosion.tscn")

@export_category("Modules")
@export var explosion_area: DETECTION_NODE

@export var damage: int = 1800
@export var explosion_delay: float = 0.3

@onready var detonate_timer: Timer = $Detonate_Timer


func on_placed():
	super.on_placed()
	detonate_timer.start(explosion_delay)


func detonate() -> void:
	var particle = lawn.spawn_particle(EXPLOSION) as TEMP_PARTICLES
	particle.position = position+Vector2(0, 8)
	for each in explosion_area.entities_in_range:
		if (each.body.cell.y == cell.y) or (each.body.cell.y == cell.y-1) or (each.body.cell.y == cell.y+1):
			each.body.on_damage_taken(damage)
	lawn.free_summon(cell, self)


func _on_detonate_timer_timeout() -> void:
	detonate()
