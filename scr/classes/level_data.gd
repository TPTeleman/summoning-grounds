class_name LEVEL_DATA extends Resource

@export var map: Texture2D
@export var waves : Array[WAVE_DATA]

@export_category("Sun Details")
@export var sun_falls: bool = true
@export var starting_sun: int = 50
@export var sun_amount: int = 25
@export var first_sun: float = 3.5
@export var sun_cooldown: float = 8.5
@export var sun_delay_range: float = 0.35
