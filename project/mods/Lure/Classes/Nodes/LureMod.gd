extends Node

# PSEUDO-CONSTS / Classes
var Lure:Node setget _set_nullifier, _get_lure
var Prelude:Reference setget _set_nullifier, _get_prelude

# PSEUDO-CONSTS / Variants
var MOD_FOLDER:String = get_script().get_path().get_base_dir() setget _set_nullifier
var MOD_ID:String = MOD_FOLDER.get_slice("/",3) setget _set_nullifier

# MOD's Content
var items = {}
var cosmetics = {}
var actors = {}
var maps = {}

# SETGETS
func _set_nullifier(value) -> void:
	return

func _get_lure() -> Node:
	return get_node_or_null("/root/Lure")

func _get_prelude() -> Reference:
	return Lure.Prelude

func _enter_tree():
	Lure._register_mod(self)

func _ready():
	Lure.select_mod(MOD_ID)
