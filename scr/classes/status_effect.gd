class_name EFFECT extends Resource

var effect_name: String
var effect_type: String
var effect_value: float
var max_duration: float
var current_duration: float
var max_stacks: int
var current_stacks: int


func _init(name, type, value, duration):
	effect_name = name
	effect_type = type
	effect_value = value
	max_duration = duration
	current_duration = duration
