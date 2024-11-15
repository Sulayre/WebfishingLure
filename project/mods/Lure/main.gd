extends "res://mods/Lure/classes/lure_mod.gd"

signal mod_loaded(mod)  # mod: LureMod

const LureMod := preload("res://mods/Lure/classes/lure_mod.gd")
const Loader := preload("res://mods/Lure/modules/loader.gd")
const LureSave := preload("res://mods/Lure/modules/lure_save.gd")
const Utils := preload("res://mods/Lure/utils.gd")
const Wardrobe := preload("res://mods/Lure/modules/wardrobe.gd")

var mods: Dictionary setget _set_nullifier
var content: Dictionary setget _set_nullifier
var actors: Dictionary setget _set_nullifier

var species_indices: Array = ["species_cat", "species_dog"]

var _mod_node_names: Array
var _content_node_names: Array


func _ready() -> void:
	get_tree().connect("node_added", self, "_node_catcher", [], CONNECT_DEFERRED)
	UserSave.connect("_slot_saved", self, "_on_slot_saved")

	print_message("I'm ready!")


# Returns a mod matching the given mod ID
func get_mod(mod_id: String) -> LureMod:
	return mods.get(mod_id)


# Get content resources of a specific category
func get_content_of_category(category: String) -> Array:
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
	Loader.add_resource(lure_id, resource)
	content[lure_id] = resource
	_content_node_names.append(node_name)

	print_message(
		'Registered new Lure {type} "{id}"'.format({"type": resource.type, "id": lure_id})
	)
	
	if resource is LureActor:
			actors[resource.id] = resource
	
	elif resource is LureItem and resource.category == "furniture":
		var actor_resource:LureActor = resource.prop_resource
		if !actor_resource:# we check if the item even has an actor resource attached
			return
		if !actor_resource.actor_scene:# we check if it has a scene assigned (it resets when using ids)
			return
		# we check if the actor is internal so we can add it to the actor list with the item id + suffix
		if actor_resource.resource_path.begins_with(resource.resource_path):
			actor_resource.internal_actor = true
			actor_resource.id = resource.id + ".prop"
			actors[actor_resource.id] = actor_resource
		# we make the prop_code "resource" and later lao the prop with it, most props probably have not
		# loaded yet so can we grab the prop data directly from here and then get the actor_id when we send
		# the packet when realistically all props will be loaded and have their ids generated
		resource.prop_code = "resource"
	
	if (
			resource is LureCosmetic
			and resource.category == "species"
	):
		species_indices.append(lure_id)
		var content_index = species_indices.size() - 1
		resource.dynamic_species_id = content_index

		Wardrobe.extend_vanilla_patterns(
			[
				Globals.cosmetic_data.get("pattern_calico"),
				Globals.cosmetic_data.get("pattern_collie"),
				Globals.cosmetic_data.get("pattern_spotted"),
				Globals.cosmetic_data.get("pattern_tux"),
			],
			resource
		)

		Wardrobe.refresh_body_patterns(get_content_of_category("pattern"), species_indices)


# Register a mod with Lure
# Do not call this if you don't know what you're doing: Mod registry is automatic.
func register_mod(mod: LureMod) -> void:
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

		if resource.lure_flags & LureContent.Flags.AUTOLOAD:
			call_deferred("register_resource", id, content_id, resource)

	print_message('Registered new Lure mod "%s"' % mod_id)
	emit_signal("mod_loaded", mod)


# Actions to perform when nodes are added to the scene tree
func _node_catcher(node: Node):
	var is_main_menu: bool = node.name == "main_menu"
	var is_save_menu: bool = (
		node.name == "save_select"
		or node.name.begins_with("@save_select@") and node.get_parent().name != "main_menu"
	)
	var is_player: bool = "player" in node.get_groups()

	if is_main_menu:
		_save_slot_loaded()
	elif is_save_menu:
		node.connect("_pressed", self, "_save_slot_loaded", [], CONNECT_DEFERRED)
	elif is_player:
		Wardrobe.setup_player(node, {"species_array": get_content_of_category("species")})


# Set up Lure content
func _save_slot_loaded() -> void:
	var save_slot: int = UserSave.current_loaded_slot

	if save_slot == -1:  # No save slot selected
		return

	# Insert Lure save data into PlayerData
	var lure_save: Dictionary = LureSave.load_data(save_slot)
	if lure_save:
		LureSave.initialise_data(lure_save, PlayerData)

	for id in content.keys():
		if not content[id] is LureCosmetic:
			continue
		if content[id].lure_flags & LureContent.Flags.AUTO_UNLOCK:
			Wardrobe.unlock_cosmetic(id)


# Save Lure data to file
func _on_slot_saved() -> void:
	var save_slot: int = UserSave.current_loaded_slot

	# Filter out Lure content from PlayerData
	var lure_save: Dictionary = LureSave.filter_player_data(
		content.keys(),
		{
			"inventory": PlayerData.inventory,
			"cosmetics_unlocked": PlayerData.cosmetics_unlocked,
			"cosmetics_equipped": PlayerData.cosmetics_equipped,
			"bait_inv": PlayerData.bait_inv,
			"bait_selected": PlayerData.bait_selected,
			"bait_unlocked": PlayerData.bait_unlocked,
			"journal_logs": PlayerData.journal_logs,
			"lure_selected": PlayerData.lure_selected,
			"lure_unlocked": PlayerData.lure_unlocked,
			"saved_aqua_fish": PlayerData.saved_aqua_fish
		}
	)
	LureSave.save_data(save_slot, lure_save)


# Prevents other scripts from modifying core variables
func _set_nullifier(_v) -> void:
	return
