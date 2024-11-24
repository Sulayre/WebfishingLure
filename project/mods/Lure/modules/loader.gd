extends Reference

const LureContent := preload("res://mods/Lure/classes/lure_content.gd")
const LureItem := preload("res://mods/Lure/classes/lure_item.gd")
const LureCosmetic := preload("res://mods/Lure/classes/lure_cosmetic.gd")


static func add_resource(id: String, resource: Resource) -> void:
	if not resource is LureContent:
		return

	if resource is LureItem:
		_add_item(id, resource)
	elif resource is LureCosmetic:
		_add_cosmetic(id, resource)


static func _add_item(id: String, resource: LureItem) -> void:
	Globals.item_data[id] = {"file": resource}


static func _add_cosmetic(id: String, resource: LureCosmetic) -> void:
	Globals.cosmetic_data[id] = {"file": resource}
