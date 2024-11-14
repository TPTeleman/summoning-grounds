class_name STRAIGHT_PROJECTILE extends CharacterBody2D

signal _hit_enemy(enemy)

@export var projectile_speed: float = 240
@export var pierces: int = 1
@export_enum("Summon","Monster") var parent_group: String

var damage: int
var direction: Vector2 = Vector2(1, 0)
var lane : int

@onready var sprites: Node2D = $Sprites


func _process(_delta):
	if pierces <= 0:
		queue_free()


func _physics_process(_delta):
	velocity = direction * projectile_speed
	
	move_and_slide()


func _on_detection_node_area_entered(area):
	if area.body.cell.y != lane or area.body.is_in_group(parent_group):
		return
	if pierces > 0:
		on_hit_target(area.body)


func on_hit_target(enemy: CharacterBody2D):
	enemy.on_damage_taken(damage)
	_hit_enemy.emit(enemy)
	pierces -= 1
