class_name MENU extends Control

signal play_pressed


func _on_play_button_button_down() -> void:
	play_pressed.emit()


func _on_options_button_button_down() -> void:
	pass # Replace with function body.


func _on_quit_button_button_down() -> void:
	get_tree().quit()
