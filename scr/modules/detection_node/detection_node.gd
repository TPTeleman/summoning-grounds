class_name DETECTION_NODE extends Area2D

@export var individual: CharacterBody2D

var entities_in_range: Array[HITBOX_NODE]


func _ready():
	area_entered.connect(on_area_entered)
	area_exited.connect(on_area_exited)


func get_closest_entity() -> SUMMON_BODY:
	var target: CharacterBody2D = null
	for summon in entities_in_range:
		if !target or summon.body.position.distance_to(individual.position) < target.position.distance_to(individual.position):
			target = summon.body
	return target


func on_area_entered(area: HITBOX_NODE):
	if !entities_in_range.has(area):
		entities_in_range.append(area)


func on_area_exited(area: HITBOX_NODE):
	if entities_in_range.has(area):
		entities_in_range.erase(area)
