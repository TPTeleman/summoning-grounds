class_name LANE_DETECTOR_NODE extends Node

@export_category("Modules")
@export var individual: SUMMON_BODY

@export var lanes := {
	-2: false,
	-1: false,
	0: true,
	1: false,
	2: false,
}
@export var lane_range: float = 10.0
@export var centered: bool = true
@export var in_front: bool = true
@export var behind: bool = false


func get_enemies_all_lane():
	var affected_lanes = []
	for lane in lanes:
		if lanes[lane]:
			affected_lanes.append(individual.cell.y+lane)
	#print(individual.cell.y," - ",affected_lanes)
	var enemies = individual.lawn.get_monsters_in_lanes(affected_lanes)
	return enemies


func get_enemies_in_lane(lane: int):
	return individual.lawn.get_monsters_in_lanes([lane])


func has_enemies_in_lane(lane: int):
	var enemies = individual.lawn.get_monsters_in_lanes([lane])
	if enemies.size() > 0:
		return true
	return false


func in_range_centered(element: MONSTER_BODY, lane: int):
	var distance = (individual.global_position+Vector2(0, 48*lane)).distance_to(element.global_position)
	var has_range = distance <= lane_range and element.position.x < 576
	if !in_front or !behind:
		if (in_front and element.global_position.x < individual.global_position.x) or (behind and element.global_position.x > individual.global_position.x):
			has_range = false
	#print(lane," - ",distance," - ",has_range)
	return has_range


func in_range(element: MONSTER_BODY, lane: int):
	var has_range = element.global_position.distance_to(Vector2(0, 48*lane)) <= lane_range and element.position.x < 576
	if !in_front or !behind:
		if (in_front and element.global_position.x < individual.global_position.x) or (behind and element.global_position.x > individual.global_position.x):
			has_range = false
	return has_range


func has_enemy_in_range():
	var enemies = get_enemies_all_lane() as Array[MONSTER_BODY]
	if centered:
		for lane in lanes:
			if lanes[lane] and enemies.any(in_range_centered.bind(lane)):
				return true
	else:
		for lane in lanes:
			if lanes[lane] and enemies.any(in_range.bind(lane)):
				return true
	return false


func get_enemies_in_range():
	var filtered_enemies = []
	var enemies = get_enemies_in_lane(0) as Array[MONSTER_BODY]
	if centered:
		for lane in lanes:
			if lanes[lane]:
				pass
		for each in enemies:
			if each.cell.y == individual.cell.y:
				if each.global_position.distance_to(individual.global_position) <= lane_range:
					filtered_enemies.append(each)
			else:
				pass
	else:
		pass


func get_first_enemy(positional: bool = false):
	var enemies = get_enemies_all_lane() as Array[MONSTER_BODY]
	var closest_enemy: MONSTER_BODY = null
	for lane in lanes:
		if lanes[lane]:
			for enemy in enemies:
				if (centered and in_range_centered(enemy, lane) or (!centered and in_range(enemy, lane))):
					if closest_enemy == null:
						closest_enemy = enemy
					else:
						if !positional:
							if enemy.cell.y == individual.cell.y:
								if closest_enemy.cell.y == individual.cell.y:
									var distance = (individual.global_position+Vector2(0, 48*lane)).distance_to(enemy.global_position)
									if distance < (individual.global_position+Vector2(0, 48*lane)).distance_to(closest_enemy.global_position):
										closest_enemy = enemy
								else:
									closest_enemy = enemy
						else:
							var distance = (individual.global_position+Vector2(0, 48*lane)).distance_to(enemy.global_position)
							if distance < (individual.global_position+Vector2(0, 48*lane)).distance_to(closest_enemy.global_position):
								closest_enemy = enemy
	return closest_enemy
