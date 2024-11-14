extends Node

var sun_count: int = 0
var summon_array: Array[SUMMON_RES]
var max_summons: int = 10
var available_summons : Dictionary


func dir_contents():
	var dir = DirAccess.open("res://scenes/summons/resources/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			var reduced_name = file_name.trim_suffix(".tres")
			if !dir.current_is_dir():
				#print("Found file: " + reduced_name)
				var summon = load("res://scenes/summons/resources/"+file_name)
				available_summons[summon.id] = reduced_name
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
