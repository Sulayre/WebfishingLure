extends Node

signal mod_loaded(mod) # mod: LureMod
signal mods_loaded

const LureMod := preload("res://mods/Lure/classes/lure_mod.gd")
const Loader := preload("res://mods/Lure/modules/loader.gd")
const Wardrobe := preload("res://mods/Lure/modules/wardrobe.gd")

var wardrobe := Wardrobe.new()

var threaded_references: Array = [wardrobe]
var mods: Dictionary setget _set_nullifier
var content_ids: PoolStringArray setget _set_nullifier



# Returns a mod matching the given mod ID
func get_mod(mod_id: String) -> LureMod:
	return mods.get(mod_id)


# Register a mod with Lure
# Do not call this if you don't know what you're doing: Mod registry is automatic.
func _register_mod(mod: LureMod) -> void:
	if (not mod is LureMod) or (mod in mods):
		return
	
	mods[mod.mod_id] = mod
	
	for id in mod.mod_content:
		var lure_id = mod.mod_id + "." + id
		Loader._add_resource(lure_id, mod.mod_content[id])
		content_ids.append(lure_id)


# Prevents other scripts from modifying core variables
func _set_nullifier(value) -> void:
	return
