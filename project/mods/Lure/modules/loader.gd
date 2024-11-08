extends Reference

const LureContent := preload("res://mods/Lure/classes/lure_content.gd")
const LureItem := preload("res://mods/Lure/classes/lure_item.gd")
const LureCosmetic := preload("res://mods/Lure/classes/lure_cosmetic.gd")

static func _add_resource(resource: Resource) -> void:
	if not resource is LureContent:
		#commit die
		return
	if resource is LureItem:
		_add_item(resource)
	elif resource is LureCosmetic:
		_add_cosmetic(resource)
	
static func _add_item(resource: LureItem) -> void:
	Globals.item_data[resource.lure_id] = {"file":resource}

static func _add_cosmetic(resource: LureCosmetic) -> void:
	Globals.cosmetic_data[resource.lure_id] = {"file":resource}
	PlayerData.cosmetic_reset_lock = true
	PlayerData._unlock_cosmetic(resource.lure_id)
	PlayerData.cosmetic_reset_lock = false
