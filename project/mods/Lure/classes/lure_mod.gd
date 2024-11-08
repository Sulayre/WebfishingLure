extends Node

const LureContent := preload("res://mods/Lure/classes/lure_content.gd")
const LureItem := preload("res://mods/Lure/classes/lure_item.gd")
const LureCosmetic := preload("res://mods/Lure/classes/lure_cosmetic.gd")

var Lure: Node
var mod_folder: String = get_script().get_path().get_base_dir()
var mod_id: String = mod_folder.get_slice("/", 3)

# Lure mod content
# id : resource
var items: Dictionary
var cosmetics: Dictionary
var actors: Dictionary
var maps: Dictionary


func _init() -> void:
	var resource_files:PoolStringArray = _get_resource_paths(mod_folder) #.plus_file("resources")
	#print_debug(resource_files)
	for file_path in resource_files:
		var resource = load(file_path)
		var file_name:String = file_path.split("/",false)[-1]
		if not resource is LureContent:
			continue
		resource.resource_id = file_name.get_basename()
		resource.mod_id = mod_id
		if resource is LureItem:
			items[resource["resource_id"]] = resource
		elif resource is LureCosmetic:
			cosmetics[resource["resource_id"]] = resource

				
	print_debug(items,"\n",cosmetics)


func _enter_tree() -> void:
	Lure = $"/root/Lure"
	
	Lure._register_mod(self)


func _ready() -> void:
	pass


# Return an array of tres files in the given path recursively
func _get_resource_paths(path: String) -> PoolStringArray:
	var paths: PoolStringArray
	var dir := Directory.new()
	
	if dir.open(path) != OK:
		return PoolStringArray()
	
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
