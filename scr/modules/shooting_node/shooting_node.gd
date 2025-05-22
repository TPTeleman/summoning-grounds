class_name SHOOTING_NODE extends Node

@export_category("Modules")
@export var individual: CharacterBody2D
@export var shoot_pos: Marker2D

@export var projectile: PackedScene = preload("res://scenes/projectiles/straight_projectile.tscn")

@export_category("Stats")
@export var attack_cooldown: float = 1.0
@export var attack_variation: float = 0.125
@export var damage: int = 20
@export var projectile_amount: int = 1
@export var projectile_delay: float = 0.0

var is_stopped: bool = true
var is_attacking: bool = false
var attack_timer: float


func _ready():
	attack_timer = attack_cooldown


func processing_attack(delta):
	if !is_stopped:
		if attack_timer > 0:
			attack_timer -= delta
			is_attacking = false
		elif !is_attacking:
			is_attacking = true
			for i in projectile_amount:
				shoot()
				await get_tree().create_timer(projectile_delay).timeout
			attack_timer = attack_cooldown+randf_range(-attack_variation, attack_variation)


func shoot():
	var new_projectile = individual.lawn.spawn_projectile(projectile)
	new_projectile.lane = individual.cell.y
	new_projectile.damage = damage
	if shoot_pos:
		new_projectile.global_position = shoot_pos.global_position
	else:
		new_projectile.global_position = individual.global_position
