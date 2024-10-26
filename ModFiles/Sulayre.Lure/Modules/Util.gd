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

#func _secret_parser() -> Dictionary:
#	var file = File.new()
#	var details = {"kade":[]}
#	if file.open(OS.get_executable_path().get_base_dir().plus_file("GDWeave/configs/Sulayre.Lure.json"),File.READ) == OK:
#		print(PREFIX+"checking config file secret unlocks...")
#		var p = JSON.parse(file.get_as_text())
#		var result = p.result
#		if typeof(result) == TYPE_DICTIONARY:
#			var secrets = OS.get_environment("GODOT_LURE_SECRETS").split("/")
#			for s in result["secrets"]:
#				if s == secrets[0]:
#					print(PREFIX+"kade dev secret unlocked.")
#					details.kade.append(Lure.FLAGS.FREE_UNLOCK)
#	return details
