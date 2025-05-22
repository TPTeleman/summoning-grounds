extends SUMMON_BODY

@export_category("Modules")
@export var shooting_node: SHOOTING_NODE
@export var lane_node: LANE_DETECTOR_NODE


func on_placed() -> void:
	super.on_placed()
	shooting_node.is_stopped = false


func _process(delta: float):
	super._process(delta)
	if lane_node.has_enemy_in_range():
		shooting_node.processing_attack(delta)
