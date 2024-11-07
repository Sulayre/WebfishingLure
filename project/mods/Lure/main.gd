extends Node
class_name Lure

# consts
const PRELUDE = preload("res://mods/Lure/prelude.gd")

# not-so-class-nor-constant
var Modules:Dictionary = {
	"Loader": preload("res://mods/Lure/Modules/Loader.gd").new()
} setget _set_nullifier

# signals
signal mod_loaded(mod) # mod => LureMod (Node)
signal mods_loaded

# private vars

# public vars
var mods = {} setget _set_nullifier
var current_mod:Node = null

# INHERITED FUNCTIONS

#func _init():

func _enter_tree():
	_load_modules()

#func _ready():

# SETGETS
## non-lure calls are not allowed to modify the modules
func _set_nullifier(value) -> void:
	return

## get for ModsList so we don't have to define it all the time
func _get_mod_list() -> Array:
	return ModsData.keys()

# ERRORS
## we select another mod to work on
func select_mod(mod_id:String) -> int:
	if mod_id in mods.keys():
		current_mod = mods[mod_id]
		return OK
	return FAILED

# NODES
func get_mod(mod_id:String) -> Node:
	return mods.get(mod_id)

# PSEUDO-PRIVATE / VOID
## instances the nodes for Lure's modules
func _load_modules() -> void:
	for ModName in Modules.keys():
		var ModNode = Modules[ModName]
		add_child(ModNode)
		ModNode.name = ModName

# don't call this if you don't know what you're doing, mod registry is automatic.
func _register_mod(mod:Node) -> void:
	if mod is Prelude.LureMod:
		if !(mod in mods):
			mods[mod.MOD_ID] = mod
