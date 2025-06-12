extends Node2D

@onready var light: PointLight2D = $Sun_Light


func _on_timer_timeout() -> void:
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.45)
	await tween.finished
	queue_free()
