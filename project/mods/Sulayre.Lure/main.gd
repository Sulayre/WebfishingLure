extends Node

# MODULES // this is so stinky im so sorry
const _modules = {
	"Patches":	preload("res://mods/Sulayre.Lure/Modules/Patches.gd"),
	"Util":		preload("res://mods/Sulayre.Lure/Modules/Util.gd"),
	"Loader":	preload("res://mods/Sulayre.Lure/Modules/Loader.gd"),
	"Printer":	preload("res://mods/Sulayre.Lure/Modules/Printer.gd"),
	"Mapper":	preload("res://mods/Sulayre.Lure/Modules/Mapper.gd")
}

const prompt = preload("res://mods/Sulayre.Lure/Scenes/MainMenu/BonusContentPrompt.tscn")

var Patches
var Util
var Buffer
var Loader
var Printer
var Mapper

# ENUMS
enum FLAGS {
	SHOP_POSSUM, # THESE
	SHOP_FROG, # ARE
	SHOP_BEACH, # UNUSED !!!!
	FREE_UNLOCK,
	LOCK_AFTER_SHOP_UPDATE,
	VENDING_MACHINE,
}

# don't use this its obsolete its only for old lure mods to work
enum LURE_FLAGS {
	SHOP_POSSUM,
	SHOP_FROG,
	SHOP_BEACH,
	FREE_UNLOCK,
}


enum {
	MOD_NOT_FOUND,
	NEIGHBOR_MOD_NOT_FOUND,
	RESOURCE_PATH_INVALID,
	RESOURCE_NOT_FOUND,
	RESOURCE_UNKNOWN_ERROR,
	RESOURCE_CLASS_INCORRECT,
	PATTERN_TEXTURE_MISSING,
	ALTERNATIVE_MESH_MISSING,
	SPECIES_ANIMATION_MISSING,
	TEXTURE_BUFFER_MISSING_PATTERN_REFERENCE,
	TEXTURE_BUFFER_MISSING_SPECIES_REFERENCE,
	MESH_BUFFER_MISSING_COSMETIC_REFERENCE,
	MESH_BUFFER_MISSING_SPECIES_REFERENCE,
	SPECIES_ANIMATION_UNREGISTERED,
	ASSIGNED_NOT_ANIMATION,
	VOICE_BARK_MISSING,
	VOICE_SECONDARY_MISSING,
	PROPS_SCENE_MISSING,
	ACTION_NODE_NULL,
	ACTION_FUNCTION_MISSING,
	ACTION_MISSING,
	SAVE_UNKNOWN,
	MAP_NOT_FOUND,
}

# CONSTANTS
const ID = "Sulayre.Lure"
const MODS_FOLDER = "res://mods"

const OWN_MOD_PREFIX = "mod://"
const PREFIX = "[LURE/MAIN]: "

const VANILLA_SPECIES = ["species_cat","species_dog"]

# SIGNALS
signal main_menu_enter
signal game_enter
signal world_enter
signal _vanilla_saved
signal lurlog(log_id,error)
signal mod_map_loaded

# ONREADY VARIABLES
onready var root = get_tree().root
# VARIABLES

var dir = Directory.new()
var bonus_prompt = false

var loaded_cosmetics = []
var loaded_items = []

var vanilla_cosmetics = []
var vanilla_items = []

var texture_buffer = []
var mesh_buffer = []
var animation_buffer = {}

var modded_voices = {}
var modded_actors = {}
var modded_maps = []

var modded_species = []

var action_references = {}

var launch_args = OS.get_cmdline_args()

var cosmetic_list:Dictionary = {}
var item_list:Dictionary = {}
var _savewaiter:Thread = Thread.new()
# godot calls

func _init():
	modded_species.append_array(VANILLA_SPECIES)
	

func _enter_tree():
	_load_modules()
	if OS.has_feature("editor") and PlayerData.has_signal("_loaded_save"):
		yield(PlayerData,"_loaded_save")
	vanilla_cosmetics = Globals.cosmetic_data.keys()
	vanilla_items = Globals.item_data.keys()
	var lurekittrack = AudioStreamPlayer.new()
	lurekittrack.name = "lurekit_menu"
	lurekittrack.stream = preload("res://mods/Sulayre.Lure/creativeinstrumental.mp3")
	GlobalAudio.add_child(lurekittrack)
	#Loader._load_modded_save_data()

# very stupid boilerplate since i did some tweaks on my decomp for testing so it doesnt break for yall
func _ready():
	if OS.has_feature("editor") and !PlayerData.has_signal("_loaded_save"):
		vanilla_cosmetics = Globals.cosmetic_data.keys()
		vanilla_items = Globals.item_data.keys()
	#var secretdata = {"kade":[]} if OS.has_feature("editor") else Util._secret_parser()
	_signals()
	if OS.has_feature("editor"):
		_bonus_content_load()
	else:
		_options_check()
	if "lurekit" in launch_args:
		get_tree().change_scene("res://mods/Sulayre.Lure/Scenes/LureKit/LureKitMain.tscn")
	
	
func register_action(mod_id:String,action_id:String,function_holder:Node,function_name:String):
	if Util._validate_paths(mod_id,"res://"):
		if !function_holder:
			Printer.out(ACTION_NODE_NULL,true)
			return
		if !function_holder.has_method(function_name):
			Printer.out(ACTION_FUNCTION_MISSING,true)
		action_references[mod_id+"."+action_id] = [function_holder,function_name]

# Stores a voice bank for a specific modded species.
func assign_species_voice(mod_id:String,species_id:String,bark_path:String,growl_path:String="",whine_path:String=""):
	if Util._validate_paths(mod_id,bark_path):
		var real_bark = Util._mod_path_converter(mod_id,bark_path)
		var real_growl = real_bark
		var real_whine = real_bark
		if Util._validate_paths(mod_id,growl_path):
			real_growl = Util._mod_path_converter(mod_id,growl_path)
		if Util._validate_paths(mod_id,whine_path):
			real_whine = Util._mod_path_converter(mod_id,whine_path)
		if real_growl == real_bark or real_whine == real_bark:
			Printer.out(VOICE_SECONDARY_MISSING)
		var bark_res = load(real_bark)
		var growl_res = load(real_growl)
		var whine_res = load(real_whine)
		modded_voices[species_id] = {
			"bark": bark_res,
			"growl": growl_res,
			"whine": whine_res
		}
		#print(modded_voices)
	else:
		Printer.out(VOICE_BARK_MISSING,true)

# Adds a new map into the map selector
func add_map(mod_id:String,map_id:String,scene_path:String,map_name:String=""):
	if Util._validate_paths(mod_id,scene_path):
		var real_path = Util._mod_path_converter(mod_id,scene_path)
		var map:PackedScene = load(real_path)
		if !map:
			Printer.out(MAP_NOT_FOUND,true)
			return
		var final_id = mod_id+"."+map_id
		if map_name == "": map_name = final_id
		modded_maps.append(
			{
				"id":final_id,
				"scene":map,
				"name":map_name
			}
		)
		print(PREFIX+"Map with ID ",map_id," has been added successfully!")

# Stores face animation data for a specific modded species.
func assign_face_animation(mod_id:String,species_id:String,animation_path:String):
	if Util._validate_paths(mod_id,animation_path):
		var real_path = Util._mod_path_converter(mod_id,animation_path)
		var animation:Animation = load(real_path)
		if !animation:
			Printer.out(SPECIES_ANIMATION_MISSING,true)
			return
		animation_buffer[species_id] = animation

# stores an alternative mesh for a cosmetic and dynamically sets it up so you can have custom patterns
# for both vanila and modded species
# (you can add meshes for other people's modded species btw!)
func assign_cosmetic_mesh(mod_id:String,cosmetic_id:String,species_id:String,mesh_path:String):
	if Util._validate_paths(mod_id,mesh_path):
		var real_path = Util._mod_path_converter(mod_id,mesh_path)
		var mesh:Mesh = load(real_path)
		if !mesh:
			Printer.out(ALTERNATIVE_MESH_MISSING,true)
			return
		mesh_buffer.append(
			{
				"cosmetic":cosmetic_id,
				"species":species_id,
				"mesh":mesh
			}
		)
		#print(PREFIX+"buffered alternative mesh for cosmetic "+ cosmetic_id + " for species "+species_id)

# stores a texture and dynamically sets it up so you can have custom patterns
# for both vanila and modded species
# (you can add textures for other people's modded species btw!)
func assign_pattern_texture(mod_id:String,pattern_id:String,species_id:String,texture_path:String):
	if Util._validate_paths(mod_id,texture_path):
		var real_path = Util._mod_path_converter(mod_id,texture_path)
		var texture:Texture = load(real_path)
		if !texture:
			Printer.out(PATTERN_TEXTURE_MISSING,true)
			return
		texture_buffer.append(
			{
				"pattern":pattern_id,
				"species":species_id,
				"texture":texture
			}
		)
		#print(PREFIX+"buffered texture for pattern "+pattern_id + " and species "+species_id)
		#_refresh_patterns()

func register_prop(mod_id:String,identifier:String,scene_path:String):
	print(PREFIX+"Mod with ID ",mod_id," is calling the register_props function which is obsolete, use add_actor instead!")
	add_actor(mod_id,identifier,scene_path)

func add_actor(mod_id:String,identifier:String,scene_path:String):
	var scene:PackedScene = load(Util._mod_path_converter(mod_id,scene_path))
	if scene:
		modded_actors[mod_id+"."+identifier] = scene
	else:
		Printer.out(PROPS_SCENE_MISSING,true)
		return
	#print(modded_props)

func add_content(mod_id:String,resource_id:String,resource_path:String, flags:Array=[FLAGS.LOCK_AFTER_SHOP_UPDATE]):
	var data = {
		"mod":	mod_id,
		"id":	resource_id,
		"file":	resource_path,
		"flags":[]
	}
	data.mod = mod_id
	data.item = resource_id
	data.file = resource_path
	data.flags = flags
	
	if Util._validate_paths(mod_id,resource_path):
		Loader._register_resource(data)

# gives you the res:// path of another mod using the relative path
func get_other_mod_asset_path(path:String):
	if !path.begins_with("mods/"): return null
	var slice = path.get_slice("/",1)
	var id = slice.get_slice("://",0)
	return path.replace("mods/"+id+"://",MODS_FOLDER.plus_file(id)+"/")

#module loader
func _load_modules():
	var listing = "[/root/"+name+"]"
	for k in _modules.keys():
		var code = _modules[k]
		var node = code.new()
		node.name = k
		add_child(node)
		listing += "\n\tL[/"+k+"]"
		set(k,node)
		node.set("Lure",self)
		prints(get(k),node.name)
	print(PREFIX+"Modules loaded.")
	connect("lurlog",Printer,"out")
	print(listing)

# extra shit
func _options_check():
	var file = File.new()
	print(PREFIX+"searching for gdweave options json")
	if file.open(OS.get_executable_path().get_base_dir().plus_file("GDWeave/configs/Sulayre.Lure.json"),File.READ) == OK:
		var p = JSON.parse(file.get_as_text())
		file.close()
		var result = p.result
		if typeof(result) == TYPE_DICTIONARY:
			print(PREFIX+"checking options")
			if result["bonus_prompt"]:
				print(PREFIX+"bonus content prompt")
				bonus_prompt = true
			elif result["bonus_content"]:
				print(PREFIX+"bonus content on")
				_bonus_content_load()

func _bonus_content_load():
	add_content("Sulayre.Lure","kade_shirt","mod://Resources/Cosmetics/undershirt_graphic_tshirt_kade.tres")
	add_content("Sulayre.Lure","misname_title","mod://Resources/Cosmetics/title_misname.tres")
	#add_map("Sulayre.Lure","test_map","mod://Scenes/Maps/example_map.tscn","Lure Test Map")
# 3.5 sucks ass
func _filter_save(new_save:Dictionary) -> Dictionary:
	if Patches:
		if Patches.has_method("_filter_save"):
			return Patches._filter_save(new_save)
		#printerr(PREFIX+"The save filtering method was not found dude this shit makes no sense")
	#printerr(PREFIX+"The patches node was not found for whatever reason.")
	return new_save

# Signal Calls

func _signals():
	root.connect("child_entered_tree",self,"_on_enter")
	
	self.connect("main_menu_enter",Mapper,"_on_main")
	
	self.connect("world_enter",Mapper,"_load_map")

func _on_enter(node:Node):
	if node.name == "main_menu":
		if bonus_prompt: node.add_child(prompt.instance())
		node.add_child_below_node(node.get_node("TextureRect2"),preload("res://mods/Sulayre.Lure/Scenes/MainMenu/LureKitButton.tscn").instance())
		Mapper.selected_map = null
		emit_signal("main_menu_enter")
	if node.name == "world":
		print("world enter")
		node.get_node("Viewport/main/entities").connect("child_entered_tree",Mapper,"_refresh_players")
		emit_signal("world_enter")

# Actions

func _test_action(arg1):
	print("action pressed + ",arg1)

func _test_release():
	print("action released")
