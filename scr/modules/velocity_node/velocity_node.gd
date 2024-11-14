class_name VELOCITY_NODE extends Node

@export_category("Modules")
@export var individual: CharacterBody2D

@export var base_speed: float = 575
@export var speed_range: float = 0.15

var current_speed: float
var speed_variation: float
var is_knocked: bool = false

var knockback_direction: Vector2
var knockback_speed: float = 0.0
var knockback_duration: float = 0.0
var knockback_timer: float = 0.0


func _ready():
	speed_variation = randf_range(-speed_range, speed_range)


func on_process(delta):
	if knockback_timer > 0:
		knockback_timer -= delta
		knockback_speed = lerpf(knockback_speed, 0, delta/knockback_duration)
	else:
		is_knocked = false
		knockback_speed = 0
	if is_knocked:
		individual.velocity = knockback_direction * knockback_speed
		activate_move()


func handle_velocity(delta):
	if !is_knocked:
		individual.velocity = individual.direction * current_speed * (1 + speed_variation) * delta


func activate_move():
	individual.move_and_slide()


func calculate_speed(mult_modifiers : Array[float] = [], add_modifiers : Array[float] = []):
	current_speed = base_speed
	
	## Add all multipliers first ##
	for modifier in add_modifiers:
		current_speed += modifier
	
	## Multiply last (to make sure things like slows work properly) ##
	for modifier in mult_modifiers:
		current_speed *= 1+modifier


func apply_knockback(direction: Vector2, speed: float, duration: float):
	knockback_direction = direction
	knockback_speed = speed
	knockback_duration = duration
	knockback_timer = duration
	is_knocked = true
