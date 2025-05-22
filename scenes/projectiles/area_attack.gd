extends CharacterBody2D
class_name AREA_ATTACK

signal hit_enemy(enemy)

@export_enum("Summon","Monster") var parent_group: String

var damage: int
var lane : int
var detect_delay: float = 0.01
var detonated: bool = false

@onready var detection_node: DETECTION_NODE = $Detection_Node


func _ready() -> void:
	detect_all_in_area()
	await get_tree().create_timer(0.4).timeout
	queue_free()


func _process(delta: float) -> void:
	if detect_delay > 0:
		detect_delay -= delta
	elif !detonated:
		detonated = true
		detect_all_in_area()


func detect_all_in_area() -> void:
	for area: HITBOX_NODE in detection_node.get_overlapping_areas():
		#print(area.body.name)
		if area.body.cell.y != lane or area.body.is_in_group(parent_group):
			return
		on_hit_target(area.body)


func on_hit_target(enemy: CharacterBody2D):
	enemy.on_damage_taken(damage)
	hit_enemy.emit(enemy)
