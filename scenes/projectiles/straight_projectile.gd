class_name STRAIGHT_PROJECTILE extends CharacterBody2D

signal hit_enemy(enemy)

@export var projectile_speed: float = 240
@export var pierces: int = 1
@export var infinite_pierce: bool = false
@export var projectile_range: float = 960
@export var range_limit: bool = false
@export_enum("Summon","Monster") var parent_group: String

var damage: int
var direction: Vector2 = Vector2(1, 0)
var lane : int
var starting_pos: Vector2
var travelled_distance: float = 0

@onready var sprites: Node2D = $Sprites


func _ready() -> void:
	await get_tree().process_frame
	starting_pos = global_position


func _process(_delta):
	if range_limit:
		#print("Start: ", starting_pos, " Now: ", global_position)
		travelled_distance = starting_pos.distance_to(global_position)
	#print(travelled_distance)
	if (pierces <= 0 and !infinite_pierce) or (travelled_distance >= projectile_range and range_limit):
		queue_free()


func _physics_process(_delta):
	velocity = direction * projectile_speed
	
	move_and_slide()


func _on_detection_node_area_entered(area):
	if area.body.cell.y != lane or area.body.is_in_group(parent_group):
		return
	if pierces > 0 or infinite_pierce:
		on_hit_target(area.body)


func on_hit_target(enemy: CharacterBody2D):
	enemy.on_damage_taken(damage)
	hit_enemy.emit(enemy)
	pierces -= 1
