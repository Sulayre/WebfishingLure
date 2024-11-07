extends Node

var Lure: Node
var Prelude: Reference
var mod_folder: String = get_script().get_path().get_base_dir()
var mod_id: String = mod_folder.get_slice("/", 3)

# Lure mod content
var items: Dictionary
var cosmetics: Dictionary
var actors: Dictionary
var maps: Dictionary


func _init() -> void:
	pass


func _enter_tree() -> void:
	Lure = _get_lure()
	Prelude = _get_prelude()
	
	Lure._register_mod(self)


func _ready() -> void:
	pass


# Returns the Lure node
func _get_lure() -> Node:
	return get_node_or_null("/root/Lure")


# Returns the Prelude reference
func _get_prelude() -> Reference:
	return Lure.Prelude if Lure else null
