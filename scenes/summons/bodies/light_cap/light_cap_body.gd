extends SUMMON_BODY

@export var growth_delay: float = 180.0
@export_category("Sun Makers")
@export var sunmaker_node : SUNMAKER_NODE
@export var sunmaker_grown_node : SUNMAKER_NODE

@onready var sprite = $Sprites/Sprite
@onready var grow_timer: Timer = $Grow_Timer


func on_placed() -> void:
	super.on_placed()
	grow_timer.start(growth_delay)
	set_state(0)


func _on_sun_maker_node_can_produce() -> void:
	sunmaker_node.processing = false
	sunmaker_node.create_sun()


func _on_sun_maker_grown_node_can_produce() -> void:
	sunmaker_grown_node.processing = false
	sunmaker_grown_node.create_sun()


func set_state(state: int) -> void:
	sunmaker_node.is_stopped = true if state == 1 else false
	sunmaker_grown_node.is_stopped = false if state == 1 else true
	sprite.texture = load("res://assets/sprites/summons/light_cap/light_cap_state_"+ str(state) +"_idle.png")


func _on_grow_timer_timeout() -> void:
	set_state(1)
