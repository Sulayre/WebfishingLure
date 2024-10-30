extends ViewportContainer

onready var LureKit = get_parent()

func _store_resource(resource:Resource):
	if LureKit.selected_mod_data:
		#there's no way afaik to use match and the is keyword together so
		if resource is CosmeticResource:
			ResourceSaver.save(LureKit.RES_MOD_PATH.plus_file("Resources/Cosmetics"),resource)
		elif resource is ItemResource:
			ResourceSaver.save(LureKit.RES_MOD_PATH.plus_file("Resources/Cosmetics"),resource)
		
