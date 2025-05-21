class_name MONSTER_BODY extends CharacterBody2D

signal update_cell(body, late_cell, new_cell)
signal damaged(health)
signal healed(health)
signal died

@export_category("Modules")
@export var health_node: HEALTH_NODE
@export var hitbox_node: HITBOX_NODE
@export var velocity_node: VELOCITY_NODE
@export var detection_node: DETECTION_NODE
@export var effect_node: EFFECT_NODE

@export_category("Stats")
@export var spawn_cost: int = 1
@export var damage: int = 10
@export var attack_cooldown: float = 0.45
@export var damaged_texture: Texture2D = preload("res://assets/sprites/enemies/naked_zombie/naked_zombie_1.png")

var attack_timer: float
var state: int = 0

var cell : Vector2
var lawn : LAWN
var direction: Vector2 = Vector2(-1, 0)
var target: SUMMON_BODY = null
var is_attacking: bool = false

@onready var sprites: Node2D = $Sprites
@onready var sprite: Sprite2D = $Sprites/Water_Clip/Sprite
@onready var water_clip: Sprite2D = $Sprites/Water_Clip


func _ready():
	water_clip.self_modulate = Color(255, 255, 255, 0)
	attack_timer = attack_cooldown


func _process(delta):
	velocity_node.on_process(delta)
	is_attacking = !detection_node.entities_in_range.is_empty()
	var new_cell: Vector2 = lawn.pos_to_cell(position)
	if new_cell != cell:
		update_cell.emit(self, cell, new_cell)
		#print("Updated!")
		cell = new_cell
	
	var cell_type: String = lawn.get_cell_type(cell)
	if cell_type != "water":
		sprites.position = Vector2.ZERO
		water_clip.clip_children = CanvasItem.CLIP_CHILDREN_DISABLED
		water_clip.self_modulate = Color(255, 255, 255, 0)
	else:
		sprites.position = Vector2(0, 6)
		water_clip.clip_children = CanvasItem.CLIP_CHILDREN_ONLY
		water_clip.self_modulate = Color(255, 255, 255, 255)

	if is_attacking:
		if attack_timer > 0:
			attack_timer -= delta * (1 + effect_node.get_effect_value("ice_slow") + effect_node.get_effect_value("eat_speed"))
		else:
			attack_timer = attack_cooldown
			target = lawn.get_upper_summon_to_attack(detection_node.get_closest_entity().cell)
			if is_instance_valid(target):
				target.on_damage_taken(damage)


func _physics_process(delta):
	if !is_attacking and (!effect_node.has_effect_type("stun") and !effect_node.has_effect_type("root")):
		velocity_node.calculate_speed([effect_node.get_effect_value("ice_slow"),effect_node.get_effect_value("walk_speed")])
		
		velocity_node.handle_velocity(delta)
		
		velocity_node.activate_move()
	
	if effect_node:
		effect_node.process_effect(delta)


func on_damage_taken(value: int):
	health_node.take_damage(value)


func _on_health_node_damaged(value):
	damaged.emit(value)
	if value <= float(health_node.max_health)/2:
		sprite.texture = damaged_texture


func _on_health_node_died():
	update_cell.emit(self, cell, cell)
	died.emit()
	queue_free()


func _on_health_node_healed(value):
	healed.emit(value)
