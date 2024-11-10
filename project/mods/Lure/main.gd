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
var content: Dictionary setget _set_nullifier
var species_indices: Array = [ "species_cat", "species_dog" ]


func _ready() -> void:
	get_tree().connect("node_added", self, "_node_catcher", [], CONNECT_DEFERRED)


func _enter_tree() -> void:
	var LureContent = load("res://mods/Lure/lure_content.gd").new()
	
	get_node("/root").add_child(LureContent)


# Returns a mod matching the given mod ID
func get_mod(mod_id: String) -> LureMod:
	return mods.get(mod_id)


# Get cosmetic resources of a specific category
func get_cosmetics_of_category(category: String) -> Array:
	var matching_resources: Array = []
	
	for resource in content.values():
		if not resource is LureCosmetic:
			continue
		if resource.category == category:
			matching_resources.append(resource)
	
	return matching_resources


# Register a mod with Lure
# Do not call this if you don't know what you're doing: Mod registry is automatic.
func _register_mod(mod: LureMod) -> void:
	if (not mod is LureMod) or (mod.mod_id in mods):
		return
	
	mods[mod.mod_id] = mod
	
	for id in mod.mod_content:
		var lure_id: String = mod.mod_id + "." + id
		var mod_content: LureCosmetic = mod.mod_content[id]
		
		print("Lure: Attempting to add resource %" % id)

		mod_content.id = lure_id
		Loader._add_resource(lure_id, mod_content)
		content[lure_id] = mod_content
		
		if mod_content is LureCosmetic and mod_content.category == "species":
			species_indices.append(lure_id)
			var content_index = species_indices.size() - 1
			mod_content.dynamic_species_id = content_index
			Wardrobe.refresh_body_patterns(get_cosmetics_of_category("pattern"), species_indices)


# checks for relevant nodes when one gets added
func _node_catcher(node: Node):
	if node.name == "main_menu":
		_unlock_cosmetics()
	elif "player" in node.get_groups():
		Wardrobe.setup_player(node, {
			"species_array": get_cosmetics_of_category("species"),
		})


# Loops through lure cosmetics and calls unlock cosmetic
func _unlock_cosmetics() -> void:
	for id in content.keys():
		if not content[id] is LureCosmetic:
			return
		
		Loader._unlock_cosmetic(id)


# Prevents other scripts from modifying core variables
func _set_nullifier(value) -> void:
	return
