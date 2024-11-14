extends SUMMON_BODY

@export var sunmaker_node : SUNMAKER_NODE


func on_placed() -> void:
	super.on_placed()
	sunmaker_node.is_stopped = false


func _on_sun_maker_node_can_produce() -> void:
	sunmaker_node.processing = false
	sunmaker_node.create_sun()
