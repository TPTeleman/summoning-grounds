extends STRAIGHT_PROJECTILE

@onready var sprite = $Sprites/Sprite


func _process(delta):
	super._process(delta)
	sprite.rotation_degrees += 250 * delta


func _on__hit_enemy(enemy: Variant) -> void:
	#print("Lol")
	enemy.effect_node.apply_effect("", "ice_slow", -0.5, 4.5)
