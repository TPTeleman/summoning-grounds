class_name EFFECT_NODE extends Node2D

@export_category("Modules")
@export var individual: CharacterBody2D

var effect_array : Array[EFFECT]


func process_effect(delta: float):
	for effect in effect_array:
		if effect.current_duration > 0:
			effect.current_duration -= delta
		else:
			effect_array.erase(effect)
	if has_effect_type("ice_slow"):
		individual.sprites.modulate = "2bb8ff"
	else:
		individual.sprites.modulate = "ffffff"


func apply_effect(e_name: String, e_type: String, e_value: float, duration: float):
	if !has_effect(e_name):
		var new_effect = EFFECT.new(e_name, e_type, e_value, duration)
		effect_array.append(new_effect)
	else:
		var effect = get_effect(e_name) as EFFECT
		if e_value > effect.effect_value:
			effect.effect_value = e_value
		if duration > effect.max_duration:
			effect.max_duration = duration
		if duration > effect.current_duration:
			effect.current_duration = duration


func has_effect_type(e_type: String):
	for effect in effect_array:
		if effect.effect_type == e_type:
			return true
	return false


func has_effect(e_name: String):
	for effect in effect_array:
		if effect.effect_name == e_name:
			return true
	return false


func get_effect(e_name: String):
	for effect in effect_array:
		if effect.effect_name == e_name:
			return effect
	return null


func get_effect_value(e_type: String):
	var value = 0
	for effect in effect_array:
		if effect.effect_type == e_type:
			value += effect.effect_value
	return value
