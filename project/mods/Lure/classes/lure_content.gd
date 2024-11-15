extends Resource

var id: String

var autoload = true

var _placeholder = PlaceholderResource.new()
var _import_resource: Resource = _placeholder setget _set_import_resource
var flags: int

enum FLAGS {
	FREE_UNLOCK = 1 << 0,
	SHOP_POSSUM = 1 << 1,
	SHOP_FROG = 1 << 2,
	SHOP_BEACH = 1 << 3,
	SHOP_VENDING_MACHINE = 1 << 4,
}


class PlaceholderResource:
	extends Resource

	func _init():
		resource_name = "Drop Here"


# Loops through all properties in the provided resource
# and assigns their values to matching properties on the current resource
func import_resource(resource: Resource) -> void:
	var property_list: Array = resource.get_script().get_script_property_list()

	for property in property_list:
		var property_name: String = property.name
		if not property_name in self:
			continue

		self[property_name] = resource[property_name]


func _get_property_list() -> Array:
	var export_properties := [
		{
			name = "Lure Utilities",
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE,
		},
		{
			name = "autoload",
			type = TYPE_BOOL,
		},
		{
			name = "_import_resource",
			type = TYPE_OBJECT,
		},
	]

	return export_properties


# Assigning _import_resource will reset its value back to the placeholder
# and import the provided resource into the current resource
func _set_import_resource(new_value) -> void:
	_import_resource = _placeholder

	if new_value is Resource and new_value.get_script():
		import_resource(new_value)

	property_list_changed_notify()
