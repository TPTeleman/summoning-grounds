extends SUMMON_BODY

var state: int = 0

@onready var sprite = $Sprites/Sprite


func _on_health_node_damaged(value):
	super._on_health_node_damaged(value)
	
	if value > health_node.max_health*0.66:
		state = 0
	elif value > health_node.max_health*0.33:
		state = 1
	else:
		state = 2
	sprite.texture = load("res://assets/sprites/summons/rhubarbe_shield/rhubarbe_shield_state_"+str(state)+"_idle.png")
