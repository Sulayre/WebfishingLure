extends Node

const LureItem := preload("res://mods/Lure/classes/lure_item.gd")
const LureCosmetic := preload("res://mods/Lure/classes/lure_cosmetic.gd")

var Lure: Node
var mod_folder: String = get_script().get_path().get_base_dir()
var mod_id: String = mod_folder.get_slice("/", 3)

# Lure mod content
var items: Array
var cosmetics: Array
var actors: Array
var maps: Array


func _init() -> void:
	var resource_files: Array = _get_resource_paths(mod_folder.plus_file("resources"))
	
	for file in resource_files:
		var resource = load(file)
		
		if resource is LureItem:
			items.append(resource)
		elif resource is LureCosmetic:
			cosmetics.append(resource)


func _enter_tree() -> void:
	Lure = $"/root/Lure"
	
	Lure._register_mod(self)


func _ready() -> void:
	pass


# Return an array of tres files in the given path recursively
func _get_resource_paths(path: String) -> Array:
	var paths: Array
	var dir := Directory.new()
	
	if dir.open(path) != OK:
		return []
	
	dir.list_dir_begin(true, true)
	var file_name = dir.get_next()
	
	while file_name != "":
		var file_path = path.plus_file(file_name)
		
		if dir.current_is_dir():
			paths.append_array(_get_resource_paths(file_path))
		elif file_name.ends_with("tres"):
			paths.append(file_path)
		
		file_name = dir.get_next()
	
	dir.list_dir_end()
	
	return paths
