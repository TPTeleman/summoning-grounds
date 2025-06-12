class_name SUN extends CharacterBody2D

signal sun_collected(node)

var sun_value: int

@export var rotation_speed: float = 1
@export var degrees: float = 95
@export var rotation_variation: float = 0.2
@export var horizontal_speed: float = 0
@export var fall_speed: float = 85
@export var gravity_speed: float = 55
@export var fall_range: float = 260

var direction: int = 0
var variation: float = 0
var start_position : Vector2
var on_the_ground: bool = false

@onready var sprite_cluster: Node2D = $Sprite_Cluster
@onready var sun_ring: Sprite2D = $Sprite_Cluster/Sun_Ring
@onready var sun_center: Sprite2D = $Sprite_Cluster/Sun_Center
@onready var light: PointLight2D = $Sun_Light

@onready var collision_shape = $Mouse_Area/Collision_Shape
@onready var despawn_timer: Timer = $Despawn_Timer
@onready var label: Label = $Label


func _ready() -> void:
	variation = randf_range(rotation_variation, -rotation_variation)
	start_position = position


func _process(delta: float) -> void:
	sun_ring.rotation_degrees += degrees * delta * (rotation_speed + variation)
	var traveled = position - start_position
	
	#label.text = str(snapped(traveled.y, 0.1))
	if traveled.y >= fall_range:
		on_the_ground = true
		if despawn_timer.time_left <= 0:
			despawn_timer.start()
	if !on_the_ground:
		if velocity.y == 0:
			velocity.y = fall_speed
		velocity.x = direction * horizontal_speed * delta
		velocity.y += gravity_speed * delta
		
		move_and_slide()


func _on_mouse_area_mouse_entered():
	collision_shape.disabled = true
	sun_collected.emit(self)


func _on_despawn_timer_timeout() -> void:
	collision_shape.disabled = true
	var tween := create_tween()
	tween.tween_property(sprite_cluster, "scale", Vector2.ZERO, 0.55)
	await tween.finished
	queue_free()
