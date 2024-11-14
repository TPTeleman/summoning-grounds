class_name HEALTH_NODE extends Node

signal damaged(value)
signal healed(value)
signal died()

@export var max_health : int = 100
@export var max_armor : int = 0
var current_health : int = 0
var current_armor : int = 0



func _ready():
	current_health = max_health
	current_armor = max_armor


func recover_health(value: int):
	current_health = clamp(current_health+value, 0, max_health)
	healed.emit(current_health)


func take_damage(value: int):
	var damage = value
	if current_armor > 0:
		damage = value-current_armor
		current_armor = clamp(current_armor-value, 0, max_armor)
	if damage > 0:
		current_health = clamp(current_health-damage, 0, max_health)
	damaged.emit(current_health)
	if current_health == 0:
		died.emit()
