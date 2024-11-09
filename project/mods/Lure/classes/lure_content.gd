extends Resource

var Placeholder = PlaceholderResource.new()
var import_resource: Resource = Placeholder setget _import_resource


class PlaceholderResource extends Resource:
	func _init():
		resource_name = "Drop Here"


func _get_property_list() -> Array:
	var export_properties = [{
		name = "Lure Utilities",
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE,
	}, {
		name = "import_resource",
		type = TYPE_OBJECT,
	}]
	
	return export_properties


func _import_resource(resource) -> void:
	import_resource = Placeholder
	
	if not resource is Resource or not resource.get_script():
		return
	
	var script_property_list = resource.get_script().get_script_property_list()
	for property in script_property_list:
		var property_name = property.name
		if not property_name in self:
			continue
		
		self[property_name] = resource[property_name]
		self.property_list_changed_notify()
