extends Node

var Lure: Node
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
	Lure = $"/root/Lure"
	
	Lure._register_mod(self)


func _ready() -> void:
	pass
