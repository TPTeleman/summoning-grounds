class_name LOBBED_PROJECTILE extends CharacterBody2D

signal _hit_enemy(enemy)

var duration : float = 1.25
var arc_trajectory : float = 260
@export_enum("Summon","Monster") var parent_group: String

var time : float
var start_position : Vector2
var end_position : Vector2

var damage: int
var lane : int
var reach : bool = false

@onready var sprites: Node2D = $Sprites


func _physics_process(delta):
	if time < 1:
		time = min(time+delta/duration, 1)
		position.x = lerpf(start_position.x, end_position.x, time)
		position.y = lerpf(start_position.y, end_position.y, time)
		position.y += arc_trajectory*(-1+4*pow((time-0.5), 2))
	elif !reach:
		reach = true
		reached_end()


func reached_end():
	queue_free()


func _on_detection_node_area_entered(area):
	if area.body.cell.y != lane or area.body.is_in_group(parent_group):
		return
	on_hit_target(area.body)


func on_hit_target(enemy: CharacterBody2D):
	enemy.on_damage_taken(damage)
	_hit_enemy.emit(enemy)
	queue_free()
