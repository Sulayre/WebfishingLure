extends Reference

const LureCosmetic	:= preload("res://mods/Lure/classes/lure_cosmetic.gd")

static func refresh_body_patterns(pattern_resources:Array,species_indexes:Array):
	for pattern in pattern_resources:
		if (
				not pattern is LureCosmetic
				or (pattern.get("category") != "pattern")
		):
			continue
		for species_id in pattern.body_pattern_plus:
			var loaded_index = species_indexes.find(species_id) + 1 # we offset the body texture
			if loaded_index == -1:
				continue
			var length = pattern.body_pattern.size()
			if loaded_index > length-1:
				pattern.body_pattern.resize(loaded_index+1)
			pattern.body_pattern[loaded_index] = pattern.body_pattern_plus[species_id]
