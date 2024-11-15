tool
extends "res://mods/Lure/classes/lure_content.gd"

export(PackedScene) var actor_scene
export(bool) var host_only
export(int, 1, 256) var max_allowed = 1

func _init():
		resource_name = "Lure Actor"

func _get_property_list() -> Array:
	var export_properties: Array = [{
				name = "lure_flags",
				type = TYPE_INT,
				hint = PROPERTY_HINT_FLAGS,
				hint_string = Flags.keys()[0],
				usage = PROPERTY_USAGE_DEFAULT,
			}]
	return export_properties
