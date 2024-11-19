class_name LAWN extends Node2D

signal almanac_pressed
signal left_level

const SUN_BODY = preload("res://scenes/world/sun_area/sun_area.tscn")
const PLACED_PARTICLE = {
	"dirt": preload("res://scenes/particle_effects/placed_summon/placed_summon_dirt.tscn"),
	"rock": preload("res://scenes/particle_effects/placed_summon/placed_summon.tscn"),
	"water": preload("res://scenes/particle_effects/placed_summon/placed_summon_water.tscn"),
}

const TILES = {
	"dirt": Vector2(2, 0),
	"rock": Vector2(0, 1),
	"water": Vector2(2, 1),
}

@export_category("Grid Details")
@export var cell_size : int = 48
@export var grid_size := Vector2(10, 5)
@export var grid_start := Vector2(96, 144)
@export var tile_slant := Vector2(0, 4)
@export var start_index := -30

var grid: Dictionary = {}

var level_started: bool = false

var selected_summon: SUMMON_RES = null
var summon_body: SUMMON_BODY = null
var shovel_held: bool = false

var level_data: LEVEL_DATA = null

var on_almanac: bool = false

@onready var checker = $Map/Checker
@onready var map: Node2D = $Map

@onready var objects = $Objects
@onready var summons_node: Node2D = $Summons
@onready var enemies_node: Node2D = $Enemies
@onready var wave_manager: WAVE_MANAGER = $Wave_Manager

@onready var default_grid: TileMapLayer = $Map/Default_Grid
@onready var slanted_grid: TileMapLayer = $Map/Slanted_Grid

@onready var gui: GUI = $GUI
@onready var shovel_sprite: Sprite2D = $Map/Shovel_Sprite

@onready var sun_timer: Timer = $Sun_Timer
@onready var first_sun: Timer = $First_Sun


func _ready():
	map.z_index = start_index * 2
	summons_node.z_index = start_index
	@warning_ignore("integer_division")
	enemies_node.z_index = start_index / 2
	#enter_lawn()


func enter_lawn(level_res: String):
	gui.create_summon_select()
	set_level(level_res)
	create_grid()


func _process(delta):
	if !level_started:
		return
	
	process_cards(delta)
	
	mouse_objects()


func _input(event: InputEvent):
	if !level_started:
		return
	
	if event.is_action_pressed("left_click"):
		if shovel_held:
			shovel_held = false
			remove_one_summon(pos_to_cell(get_global_mouse_position()))
		if selected_summon:
			place_summon(pos_to_cell(get_global_mouse_position()), selected_summon)
	if event.is_action_pressed("right_click"):
		if shovel_held:
			shovel_held = false
		if selected_summon:
			selected_summon = null
			gui.deselect_all()
		if is_instance_valid(summon_body):
			summon_body.queue_free()
			summon_body = null


func _on_start_button_button_down():
	if System.summon_array.size() > 0:
		start_level()
	else:
		print("Not enough summons!")


func set_level(level_res: String):
	var level = load("res://scenes/world/levels/resources/"+level_res+".tres")
	level_data = level
	wave_manager.level_data = level
	set_sun(level_data.starting_sun)


func start_level():
	gui.level_started()
	level_started = true
	
	for card in System.summon_array:
		card.summon_recharge = card.starting_charge
	
	gui.on_sun_change()
	wave_manager.set_process(true)
	
	if level_data.sun_falls:
		first_sun.start(level_data.first_sun)
	
	#place_summon(Vector2(0, 2), load("res://scenes/summons/resources/cold_cotton.tres"))
	#for i in 5:
		#spawn_monster(Vector2(11, i), load("res://scenes/monsters/basic_zombie/basic_zombie.tscn"))
	#spawn_monster(Vector2(11, 3), load("res://scenes/monsters/bucket_zombie/bucket_zombie.tscn"))


func exit_level() -> void:
	level_started = false
	wave_manager.set_process(false)
	wave_manager.reset()

	checker.position = Vector2(-48, -48)

	level_data = null
	selected_summon = null
	summon_body = null
	shovel_held = false
	shovel_sprite.hide()

	System.summon_array.clear()
	grid.clear()
	default_grid.clear()
	slanted_grid.clear()

	sun_timer.stop()
	first_sun.stop()

	left_level.emit()


func clear_entities() -> void:
	for each in objects.get_children():
		each.queue_free()
	for each in summons_node.get_children():
		each.queue_free()
	for each in enemies_node.get_children():
		each.queue_free()


func _on_gui_exit_click() -> void:
	exit_level()
	clear_entities()

#region Grid Region

func create_grid():
	var variation = 0
	var map_image: Image = level_data.map.get_image()
	var size = float(cell_size)
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var point := Vector2(x,y)
			var color = map_image.get_pixelv(point)
			grid[point] = {
				"pos": grid_start+(point*size)+Vector2(roundi(size/2),roundi(size/2)),
				"type": get_ground_from_color(color),
				"summons": [],
				"monsters": [],
				"slant": {"is_slanted": false, "elevation": 1, "slant_dir": 0}
			}
			
			var tile = grid[point]
			if !tile.slant.is_slanted:
				default_grid.set_cell(pos_to_cell(grid_start*2)+point, 1, TILES[tile.type]+Vector2(variation, 0))
			else:
				slanted_grid.set_cell(pos_to_cell(grid_start*2)+point, 1, TILES[tile.type]+Vector2(variation, 0))
			if variation == 0:
				variation = 1
			else:
				variation = 0


func get_ground_from_color(color: Color) -> String:
	if color.r > color.b and color.r > color.g:
		return "dirt"
	elif color.r == color.b and color.r == color.g:
		return "rock"
	elif color.b > color.r and color.b > color.g:
		return "water"
	return "dirt"


func get_monsters_in_lanes(lanes: Array):
	var monsters : Array[MONSTER_BODY]
	for each in enemies_node.get_children():
		var monster = each as MONSTER_BODY
		if lanes.has(monster.cell.y):
			monsters.append(monster)
	#print(monsters)
	return monsters


func cell_to_pos(cell: Vector2):
	var size = float(cell_size)
	return grid_start+(Vector2(cell.x, cell.y)*cell_size)+Vector2(roundi(size/2), roundi(size/2))


func pos_to_cell(pos: Vector2):
	var final_pos = pos-grid_start
	var size = float(cell_size)
	return Vector2(floor(final_pos.x/size), floor(final_pos.y/size))


func get_cell_type(cell: Vector2):
	if has_cell(cell):
		return grid[cell].type
	return ""


func get_upper_summon(cell: Vector2):
	if has_cell(cell):
		var gotten_summon = null
		#print(grid[cell].summons)
		for summon in grid[cell].summons:
			if !gotten_summon:
				gotten_summon = summon
			else:
				if summon.summon_res.placement_tags.has("takes_space"):
					gotten_summon = summon
				elif summon.summon_res.placement_tags.has("is_hollow"):
					if !gotten_summon.summon_res.placement_tags.has("takes_space"):
						gotten_summon = summon
				elif summon.summon_res.placement_tags.has("is_floor"):
					if !gotten_summon.summon_res.placement_tags.has("takes_space") and !gotten_summon.summon_res.placement_tags.has("is_hollow"):
						gotten_summon = summon
		return gotten_summon
	return null


func get_upper_summon_to_attack(cell: Vector2):
	if has_cell(cell):
		var gotten_summon = null
		#print(grid[cell].summons)
		for summon in grid[cell].summons:
			if !gotten_summon:
				gotten_summon = summon
			else:
				if summon.summon_res.placement_tags.has("is_hollow"):
					gotten_summon = summon
				elif summon.summon_res.placement_tags.has("takes_space"):
					if !gotten_summon.summon_res.placement_tags.has("is_hollow"):
						gotten_summon = summon
				elif summon.summon_res.placement_tags.has("is_floor"):
					if !gotten_summon.summon_res.placement_tags.has("is_hollow") and !gotten_summon.summon_res.placement_tags.has("takes_space"):
						gotten_summon = summon
		return gotten_summon
	return null


func is_cell_empty(cell: Vector2):
	if has_cell(cell) and grid[cell].summons.is_empty():
		return true
	return false


func has_place_tag(cell: Vector2, tag: String):
	if has_cell(cell):
		for summon in grid[cell].summons:
			if summon.summon_res.placement_tags.has(tag):
				return true
	return false


func has_cell(cell: Vector2):
	if grid.has(cell):
		return true
	return false


func can_place_on_cell(cell: Vector2, summon: SUMMON_RES):
	if has_cell(cell):
		if is_cell_empty(cell):
			if summon.cell_type.has(get_cell_type(cell)):
				return true
		elif !has_place_tag(cell, summon.placement_tags[0]):
			#if !summon.placement_tags.has("is_hollow"):
			if  !summon.cell_type.has(get_cell_type(cell)):
				var placed_summon = get_plantable_summon(cell) as SUMMON_BODY
				if placed_summon != null:
					if summon.cell_type.has(placed_summon.summon_res.summon_cell):
						return true
			else:
				if selected_summon.placement_tags.has("is_floor"):
					return false
				return true
	return false


func get_plantable_summon(cell: Vector2):
	var summon: SUMMON_BODY
	if has_cell(cell):
		for each in grid[cell].summons:
			if each.summon_res.placement_tags.has("is_floor"):
				summon = each
				break
	return summon


func update_plants_in_cell(cell: Vector2):
	if has_place_tag(cell, "is_floor"):
		for summon in grid[cell].summons:
			if !summon.summon_res.placement_tags.has("is_floor"):
				summon.sprites.global_position = get_plantable_summon(cell).summon_pos.global_position
	else:
		for summon in grid[cell].summons:
			if !summon.summon_res.cell_type.has(grid[cell].type):
				free_summon(cell, summon)
	for summon in grid[cell].summons:
		if summon.summon_res.placement_tags.has("is_floor"):
			summon.sprites.z_index = cell.y + cell.x
		elif summon.summon_res.placement_tags.has("takes_space"):
			summon.sprites.z_index = cell.y + cell.x + 1
		elif summon.summon_res.placement_tags.has("is_hollow"):
			summon.sprites.z_index = cell.y + cell.x + 2


func update_zombies_in_cell(_monster_body: MONSTER_BODY, _late_cell: Vector2, _new_cell: Vector2):
	pass
	#if has_cell(late_cell):
		#if monster_body != null:
			#grid[late_cell].monsters.erase(monster_body)
		#for i in grid[late_cell].monsters.size():
			#var amount = grid[late_cell].monsters.size()
			#var monster = grid[late_cell].monsters[i] as MONSTER_BODY
			#monster.sprites.z_index = late_cell.y
			#monster.sprites.position.y = 12-12*i
	#if has_cell(new_cell):
		#if monster_body != null:
			#grid[new_cell].monsters.append(monster_body)
		#for i in grid[new_cell].monsters.size():
			#var amount = grid[new_cell].monsters.size()
			#var monster = grid[new_cell].monsters[i] as MONSTER_BODY
			#monster.sprites.z_index = new_cell.y
			#monster.sprites.position.y = 12-12*i


func mouse_objects():
	var mouse_grid = pos_to_cell(get_global_mouse_position())
	if !grid.is_empty() and has_cell(mouse_grid):
		var size = float(cell_size)
		checker.position = grid[mouse_grid]["pos"]-Vector2(roundi(size/2),roundi(size/2))
	checker.visible = has_cell(mouse_grid) and (!selected_summon or selected_summon and selected_summon.cell_type.has(get_cell_type(mouse_grid))) and (!selected_summon or selected_summon and can_place_on_cell(mouse_grid, selected_summon))
	
	if is_instance_valid(summon_body):
		if has_cell(mouse_grid):
			summon_body.position = grid[mouse_grid].pos
			if grid[mouse_grid].slant.is_slanted == false:
				checker.polygon[0] = Vector2(0, 0)
				checker.polygon[1] = Vector2(48, 0)
				checker.polygon[2] = Vector2(48, 48)
				checker.polygon[3] = Vector2(0, 48)
			else:
				checker.polygon[0] = Vector2(0, 4)
				checker.polygon[1] = Vector2(48, 0)
				checker.polygon[2] = Vector2(48, 48)
				checker.polygon[3] = Vector2(0, 54)
		summon_body.visible = has_cell(mouse_grid)
		if selected_summon:
			if can_place_on_cell(mouse_grid, selected_summon):
				summon_body.sprites.modulate = "22ff009a"
			else:
				summon_body.sprites.modulate = "ff00049a"
	
	shovel_sprite.visible = shovel_held
	if shovel_held:
		shovel_sprite.global_position = get_global_mouse_position()

#endregion
#region Sun Generation


func _on_first_sun_timeout() -> void:
	sun_timer.start(level_data.sun_cooldown)
	spawn_sun(Vector2(randf_range(96, 544), 0), level_data.sun_amount, 90)


func _on_sun_timer_timeout() -> void:
	var time = level_data.sun_cooldown+randf_range(-level_data.sun_delay_range, level_data.sun_delay_range)
	sun_timer.set_wait_time(time)
	spawn_sun(Vector2(randf_range(96, 544), 0), level_data.sun_amount, 90)


func spawn_sun(pos: Vector2, sun_value: int = 25, fall_variant: int = 0):
	var new_sun = SUN_BODY.instantiate()
	new_sun.sun_value = sun_value
	new_sun.position = pos
	new_sun.fall_range += randf_range(-fall_variant, fall_variant)
	if sun_value < 25:
		new_sun.scale = Vector2(0.2, 0.2)+Vector2(0.8*(float(sun_value)/25), 0.8*(float(sun_value)/25))
	else:
		new_sun.scale = Vector2(0.8, 0.8)+Vector2(0.2*(float(sun_value)/25), 0.2*(float(sun_value)/25))
	objects.add_child(new_sun)
	new_sun.sun_collected.connect(on_sun_collected)
	return new_sun


func on_sun_collected(node):
	var tween := create_tween()
	var sun_anim = preload("res://scenes/world/sun_area/temp_sun.tscn").instantiate()
	sun_anim.position = node.position
	sun_anim.scale = node.scale
	gui.add_child(sun_anim)
	sun_anim.get_node("Timer").start(0.65)
	tween.tween_property(sun_anim, "global_position", gui.sun_rect.global_position+Vector2(32, 32), 0.65)
	gain_sun(node.sun_value)
	node.queue_free()

#endregion
#region GUI Functions

func process_cards(delta):
	for i in System.summon_array.size():
		var card = System.summon_array[i] as SUMMON_RES
		if card.summon_recharge > 0:
			card.summon_recharge -= delta
			gui.update_card_charge(i)


func _on_gui_card_clicked(id):
	shovel_held = false
	free_select()
	selected_summon = System.summon_array[id]
	if selected_summon.summon_body:
		summon_body = selected_summon.summon_body.instantiate()
		summon_body.name = "Placeholder_Body"
		objects.add_child(summon_body)
	else:
		selected_summon = null


func card_used(summon: SUMMON_RES):
	summon.summon_recharge = summon.summon_cooldown
	spend_sun(summon.summon_cost)
	free_select()


func _on_gui_shovel_clicked():
	if !level_started:
		return
	
	if shovel_held == false:
		shovel_held = true
	else:
		shovel_held = false
	free_select()


func _on_almanac_button_button_down() -> void:
	almanac_pressed.emit()

#endregion
#region Grid Functions

func place_summon(cell: Vector2, summon: SUMMON_RES):
	if can_place_on_cell(cell, summon):
		var new_summon = summon.summon_body.instantiate() as SUMMON_BODY
		new_summon.name = "summon_"+str(summon.id)+"_"+str(cell.x)+"_"+str(cell.y)
		summons_node.add_child(new_summon)
		new_summon.died.connect(free_summon)
		new_summon.position = grid[cell].pos
		new_summon.lawn = self
		new_summon.cell = cell
		new_summon.summon_res = summon
		new_summon.on_placed()
		grid[cell].summons.append(new_summon)
		card_used(summon)
		var particle = spawn_particle(PLACED_PARTICLE[grid[cell].type])
		particle.position = grid[cell].pos+Vector2(0, 16)
		update_plants_in_cell(cell)
		gui.deselect_all()


var spawned_count: int = 0

func spawn_monster(cell: Vector2, monster: PackedScene):
	var new_monster = monster.instantiate() as MONSTER_BODY
	new_monster.name = "monster_"+str(spawned_count)+"_"+str(cell.x)+"_"+str(cell.y)
	enemies_node.add_child(new_monster)
	new_monster.position = cell_to_pos(cell)
	new_monster.lawn = self
	new_monster.cell = cell
	spawned_count += 1
	new_monster.position.y += randf_range(-12,12)
	new_monster.sprites.position.x += randf_range(-12,12)
	#new_monster.update_cell.connect(update_zombies_in_cell)
	return new_monster
	#grid[cell].summons.append(new_monster)


func get_monster_amount():
	var count = enemies_node.get_child_count()
	return count


func remove_one_summon(cell: Vector2):
	var summon = get_upper_summon(cell)
	if summon:
		#gain_sun(round(summon.summon_res.summon_cost/2))
		free_summon(cell, summon)


func free_summon(cell: Vector2, summon: SUMMON_BODY):
	grid[cell].summons.erase(summon)
	summon.queue_free()
	update_plants_in_cell(cell)

#endregion
#region Lawn Functions

func spawn_particle(particle: PackedScene):
	var new_particle = particle.instantiate()
	objects.add_child(new_particle)
	return new_particle


func spawn_projectile(projectile: PackedScene):
	var new_projectile = projectile.instantiate()
	objects.add_child(new_projectile)
	return new_projectile

#endregion

func free_select():
	if selected_summon:
		selected_summon = null
	if is_instance_valid(summon_body):
		summon_body.queue_free()
		summon_body = null


func set_sun(value):
	System.sun_count = value
	gui.on_sun_change()


func spend_sun(value):
	System.sun_count -= value
	gui.on_sun_change()


func gain_sun(value):
	System.sun_count += value
	gui.on_sun_change()
