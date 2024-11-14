extends LOBBED_PROJECTILE

@onready var sprite: Sprite2D = $Sprites/Sprite


func _process(delta: float) -> void:
	sprite.rotation_degrees += 360 * delta
