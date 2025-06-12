extends Node

var sun_count: int = 0
var summon_array: Array[SUMMON_RES]
var max_summons: int = 10
var available_summons : Dictionary
var cheat_cards: bool = false


func _ready() -> void:
	get_summons()


func get_summons() -> void:
	var dir := DirAccess.open("res://scenes/summons/resources/")
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			var reduced_name := file_name.trim_suffix(".tres")
			if !dir.current_is_dir():
				#print("Found file: " + reduced_name)
				var summon: SUMMON_RES = load("res://scenes/summons/resources/"+file_name)
				available_summons[summon.id] = reduced_name
			file_name = dir.get_next()
		#print("%s files found." % available_summons.size())
	else:
		print("An error occurred when trying to access the path.")


func get_level_dictionary() -> Dictionary:
	var root_path := "res://scenes/world/levels/resources/"
	var levels: Dictionary = {}

	var root_dir := DirAccess.open(root_path)
	if root_dir:
		root_dir.list_dir_begin()
		var folder_name := root_dir.get_next()
		while folder_name != "":
			if root_dir.current_is_dir() and !folder_name.begins_with("."):
				var full_folder_path := root_path + folder_name + "/"
				var sub_dir := DirAccess.open(full_folder_path)
				if sub_dir:
					sub_dir.list_dir_begin()
					var file_name := sub_dir.get_next()
					while file_name != "":
						if !sub_dir.current_is_dir() and file_name.ends_with(".tres"):
							var level_name := file_name.trim_suffix(".tres")
							if levels.has(folder_name):
								levels[folder_name].append(level_name)
							else:
								levels[folder_name] = [level_name]
						file_name = sub_dir.get_next()
			folder_name = root_dir.get_next()
	else:
		print("An error occurred when trying to access the root path.")

	return levels


func get_level(stage: String, number: String) -> LEVEL_DATA:
	var stage_name: String = stage.to_lower()
	var level_name: String = get_level_dictionary()[stage_name][number]
	return load("res://scenes/world/levels/resources/"+stage_name+"/"+level_name+".tres")


func get_random_level(stage: String) -> LEVEL_DATA:
	var stage_name: String = stage.to_lower()
	var level_name: String = get_level_dictionary()[stage_name].pick_random()
	return load("res://scenes/world/levels/resources/"+stage_name+"/"+level_name+".tres")
