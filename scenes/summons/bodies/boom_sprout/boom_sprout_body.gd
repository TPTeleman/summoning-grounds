extends SUMMON_BODY

const ARMING = preload("res://scenes/particle_effects/sprout_effects/sprout_arming.tscn")
const EXPLOSION = preload("res://scenes/particle_effects/sprout_effects/sprout_explosion.tscn")

@export_category("Modules")
@export var detection_node: DETECTION_NODE
@export var explosion_area: DETECTION_NODE

@export var damage: int = 1800
@export var arming_delay: float = 8.5
@export var detonating_delay: float = 0.35

var state: int = 0
var detonated: bool = false

@onready var sprite = $Sprites/Sprite
@onready var detection_shape: CollisionShape2D = $Modules/Detection_Node/Collision_Shape
@onready var arming_timer: Timer = $Arming_Timer
@onready var detonating_timer: Timer = $Detonating_Timer


func on_placed():
	super.on_placed()
	update_state(0)
	arming_timer.start(arming_delay)


func _on_arming_timer_timeout():
	update_state(1)
	var particle = lawn.spawn_particle(ARMING) as TEMP_PARTICLES
	particle.position = position+Vector2(0, 8)


func update_state(value: int):
	state = value
	sprite.texture = load("res://assets/sprites/summons/boom_sprout/boom_sprout_state_"+str(state)+"_idle.png")
	collision_shape.disabled = bool(state)
	detection_shape.disabled = !bool(state)


func _on_detection_node_area_entered(area):
	if area.body.cell.y != cell.y:
		return
	if state == 1 and !detonated:
		detonated = true
		detonating_timer.start(detonating_delay)


func _on_detonating_timer_timeout() -> void:
	var particle = lawn.spawn_particle(EXPLOSION) as TEMP_PARTICLES
	particle.position = position+Vector2(0, 8)
	for each in explosion_area.entities_in_range:
		if each.body.cell.y == cell.y:
			each.body.on_damage_taken(damage)
	lawn.free_summon(cell, self)
