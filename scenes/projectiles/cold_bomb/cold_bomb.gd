extends STRAIGHT_PROJECTILE

@export_category("Slow")
@export var slow_strength: float = 0.5
@export var slow_duration: float = 4.5

var last_enemy: MONSTER_BODY = null

@onready var sprite = $Sprites/Sprite
@onready var aoe_slow: DETECTION_NODE = $AoE_Slow


func _process(delta):
	super._process(delta)
	sprite.rotation_degrees += 250 * delta


func _on_hit_enemy(enemy: MONSTER_BODY) -> void:
	last_enemy = enemy
	slow_enemies()
	enemy.effect_node.apply_effect("", "ice_slow", -slow_strength, slow_duration)


func slow_enemies():
	for area in aoe_slow.entities_in_range:
		if area.body != last_enemy and area.body.cell.y == lane:
			area.body.effect_node.apply_effect("", "ice_slow", -slow_strength, slow_duration/3)
