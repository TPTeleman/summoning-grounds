class_name SUMMON_CARD extends Control

signal on_click()

var id : int
var summon_id : int

@onready var background_rect: TextureRect = $Control/Background_Rect
@onready var face_rect: TextureRect = $Control/Face_Rect
@onready var over_rect: TextureRect = $Control/Over_Rect
@onready var dark_rect: ColorRect = $Dark_Rect
@onready var hover_rect: ColorRect = $Hover_Rect
@onready var recharge_bar: TextureProgressBar = $Recharge_Bar
@onready var cost_lbl: Label = $Cost_lbl
@onready var selection_rect: TextureRect = $Selection_Rect


func _ready() -> void:
	dark_rect.visible = false
	hover_rect.visible = false
	selection_rect.visible = false
	recharge_bar.value = 0


func update_purchase(sun, value):
	if sun >= value:
		cost_lbl.self_modulate = "ffffff"
		dark_rect.visible = false
	else:
		cost_lbl.self_modulate = "ff0000"
		dark_rect.visible = true


func update_recharge(recharge, cooldown):
	recharge_bar.max_value = cooldown
	recharge_bar.value = recharge


func update_price(value):
	cost_lbl.text = str(value)


func _on_mouse_entered():
	hover_rect.visible = true


func _on_mouse_exited():
	hover_rect.visible = false


func _on_gui_input(event: InputEvent):
	if event.is_action_pressed("left_click"):
		on_click.emit(self)
