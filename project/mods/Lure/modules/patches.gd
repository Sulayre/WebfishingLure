extends Reference

const LureCosmetic := preload("res://mods/Lure/classes/lure_cosmetic.gd")

static func override_body_pattern(species_id:String,mesh:MeshInstance,pattern:Resource):
	var Lure = mesh.get_node_or_null("/root/Lure")
	if (
			not pattern is LureCosmetic
			or not pattern is CosmeticResource
			or !Lure
	):
		return
	
	var species_index = Lure.species_index
	if not species_id in species_index:
		return
	
	var texture_index = species_index.find(species_id) + 1 # body texture offset
	if texture_index > pattern.body_pattern.size() - 1:
		return

	mesh.material_override.set_shader_param("texture_albedo", pattern.body_pattern[texture_index])
