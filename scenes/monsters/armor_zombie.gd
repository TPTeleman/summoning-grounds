extends MONSTER_BODY

@export var armor_type: String

var armor_state: int = 0

@onready var armor_sprite: Sprite2D = $Sprites/Water_Clip/Sprite/Armor_Sprite


func _on_health_node_damaged(value):
	super._on_health_node_damaged(value)
	
	if health_node.current_armor > health_node.max_armor*0.66:
		armor_state = 0
	elif health_node.current_armor > health_node.max_armor*0.33:
		armor_state = 1
	elif health_node.current_armor > 0:
		armor_state = 2
	else:
		armor_sprite.hide()
	armor_sprite.texture = load("res://assets/sprites/enemies/armor_"+str(armor_type)+"/armor_"+str(armor_type)+"_"+str(armor_state)+".png")
