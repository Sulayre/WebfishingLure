extends Reference

const LureCosmetic := preload("res://mods/Lure/classes/lure_cosmetic.gd")
const Player := preload("res://Scenes/Entities/Player/player.gd")


static func refresh_body_patterns(pattern_resources: Array, species_indexes: Array):
	for pattern in pattern_resources:
		if not pattern is LureCosmetic or pattern.get("category") != "pattern":
			continue

		for species_id in pattern.extended_body_patterns:
			if not species_id in species_indexes:
				continue

			# Offset the body texture by 1 to account for "body"
			var loaded_index := species_indexes.find(species_id) + 1

			var length: int = pattern.body_pattern.size()
			if loaded_index > length - 1:
				pattern.body_pattern.resize(loaded_index + 1)

			pattern.body_pattern[loaded_index] = pattern.extended_body_patterns[species_id]


static func setup_player(player: Player, data: Dictionary):
	setup_player_voice(player, data["species_array"])
	setup_player_face(player, data["species_array"])


static func unlock_cosmetic(id: String, new: bool = false) -> void:
	if not new:
		PlayerData.cosmetic_reset_lock = true

	PlayerData._unlock_cosmetic(id)
	PlayerData.cosmetic_reset_lock = false


static func setup_player_voice(player: Player, species_array: Array):
	var sound_manager: Spatial = player.get_node("sound_manager")

	for species in species_array:
		var voice_sounds := {
			"bark": species.voice_bark, "growl": species.voice_growl, "whine": species.voice_whine
		}

		for sound_id in voice_sounds:
			var sound_resource = voice_sounds[sound_id]
			if !sound_resource:
				continue

			var sfx_node := AudioStreamPlayer3D.new()
			var sfx_resource := AudioStreamRandomPitch.new()

			sfx_resource.audio_stream = sound_resource
			sfx_node.stream = sfx_resource
			sfx_node.name = sound_id + "_" + species.id

			sound_manager.add_child(sfx_node, true)


static func setup_player_face(player: Player, species_array: Array):
	var face_animator: AnimationPlayer = player.get_node(
		"body/player_body/Armature/Skeleton/face/player_face/AnimationPlayer"
	)

	for species in species_array:
		var animation: Animation = species.get("face_animation")
		if animation:
			face_animator.add_animation(species.id, animation)


static func extend_vanilla_patterns(vanilla_patterns: Array, new_species: LureCosmetic):
	for pattern_data in vanilla_patterns:
		if not pattern_data.get("file"):
			continue

		var pattern: CosmeticResource = pattern_data["file"]
		var pattern_id: String = pattern.get_path().get_file().get_basename()
		var species_index := new_species.dynamic_species_id + 1
		var length: int = pattern.body_pattern.size()

		if species_index > length - 1:
			pattern.body_pattern.resize(species_index + 1)

		pattern.body_pattern[species_index] = new_species.get(pattern_id)
