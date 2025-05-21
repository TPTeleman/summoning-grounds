class_name ALMANAC extends Control

signal closed

const SUMMON_CARD_NODE = preload("res://scenes/ui/gui/summon_card/summon_card.tscn")

var summon_body: SUMMON_BODY = null

@onready var card_container: GridContainer = $HBoxContainer/Card_Margin/Panel/MarginContainer/ScrollContainer/Card_Container
@onready var sum_marker: Marker2D = $HBoxContainer/Info_Margin/Panel/MarginContainer/VBoxContainer/Background/Sum_Marker
@onready var name_label: Label = $HBoxContainer/Info_Margin/Panel/MarginContainer/VBoxContainer/Name_Label
@onready var description_label: Label = $HBoxContainer/Info_Margin/Panel/MarginContainer/VBoxContainer/Description_Label
@onready var recharge_label: Label = $HBoxContainer/Info_Margin/Panel/MarginContainer/VBoxContainer/GridContainer/Recharge_Label


func _ready():
	close_almanac()
	create_summon_select()


func open_almanac() -> void:
	show()
	set_information(0)


func _input(event):
	if !visible:
		return
	
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			close_almanac()


func create_summon_select() -> void:
	for i in System.available_summons.size():
		var sum = System.available_summons[i]
		var sum_res = load("res://scenes/summons/resources/"+System.available_summons[i]+".tres") as SUMMON_RES
		var new_card = SUMMON_CARD_NODE.instantiate()
		card_container.add_child(new_card)
		new_card.id = i
		new_card.summon_id = sum_res.id
		new_card.face_rect.texture = load("res://assets/sprites/summon_cards/summon_faces/"+sum+"_face.png")
		new_card.update_price(sum_res.summon_cost)
		new_card.on_click.connect(on_card_clicked)


func on_card_clicked(card: SUMMON_CARD) -> void:
	set_information(card.summon_id)


func set_information(sum_id: int) -> void:
	if summon_body != null:
		summon_body.queue_free()
		summon_body = null
	var sum_res = load("res://scenes/summons/resources/"+System.available_summons[sum_id]+".tres") as SUMMON_RES
	name_label.text = tr(System.available_summons[sum_id].to_upper()+"_NAME")
	description_label.text = tr(System.available_summons[sum_id].to_upper()+"_DESC")+"."
	summon_body = sum_res.summon_body.instantiate()
	sum_marker.add_child(summon_body)
	summon_body.animation_player.play("idle")

	recharge_label.text = "Recharge: "+str(sum_res.summon_cooldown)+"s"
	


func _on_close_button_button_down() -> void:
	close_almanac()


func close_almanac() -> void:
	if summon_body != null:
		summon_body.queue_free()
		summon_body = null
	hide()
	closed.emit()
