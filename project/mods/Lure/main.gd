extends "res://mods/Lure/classes/lure_mod.gd"

signal mod_loaded(mod) # mod: LureMod

const LureMod := preload("res://mods/Lure/classes/lure_mod.gd")
const Loader := preload("res://mods/Lure/modules/loader.gd")
const Wardrobe := preload("res://mods/Lure/modules/wardrobe.gd")
const Patches := preload("res://mods/Lure/modules/patches.gd")
const Utils := preload("res://mods/Lure/modules/utils.gd")

var mods: Dictionary setget _set_nullifier
var content: Dictionary setget _set_nullifier
var species_indices: Array = [ "species_cat", "species_dog" ]

var _mod_node_names: Array
var _content_node_names: Array


func _ready() -> void:
	get_tree().connect("node_added", self, "_node_catcher", [], CONNECT_DEFERRED)
	
	print_message("I'm ready!")


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


# Print to the terminal
func print_message(message: String) -> void:
	Utils.pretty_print("[[color=#C54400]LURE[/color]] %s" % message)


# Register a mod's content with Lure
# This will be called automatically on mods that have autoload enabled
func register_resource(mod_id: String, content_id: String, resource: LureContent) -> void:
	var lure_id: String = mod_id + "." + content_id
	
	if not resource is LureContent:
		push_warning('Cannot register Lure content "%s": Input is not LureContent' % lure_id)
		return
	
	var node_name = lure_id.validate_node_name()
	if node_name in _content_node_names:
		push_warning('Cannot register Lure content "%s": Content ID already exists' % lure_id)
		return
	
	resource.id = lure_id
	Loader._add_resource(lure_id, resource)
	content[lure_id] = resource
	_content_node_names.append(node_name)
	
	print_message('Registered new Lure {type} "{id}"'.format({
		"type": resource.type,
		"id": lure_id
	}))
	
	if resource is LureCosmetic and resource.category == "species":
		species_indices.append(lure_id)
		var content_index = species_indices.size() - 1
		resource.dynamic_species_id = content_index
		Wardrobe.refresh_body_patterns(get_cosmetics_of_category("pattern"), species_indices)


# Register a mod with Lure
# Do not call this if you don't know what you're doing: Mod registry is automatic.
func _register_mod(mod: LureMod) -> void:
	var id := mod.mod_id
	
	if not mod is LureMod:
		push_warning('Cannot register Lure mod "%s": Input is not LureMod' % id)
		return
	
	var node_name := id.validate_node_name()
	if node_name in _mod_node_names:
		push_warning('Cannot register Lure mod "%s": Mod ID already exists' % id)
		return
	
	mods[id] = mod
	_mod_node_names.append(node_name)
	
	for content_id in mod.mod_content:
		var resource: LureContent = mod.mod_content[content_id]
		
		if resource.autoload:
			register_resource(id, content_id, resource)
	
	print_message('Registered new Lure mod "%s"' % mod_id)
	emit_signal("mod_loaded", mod)


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
