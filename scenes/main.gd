extends Node

@export var is_cheating: bool = false

@onready var lawn: LAWN = $Lawn
@onready var main_menu: MENU = $Main_Menu
@onready var almanac_control: ALMANAC = $Canvas_Layer/Almanac_Control


func _ready():
	System.cheat_cards = is_cheating
	#TranslationServer.set_locale("pt_br")


func return_to_menu() -> void:
	main_menu.show()


func _on_main_menu_play_pressed() -> void:
	lawn.enter_lawn(System.get_random_level(["night","day"].pick_random()))
	main_menu.hide()


func _on_lawn_left_level() -> void:
	return_to_menu()


func _on_almanac_pressed() -> void:
	lawn.on_almanac = true
	almanac_control.open_almanac()


func _on_almanac_closed() -> void:
	if lawn:
		lawn.on_almanac = false
