extends Reference
# res://Scenes/Singletons/UserSave/usersave.gdc

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


static func sanitise_string(Lure: Node, content_id: String):
	return content_id if not content_id in Lure.content.keys() else ""


static func sanitise_array(Lure: Node, content_ids: Array):
	var filtered_ids := []

	for id in content_ids:
		if not id in Lure.content.keys():
			filtered_ids.append(id)

	return filtered_ids


static func sanitise_dictionary(
	Lure: Node, dictionary: Dictionary, check_keys := true, check_values := true
):
	var filtered_dictionary := {}

	for key in dictionary.keys():
		if check_keys and key in Lure.content.keys():
			continue
		if check_values and dictionary[key] in Lure.content.keys():
			filtered_dictionary[key] = ""
			continue
		if dictionary[key] is Dictionary:
			filtered_dictionary[key] = sanitise_dictionary(
				Lure, dictionary[key], check_keys, check_values
			)
			continue

		filtered_dictionary[key] = dictionary[key]

	return filtered_dictionary


static func sanitise_cosmetics_equipped(Lure: Node, cosmetics_equipped: Dictionary):
	var filtered_cosmetics := {}

	for category in cosmetics_equipped.keys():
		if cosmetics_equipped[category] is Array:
			if not category in filtered_cosmetics:
				filtered_cosmetics[category] = []

			for cosmetic in cosmetics_equipped[category]:
				if cosmetic in Lure.content.keys():
					continue

				filtered_cosmetics[category].append(cosmetic)

		elif cosmetics_equipped[category] is String:
			if cosmetics_equipped[category] in Lure.content.keys():
				filtered_cosmetics[category] = FALLBACK_COSMETICS[category]
				continue

			filtered_cosmetics[category] = cosmetics_equipped[category]

	return filtered_cosmetics


static func sanitise_saved_aqua_fish(Lure: Node, saved_aqua_fish: Dictionary):
	if saved_aqua_fish.id in Lure.content.keys():
		return {"id": "empty", "ref": 0, "size": 50.0, "quality": 0}

	return saved_aqua_fish
