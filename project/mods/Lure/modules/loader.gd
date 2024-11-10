extends Reference

const LureContent := preload("res://mods/Lure/classes/lure_content.gd")
const LureItem := preload("res://mods/Lure/classes/lure_item.gd")
const LureCosmetic := preload("res://mods/Lure/classes/lure_cosmetic.gd")

static func _add_resource(id: String, resource: Resource) -> void:
	if not resource is LureContent:
		return
	
	if resource is LureItem:
		_add_item(id, resource)
	elif resource is LureCosmetic:
		_add_cosmetic(id, resource)

#TODO: do the actions shit - arch btw
static func _add_item(id: String, resource: LureItem) -> void:
	Globals.item_data[id] = { "file": resource }

static func _add_cosmetic(id: String, resource: LureCosmetic) -> void:
	match resource.category:
		"species":
			pass
		"hat", "accessory":
			for species_id in resource.body_pattern_plus:
				if not resource.body_pattern_plus[species_id] is Texture:
					continue
		"pattern":
			pass
		_:
			pass
	
	Globals.cosmetic_data[id] = { "file": resource }


static func _unlock_cosmetic(id: String, new: bool = false) -> void:
	if not new:
		PlayerData.cosmetic_reset_lock = true
	
	PlayerData._unlock_cosmetic(id)
	PlayerData.cosmetic_reset_lock = false
