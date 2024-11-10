extends Reference

const LureCosmetic := preload("res://mods/Lure/classes/lure_cosmetic.gd")

static func override_body_pattern(species_id: String, mesh: MeshInstance, pattern: Resource):
	var Lure = mesh.get_node_or_null("/root/Lure")
	if (
			not pattern is LureCosmetic
			and not pattern is CosmeticResource
			or !Lure
	):
		return
	
	var species_indices = Lure.species_indices
	if not species_id in species_indices:
		return
	
	var texture_index = species_indices.find(species_id) + 1 # body texture offset
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
