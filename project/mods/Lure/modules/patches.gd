extends Reference

#func _custom_species_patterns(mesh:MeshInstance,pattern:CosmeticResource,species:String="none"):
#	var modded_species:Array = Lure.modded_species
#	var index = modded_species.find(species)
#	print(pattern.body_pattern)
#	if modded_species.find(species) != -1:
#		#print("found modded species with index "+index)
#		var variant = pattern.body_pattern[index+1]
#		if variant:
#			print(PREFIX+"Assigned variant "+index+" to species "+species)
#			var material = mesh.material_override
#			material.shader = BODY_COLORS_SHADER
#			mesh.material_override.set_shader_param("texture_albedo", variant)
#			return
#	#if there isn't a texture assigned to the species for this pattern we just
#	#make it solid color
#	mesh.material_override.set_shader_param("texture_albedo", null)
#	#print("running fallback texture")
