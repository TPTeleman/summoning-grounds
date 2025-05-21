extends SUMMON_BODY

@export_category("Modules")
@export var knockback_area: DETECTION_NODE

@export_category("Ability")
@export var knockback_power: int = 175
@export var knockback_duration: float = 0.225
@export var knockback_cooldown: float = 8.0

var state: int = 0
var can_knock: bool = false
var knockback_timer: float = 0.0

var knock_states := {
	0: false,
	1: false,
	2: false,
	3: false,
	4: false
}

@onready var sprite = $Sprites/Sprite


func _process(delta: float):
	super._process(delta)
	if !can_knock:
		knockback_timer -= delta
		if knockback_timer <= 0.0:
			knockback_timer = knockback_cooldown
			can_knock = true


func _on_health_node_damaged(value):
	super._on_health_node_damaged(value)
	if value > health_node.max_health*0.72:
		state = 0
	elif value > health_node.max_health*0.54:
		state = 1
	elif value > health_node.max_health*0.38:
		state = 2
	elif value > health_node.max_health*0.20:
		state = 3
	else:
		state = 4
	if !knock_states[state]:
		knock_states[state] = true
		knockback_enemies()
	sprite.texture = load("res://assets/sprites/summons/rambutan/rambutan_state_"+str(state)+"_idle.png")


func knockback_enemies():
	for hitbox: HITBOX_NODE in knockback_area.entities_in_range:
		var body: MONSTER_BODY = hitbox.body
		if (body.cell.y == cell.y) or (body.cell.y == cell.y-1) or (body.cell.y == cell.y+1):
			body.velocity_node.apply_knockback(Vector2(1,0), knockback_power, knockback_duration)
