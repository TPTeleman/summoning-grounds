extends Node

@onready var lawn: LAWN = $Lawn
@onready var main_menu: MENU = $Main_Menu


func _on_main_menu_play_pressed() -> void:
	#var number = ["000","000","000"].pick_random()
	var number = ["001","002","003"].pick_random()
	lawn.enter_lawn("debug_level_"+number)
	main_menu.hide()
