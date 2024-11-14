extends SUMMON_BODY

@export_category("Modules")
@export var knockback_area: DETECTION_NODE

var state: int = 0
var knock_states := {
	0: false,
	1: false,
	2: false
}

@onready var sprite = $Sprites/Sprite


func _on_health_node_damaged(value):
	super._on_health_node_damaged(value)
	if value > health_node.max_health*0.66:
		state = 0
	elif value > health_node.max_health*0.33:
		state = 1
	else:
		state = 2
	if !knock_states[state]:
		knock_states[state] = true
		knockback_enemies()
	sprite.texture = load("res://assets/sprites/summons/rambutan/rambutan_state_"+str(state)+"_idle.png")


func knockback_enemies():
	for each in knockback_area.entities_in_range:
		if (each.body.cell.y == cell.y) or (each.body.cell.y == cell.y-1) or (each.body.cell.y == cell.y+1):
			each.body.velocity_node.apply_knockback(Vector2(1,0), 175, 0.225)
