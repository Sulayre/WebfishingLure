extends Node
var Lure:Node
const PREFIX = "[Lure/Util]: "
func _mod_path_converter(mod_id:String,path:String):
	if path.begins_with("res://"):
		return path
	return path.replace("mod://",Lure.MODS_FOLDER.plus_file(mod_id)+"/")

func _validate_paths(mod:String,path:String) -> bool:
	var dir = Directory.new()
	var folder = Lure.MODS_FOLDER.plus_file(mod)
	if !dir.dir_exists(folder):
		Lure.emit_signal("lurlog",Lure.MOD_NOT_FOUND,true)
		dir = null
		return false
	var valid_other_mod = path.begins_with("mods/")
	if path.begins_with(Lure.OWN_MOD_PREFIX) or valid_other_mod:
		# mods/modid://
		if valid_other_mod:
			var slice = path.get_slice("/",1)
			var id = slice.get_slice("://",0)
			if dir.dir_exists(Lure.MODS_FOLDER.plus_file(id)):
				dir = null
				return true
			else:
				Lure.emit_signal("lurlog",Lure.NEIGHBOR_MOD_NOT_FOUND,true)
				dir = null
				return false
		# mod:// technically 
		dir = null
		return true
	elif path.begins_with("res://"):
		dir = null
		return true
	Lure.emit_signal("lurlog",Lure.RESOURCE_PATH_INVALID,true)
	dir = null
	return false

func _specie_sfx_name(action:String,specie_id) -> String:
	return(action+"_"+_format_node_name(specie_id))

func _format_node_name(name:String) -> String:
	return name.replace(".","_").replace(":","").replace("@","")

func _regenerate_loot_table(category:String,pool:String):
	Globals._generate_loot_tables(category,pool)

func get_player_actor():
	return get_tree().current_scene.get_node("Viewport/main/entities/player")

func _get_map_data(id:String):
	for map_data in Lure.modded_maps:
		if id == map_data.id:
			return map_data
	return null

func map_exists(id):
	for map_data in Lure.modded_maps:
		if id == map_data.id:
			#print(PREFIX+"Map with ID ",id," is currently installed.")
			return true
	return false
