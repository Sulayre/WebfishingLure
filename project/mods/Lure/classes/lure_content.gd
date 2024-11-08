extends Resource

var resource_id: String
var mod_id: String
var lure_id:String setget ,_get_lure_id

func _get_lure_id():
	return mod_id+"."+resource_id
