extends SUMMON_BODY

@export_category("Modules")
@export var lobbing_node: LOBBING_NODE
@export var lane_node: LANE_DETECTOR_NODE


func on_placed() -> void:
	super.on_placed()
	lobbing_node.is_stopped = false


func _process(delta: float):
	super._process(delta)
	if lane_node.has_enemy_in_range():
		var enemy = lane_node.get_first_enemy() as MONSTER_BODY
		var pos = lawn.cell_to_pos(Vector2(11, cell.y))
		var lane = cell.y
		if is_instance_valid(enemy):
			pos = enemy.global_position
			lane = enemy.cell.y
		lobbing_node.processing_attack(delta, pos, lane)
