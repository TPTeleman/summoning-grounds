class_name GUI extends CanvasLayer

signal card_clicked(id)
signal shovel_clicked

const SUMMON_CARD_NODE = preload("res://scenes/ui/gui/summon_card/summon_card.tscn")

@onready var card_container: GridContainer = $Control/CenterContainer/ColorRect/MarginContainer/ScrollContainer/GridContainer
@onready var sun_lbl: Label = $Control/MarginContainer/CenterContainer/HBoxContainer2/HBoxContainer2/Sun_Lbl
@onready var summon_container: GridContainer = $Control/MarginContainer/CenterContainer/HBoxContainer2/HBoxContainer
@onready var select_container = $Control/CenterContainer
@onready var start_button = $Control/Start_Button
@onready var sun_rect = $Control/MarginContainer/CenterContainer/HBoxContainer2/HBoxContainer2/Sun_Rect


func _ready() -> void:
	hide()
	pause_menu.hide()


func _input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			if get_tree().paused == false:
				pause_game()
			else:
				resume_game()
			


func create_summon_select():
	System.dir_contents()
	for i in System.available_summons.size():
		var sum = System.available_summons[i]
		var sum_res = load("res://scenes/summons/resources/"+System.available_summons[i]+".tres") as SUMMON_RES
		#print(System.available_summons[i])
		var new_card = SUMMON_CARD_NODE.instantiate()
		card_container.add_child(new_card)
		new_card.id = i
		new_card.summon_id = sum_res.id
		new_card.face_rect.texture = load("res://assets/sprites/summon cards/summon faces/"+sum+"_face.png")
		new_card.update_price(sum_res.summon_cost)
		new_card.on_click.connect(on_card_selected)
	show()
	#for i in 3:
		#System.summon_array.append(load("res://scenes/summons/resources/"+System.available_summons[10]+".tres"))
		#card_added(10, 11)
	#for i in System.available_summons.size():
		#card_container.get_child(i).on_click.emit(card_container.get_child(i))
	#start_button.button_down.emit()


func summon_purchased():
	for each in summon_container.get_children():
		each.update_purchase(System.sun_count, System.summon_array[each.id].summon_cost)


func level_started():
	select_container.hide()
	start_button.hide()
	for each in summon_container.get_children():
		each.on_click.connect(on_card_clicked)


func on_card_clicked(card):
	var sum_id = -1
	for i in System.summon_array.size():
		if System.summon_array[i].id == card.summon_id:
			sum_id = i
	var summon = System.summon_array[sum_id] as SUMMON_RES
	if summon.summon_recharge <= 0 and System.sun_count >= summon.summon_cost:
		deselect_all()
		card.selection_rect.visible = true
		card_clicked.emit(sum_id)


func deselect_all():
	for card in summon_container.get_children():
		card.selection_rect.visible = false


func on_card_selected(card):
	var has_card = -1
	#print(card.name," - ",card.summon_id)
	for i in System.summon_array.size():
		if System.summon_array[i].id == card.summon_id:
			#print(System.summon_array[i].id," == ",card.summon_id)
			has_card = i
			break
	if has_card == -1:
		if System.summon_array.size() < System.max_summons:
			#print(System.available_summons[card.summon_id])
			System.summon_array.append(load("res://scenes/summons/resources/"+System.available_summons[card.summon_id]+".tres"))
			card_added(card.id, card.summon_id)
			card.modulate = "272727"
	else:
		System.summon_array.pop_at(has_card)
		card_removed(card)
		card.modulate = "ffffff"


func card_added(id: int, sum_id: int):
	var sum = System.available_summons[id]
	var sum_res = load("res://scenes/summons/resources/"+System.available_summons[id]+".tres") as SUMMON_RES
	#print(System.available_summons[i])
	var new_card = SUMMON_CARD_NODE.instantiate()
	summon_container.add_child(new_card)
	new_card.id = id
	new_card.summon_id = sum_id
	new_card.face_rect.texture = load("res://assets/sprites/summon cards/summon faces/"+sum+"_face.png")
	new_card.update_price(sum_res.summon_cost)
	#new_card.on_click.connect(on_card_selected)


func card_removed(card):
	for i in summon_container.get_child_count():
		if summon_container.get_child(i).summon_id == card.summon_id:
			summon_container.remove_child(summon_container.get_child(i))
			break


func _on_placeholder_gui_input(event: InputEvent):
	if event.is_action_pressed("left_click"):
		shovel_clicked.emit()


func update_card_charge(index):
	var summon = System.summon_array[index] as SUMMON_RES
	var card = summon_container.get_child(index) as SUMMON_CARD
	
	card.update_recharge(summon.summon_recharge, summon.summon_cooldown)


func on_sun_change():
	sun_lbl.text = str(System.sun_count)
	
	for i in System.summon_array.size():
		var summon = System.summon_array[i] as SUMMON_RES
		var card = summon_container.get_child(i) as SUMMON_CARD
		
		card.update_purchase(System.sun_count, summon.summon_cost)


#region Pause Menu

@onready var pause_menu: Control = $Pause_Menu

func pause_game() -> void:
	get_tree().paused = true
	pause_menu.show()


func resume_game() -> void:
	get_tree().paused = false
	pause_menu.hide()


func _on_resume_button_button_down() -> void:
	resume_game()


func _on_quit_button_button_down() -> void:
	pass # Replace with function body.

#
