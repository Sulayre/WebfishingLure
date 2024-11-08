extends Node

signal mod_loaded(mod) # mod: LureMod
signal mods_loaded
# who the fuck puts signals before variable definitions /j
const LureMod		:= preload("res://mods/Lure/classes/lure_mod.gd")

const Loader		:= preload("res://mods/Lure/modules/loader.gd")
const Wardrobe		:= preload("res://mods/Lure/modules/wardrobe.gd")
const Patches		:= preload("res://mods/Lure/modules/patches.gd")

const LureContent	:= preload("res://mods/Lure/classes/lure_content.gd")
const LureCosmetic	:= preload("res://mods/Lure/classes/lure_cosmetic.gd")

var mods: Dictionary setget _set_nullifier
var content_ids: PoolStringArray setget _set_nullifier
var content_resources: Array setget _set_nullifier
var species_indexes:Array = [] setget ,_get_species_indexes


# Returns a mod matching the given mod ID
func get_mod(mod_id: String) -> LureMod:
	return mods.get(mod_id)

# we append the vanilla species so we don't have to do annoying math when we wanna offset vanilla shit
func _get_species_indexes():
	return ["species_cat","species_dog"].append_array(species_indexes)


# Register a mod with Lure
# Do not call this if you don't know what you're doing: Mod registry is automatic.
func _register_mod(mod: LureMod) -> void:
	if (not mod is LureMod) or (mod in mods):
		return
	
	mods[mod.mod_id] = mod
	
	for id in mod.mod_content:
		var lure_id = mod.mod_id + "." + id
		var content:LureCosmetic = mod.mod_content[id]
		Loader._add_resource(lure_id, content)
		content_ids.append(lure_id)
		content_resources.append(content)
		
		if not content is LureCosmetic:
			continue
		elif content.category == "species":
			species_indexes.append(lure_id)
			var content_index = species_indexes.size() - 1
			content.dynamic_species_id = content_index
			Wardrobe.refresh_body_patterns(get_cosm_res_of_cat("pattern"),species_indexes)

# get cosmetic resources of specific category
func get_cosm_res_of_cat(category:String) -> Array:
	var matching_resources:Array
	for cont in content_resources:
		if not cont is Loader.LureCosmetic:
			continue
		if cont.category == category:
			matching_resources.append(cont)
	return matching_resources

# Prevents other scripts from modifying core variables
func _set_nullifier(value) -> void:
	return
