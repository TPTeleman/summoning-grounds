class_name SUMMON_BODY extends CharacterBody2D

signal died(body)

@export_category("Modules")
@export var health_node: HEALTH_NODE
@export var hitbox_node: HITBOX_NODE

var summon_res : SUMMON_RES
var cell : Vector2
var lawn : LAWN

@onready var sprites: Node2D = $Sprites
@onready var animation_player: AnimationPlayer = $Animation_Player
@onready var collision_shape: CollisionShape2D = $Modules/Hitbox_Node/Collision_Shape
@onready var label = $Label


func _ready():
	label.text = str(health_node.max_health)
	set_process(false)
	set_physics_process(false)


func on_placed():
	animation_player.play("idle")
	collision_shape.disabled = false
	set_process(true)
	set_physics_process(true)


func _process(_delta: float):
	pass


func on_damage_taken(value: int):
	health_node.take_damage(value)


func _on_health_node_damaged(value):
	label.text = str(value)


func _on_health_node_died():
	died.emit(cell, self)
