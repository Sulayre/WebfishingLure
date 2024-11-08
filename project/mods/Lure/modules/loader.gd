extends Node

onready var Lure := $"/mods/Lure"


func _add_resource(file, file_name) -> void:
	file_name = file_name.get_basename()
	
	var read = load(file)
	if read.get("resource_type") == null:
		print("TRES file does not have resource type labeled.")
		return
	var type = read.get("resource_type")
	
	var new = {}
	new["file"] = load(file)
	