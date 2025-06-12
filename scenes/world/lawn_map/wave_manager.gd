class_name WAVE_MANAGER extends Node

@export var lawn: LAWN
@export var level_data: LEVEL_DATA

var current_flag: int = 0
var wave_index: int = -1
var horde_index: int = -1

var spawn_rate: float = 0.0
var spawn_timer: float = 99.0
var wave_duration: float = 0.0
var wave_timer: float = 0.0

var max_horde_health: float = 0.0
var current_horde_health: float = 0.0


func _ready() -> void:
	set_process(false)


func reset() -> void:
	current_flag = 0
	wave_index = -1
	horde_index = -1

	spawn_rate = 0.0
	spawn_timer = 99.0
	wave_duration = 0.0
	wave_timer = 0.0

	level_data = null


func call_next_wave():
	if wave_index % 5 == 0:
		advance_flag()
	wave_index += 1
	if wave_index <= level_data.waves.size()-1:
		#var available_zombies = level_data.waves[wave_index].zombie_per_lane.duplicate()
		#var zombies: Array[PackedScene]
		#while(level_data.waves[wave_index].zombie_points > 0):
			#if available_zombies.is_empty():
				#break
			#var zombie_scene = available_zombies.pick_random()
			#var new_zombie = zombie_scene.instantiate() as MONSTER_BODY
			#if level_data.waves[wave_index].zombie_points >= new_zombie.spawn_cost:
				#level_data.waves[wave_index].zombie_points -= new_zombie.spawn_cost
				#zombies.append(zombie_scene)
			#else:
				#available_zombies.erase(zombie_scene)
		#zombies_in_wave += zombies
		horde_index = -1
		spawn_rate = level_data.waves[wave_index].spawn_rate
		spawn_timer = spawn_rate
		
		wave_duration = level_data.waves[wave_index].wave_duration
		wave_timer = wave_duration


func _process(delta: float) -> void:
	if lawn.get_monster_amount() <= 0 and (wave_index > 0 or wave_index == 0 and horde_index > -1):
		spawn_timer = 0
		if wave_index < len(level_data.waves) and horde_index >= level_data.waves[wave_index].hordes.size()-1:
			call_next_wave()
	
	if spawn_timer > 0:
		spawn_timer -= delta
	elif wave_index < len(level_data.waves) and horde_index < level_data.waves[wave_index].hordes.size()-1:
		spawn_timer = spawn_rate
		horde_index += 1
		var horde: HORDE_DATA = level_data.waves[wave_index].hordes[horde_index]
		for i in horde.zombie_per_lane.keys():
			for j in horde.zombie_per_lane[i]:
				var zombie: PackedScene = level_data.waves[wave_index].zombie_types[j]
				var lane = i
				if lane == -1:
					lane = randi_range(0,4)
				var _monster: MONSTER_BODY = lawn.spawn_monster(Vector2(11, lane), zombie)
		#level_data.waves[wave_index].zombie_points -= monster.spawn_cost
	#if level_data.waves[wave_index].zombie_points <= 0 and wave_timer > 4.0:
		#call_next_wave()
	
	if wave_timer > 0:
		wave_timer -= delta
		#print(wave_timer)
	else:
		call_next_wave()


func advance_flag():
	current_flag += 1
