extends Node

signal mod_loaded(mod) # mod: LureMod
signal mods_loaded

const LureMod := preload("res://mods/Lure/classes/lure_mod.gd")
const MODULES := {
	"Loader": preload("res://mods/Lure/modules/loader.gd"),
}

var mods: Dictionary setget _set_nullifier
var current_mod: Node


func _init() -> void:
	pass


func _enter_tree() -> void:
	_load_modules()


func _ready() -> void:
	pass


# Selects a mod to work on
func select_mod(mod_id: String) -> int:
	if not mod_id in mods.keys():
		return FAILED
	
	current_mod = mods[mod_id]
	return OK


# Returns a mod matching the given mod ID
func get_mod(mod_id: String) -> LureMod:
	return mods.get(mod_id)


# Register a mod with Lure
# Do not call this if you don't know what you're doing: Mod registry is automatic.
func _register_mod(mod: LureMod) -> void:
	if not mod is LureMod:
		return
	
	if not mod in mods:
		mods[mod.mod_id] = mod


# Instances the nodes for Lure's modules
func _load_modules() -> void:
	for module in MODULES.keys():
		var module_node = MODULES[module].new()
		module_node.name = module
		add_child(module_node)


# Prevents other mods from modifying variables
func _set_nullifier(value) -> void:
	return
