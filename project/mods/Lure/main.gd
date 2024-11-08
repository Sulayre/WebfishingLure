extends Node

# warning-ignore:unused_signal
signal mod_loaded(mod) # mod: LureMod

const LureMod := preload("res://mods/Lure/classes/lure_mod.gd")

const Loader := preload("res://mods/Lure/modules/loader.gd")
const Wardrobe := preload("res://mods/Lure/modules/wardrobe.gd")
const Patches := preload("res://mods/Lure/modules/patches.gd")

const LureContent := preload("res://mods/Lure/classes/lure_content.gd")
const LureItem := preload("res://mods/Lure/classes/lure_item.gd")
const LureCosmetic := preload("res://mods/Lure/classes/lure_cosmetic.gd")

var mods: Dictionary setget _set_nullifier
var content_ids: PoolStringArray setget _set_nullifier
var content_resources: Array setget _set_nullifier
var species_indexes: Array setget _set_nullifier, _get_species_indexes


# Returns a mod matching the given mod ID
func get_mod(mod_id: String) -> LureMod:
	return mods.get(mod_id)


# Get cosmetic resources of a specific category
func get_cosmetics_of_category(category: String) -> Array:
	var matching_resources: Array = []
	
	for resource in content_resources:
		if not resource is LureCosmetic:
			continue
		if resource.category == category:
			matching_resources.append(resource)
	
	return matching_resources


# Register a mod with Lure
# Do not call this if you don't know what you're doing: Mod registry is automatic.
func _register_mod(mod: LureMod) -> void:
	if (not mod is LureMod) or (mod in mods):
		return
	
	mods[mod.mod_id] = mod
	
	for id in mod.mod_content:
		var lure_id: String = mod.mod_id + "." + id
		var content: LureCosmetic = mod.mod_content[id]
		
		Loader._add_resource(lure_id, content)
		content_ids.append(lure_id)
		content_resources.append(content)
		
		if content is LureCosmetic and content.category == "species":
			species_indexes.append(lure_id)
			var content_index = species_indexes.size() - 1
			content.dynamic_species_id = content_index
			Wardrobe.refresh_body_patterns(get_cosmetics_of_category("pattern"), species_indexes)


# Prepend cat and dog to the species index to avoid math
func _get_species_indexes():
	return ["species_cat","species_dog"].append_array(species_indexes)


# Prevents other scripts from modifying core variables
func _set_nullifier(value) -> void:
	return
