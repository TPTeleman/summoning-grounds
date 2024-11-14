class_name LOBBING_NODE extends Node

@export_category("Modules")
@export var individual: CharacterBody2D
@export var shoot_pos: Marker2D

@export var projectile: PackedScene = preload("res://scenes/projectiles/lobbed_projectile.tscn")

@export_category("Stats")
@export var attack_cooldown: float = 1.0
@export var attack_variation: float = 0.125
@export var damage: int = 20
@export var projectile_amount: int = 1
@export var projectile_delay: float = 0.0
@export var duration : float = 1.25
@export var arc_trajectory : float = 260

var is_stopped: bool = true
var is_attacking: bool = false
var attack_timer: float


func _ready():
	attack_timer = attack_cooldown


func processing_attack(delta, pos: Vector2, target_lane: int):
	if !is_stopped:
		if attack_timer > 0:
			attack_timer -= delta
			is_attacking = false
		elif !is_attacking:
			is_attacking = true
			for i in projectile_amount:
				shoot(pos, target_lane)
				await get_tree().create_timer(projectile_delay).timeout
			attack_timer = attack_cooldown+randf_range(-attack_variation, attack_variation)


func shoot(pos: Vector2, target_lane: int):
	var new_projectile = individual.lawn.spawn_projectile(projectile) as LOBBED_PROJECTILE
	new_projectile.lane = target_lane
	new_projectile.damage = damage
	new_projectile.duration = duration
	new_projectile.arc_trajectory = arc_trajectory
	if shoot_pos:
		new_projectile.global_position = shoot_pos.global_position
		new_projectile.start_position = shoot_pos.global_position
	else:
		new_projectile.global_position = individual.global_position
		new_projectile.start_position = individual.global_position
	new_projectile.end_position = pos
