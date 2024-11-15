extends Reference

const LureCosmetic := preload("res://mods/Lure/classes/lure_cosmetic.gd")
const CustomBodyShader := preload("res://mods/Lure/resources/materials/custom_body_shader.tres")

const FALLBACK_COSMETICS = {
	"species": "species_cat",
	"pattern": "pattern_none",
	"primary_color": "pcolor_white",
	"secondary_color": "scolor_tan",
	"hat": "hat_none",
	"undershirt": "shirt_none",
	"overshirt": "overshirt_none",
	"title": "title_rank_1",
	"bobber": "bobber_default",
	"eye": "eye_halfclosed",
	"nose": "nose_cat",
	"mouth": "mouth_default",
	"accessory": [],
	"tail": "tail_cat",
	"legs": "legs_none"
}


# res://Scenes/Entities/Player/player.gdc
static func override_body_pattern(species_id: String, mesh: MeshInstance, pattern: Resource):
	var lure = mesh.get_node_or_null("/root/Lure")
	if not pattern is LureCosmetic and not pattern is CosmeticResource or !lure:
		return

	var species_indices = lure.species_indices
	if not species_id in species_indices:
		return

	var texture_index = species_indices.find(species_id) + 1  # body texture offset
	if texture_index > pattern.body_pattern.size() - 1:
		return

	mesh.material_override.set_shader_param("texture_albedo", pattern.body_pattern[texture_index])


static func get_bark_id(player: Actor, equipped_species: String) -> Array:
	equipped_species = equipped_species.replace(".", "")

	if equipped_species == "species_cat" or equipped_species == "species_dog":
		equipped_species = equipped_species.replace("species_", "")

	var sound_manager = player.get_node("sound_manager")

	var bark_id = "bark_" + equipped_species
	var growl_id = "growl_" + equipped_species
	var whine_id = "whine_" + equipped_species

	return [
		bark_id if sound_manager.has_node(bark_id) else "bark_cat",
		growl_id if sound_manager.has_node(growl_id) else "growl_cat",
		whine_id if sound_manager.has_node(whine_id) else "whine_cat"
	]


# res://Scenes/Singletons/UserSave/usersave.gdc
static func sanitise_string(lure: Node, content_id: String):
	return content_id if not content_id in lure.content.keys() else ""


static func sanitise_array(lure: Node, content_ids: Array):
	var filtered_ids := []

	for id in content_ids:
		if not id in lure.content.keys():
			filtered_ids.append(id)

	return filtered_ids


static func sanitise_dictionary(
	lure: Node, dictionary: Dictionary, check_keys := true, check_values := true
):
	var filtered_dictionary := {}

	for key in dictionary.keys():
		if check_keys and key in lure.content.keys():
			continue
		if check_values and dictionary[key] in lure.content.keys():
			filtered_dictionary[key] = ""
			continue
		if dictionary[key] is Dictionary:
			filtered_dictionary[key] = sanitise_dictionary(
				lure, dictionary[key], check_keys, check_values
			)
			continue

		filtered_dictionary[key] = dictionary[key]

	return filtered_dictionary


static func sanitise_cosmetics_equipped(lure: Node, cosmetics_equipped: Dictionary):
	var filtered_cosmetics := {}

	for category in cosmetics_equipped.keys():
		if cosmetics_equipped[category] is Array:
			if not category in filtered_cosmetics:
				filtered_cosmetics[category] = []

			for cosmetic in cosmetics_equipped[category]:
				if cosmetic in lure.content.keys():
					continue

				filtered_cosmetics[category].append(cosmetic)

		elif cosmetics_equipped[category] is String:
			if cosmetics_equipped[category] in lure.content.keys():
				filtered_cosmetics[category] = FALLBACK_COSMETICS[category]
				continue

			filtered_cosmetics[category] = cosmetics_equipped[category]

	return filtered_cosmetics


static func sanitise_saved_aqua_fish(lure: Node, saved_aqua_fish: Dictionary):
	if saved_aqua_fish.id in lure.content.keys():
		return {"id": "empty", "ref": 0, "size": 50.0, "quality": 0}

	return saved_aqua_fish
