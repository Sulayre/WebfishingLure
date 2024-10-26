extends Node

# MODULES // this is so stinky im so sorry
const _modules = {
	"Patches":	preload("res://mods/Sulayre.Lure/Modules/Patches.gd"),
	"Util":		preload("res://mods/Sulayre.Lure/Modules/Util.gd"),
	"Loader":	preload("res://mods/Sulayre.Lure/Modules/Loader.gd"),
	"Printer":	preload("res://mods/Sulayre.Lure/Modules/Printer.gd")
}

var Patches
var Util
var Buffer
var Loader
var Printer

# ENUMS
enum LURE_FLAGS {
	SHOP_POSSUM, # THESE
	SHOP_FROG, # ARE
	SHOP_BEACH, # UNUSED !!!!
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
signal _vanilla_saved
signal lurlog(log_id,error)

# ONREADY VARIABLES
onready var root = get_tree().root
var dir = Directory.new()

# VARIABLES

var loaded_cosmetics = []
var loaded_items = []

var vanilla_cosmetics = []
var vanilla_items = []

var texture_buffer = []
var mesh_buffer = []
var animation_buffer = {}

var modded_voices = {}
var modded_props = {}
var modded_species = []

var action_references = {}

var cosmetic_list:Dictionary = {}
var item_list:Dictionary = {}

var _savewaiter:Thread = Thread.new()
# godot calls

func _init():
	modded_species.append_array(VANILLA_SPECIES)

func _enter_tree():
	vanilla_cosmetics = Globals.cosmetic_data.keys()
	vanilla_items = Globals.item_data.keys()
	print(vanilla_cosmetics)
	print(vanilla_items)
	_load_modules()
	Loader._load_modded_save_data()

func _ready():
	register_prop("Zea.Content","bounceshroom","res://mods/Zea.Content/Scenes/mushroom_bounce_prop.tscn")
	add_content(ID,"kade_shirt","mod://Resources/Cosmetics/undershirt_graphic_tshirt_kade.tres") # this turns into <Sulayre.Lure.kade_shirt>
	root.connect("child_entered_tree",self,"_on_enter")
	self.connect("main_menu_enter",self,"_add_watermark")	

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
		print(PREFIX+"buffered alternative mesh for cosmetic "+ cosmetic_id + " for species "+species_id)

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
		print(PREFIX+"buffered texture for pattern "+pattern_id + " and species "+species_id)
		#_refresh_patterns()

func register_prop(mod_id:String,identifier:String,scene_path:String):
	var scene:PackedScene = load(Util._mod_path_converter(mod_id,scene_path))
	if scene:
		modded_props[mod_id+"."+identifier] = scene
	else:
		Printer.out(PROPS_SCENE_MISSING,true)
		return
	print(modded_props)

func add_content(mod_id:String,resource_id:String,resource_path:String, flags:Array=[LURE_FLAGS.FREE_UNLOCK]):
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

# 3.5 sucks ass
func _filter_save(new_save:Dictionary) -> Dictionary:
	if Patches:
		if Patches.has_method("_filter_save"):
			return Patches._filter_save(new_save)
		printerr(PREFIX+"The save filtering method was not found dude this shit makes no sense")
	printerr(PREFIX+"The patches node was not found for whatever reason.")
	return new_save

# Signal Calls
func _on_enter(node:Node):
	if node.name == "main_menu" and node.is_class("Control"):
		emit_signal("main_menu_enter")

func _add_watermark():
	var prefab:PackedScene =load("res://mods/Sulayre.Lure/Scenes/Watermark.tscn")
	var dupe:Node = prefab.instance()
	get_tree().root.get_node("main_menu").add_child(dupe)
	dupe.visible = true

# Actions

func _test_action(arg1):
	print("action pressed + ",arg1)

func _test_release():
	print("action released")
