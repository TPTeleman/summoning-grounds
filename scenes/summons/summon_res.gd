class_name SUMMON_RES extends Resource

@export var id: int
@export var summon_body: PackedScene
@export var summon_cost: int = 0
@export var starting_charge: float = 0.0
@export var summon_cooldown: float = 0.0
@export var is_premium: bool = false

@export_category("Placement Details")
@export var is_upgrade: bool = false
@export var placement_tags: Array[String] = ["takes_space"]
@export var summon_cell := ""
@export var cell_type : Array[String] = ["dirt"]

var summon_recharge: float = 0.0
