class_name SUNMAKER_NODE extends Node

signal can_produce

@export var summon_body: SUMMON_BODY

@export var first_sun: float = 1.0
@export var generation_cooldown: float = 1.0
@export var sun_delay_range: float = 0.35
@export var sun_value: int = 25

var is_stopped: bool = true
var sun_timer: float = 0.0
var processing: bool = true

@export var horizontal_speed: float = 900
@export var fall_speed: float = -175
@export var gravity_speed: float = 200
@export var fall_range: float = 32


func _ready() -> void:
	sun_timer = first_sun+randf_range(-sun_delay_range, sun_delay_range)


func _process(delta: float) -> void:
	if is_stopped:
		return
	if sun_timer > 0:
		sun_timer -= delta
	elif processing:
		can_produce.emit()


func create_sun():
	processing = true
	sun_timer = generation_cooldown+randf_range(-sun_delay_range, sun_delay_range)
	var sun = summon_body.lawn.spawn_sun(summon_body.global_position, sun_value, 0) as SUN
	sun.horizontal_speed = randf_range(-horizontal_speed, horizontal_speed)
	sun.direction = [-1, 1].pick_random()
	sun.fall_speed = fall_speed
	sun.gravity_speed = gravity_speed
	sun.fall_range = fall_range+randf_range(-15, 15)
