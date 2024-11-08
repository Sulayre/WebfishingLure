extends "res://mods/Lure/classes/lure_content.gd"

export  var name = "cos name"
export (String, MULTILINE) var desc = "cos desc"
export  var title = ""
export (Texture) var icon
export (Mesh) var mesh

var species_alt_mesh = []
export (Dictionary) var species_alt_mesh_plus = {
	"species_id": null,
}
export (Skin) var mesh_skin
export (Material) var material
export (Material) var secondary_material
export (Material) var third_material
export (Color) var main_color = Color(1.0, 1.0, 1.0, 1.0)

var body_pattern
export (Dictionary) var body_pattern_plus = {
	"body": preload("res://Assets/Textures/Cosmetics/body_pattern_tux.png"),
	"species_cat": preload("res://Assets/Textures/Cosmetics/body_pattern_tux_cat.png"),
	"species_dog": preload("res://Assets/Textures/Cosmetics/body_pattern_tux_dog.png"),
	"mod_species_id": null,
}
export (PackedScene) var scene_replace

export  var mirror_face = true
export  var flip = false
export  var allow_blink = true
export (Texture) var alt_eye
export (Texture) var alt_blink

export (String, "species", "primary_color", "secondary_color", "eye", "nose", "mouth", "hat", "undershirt", "overshirt", "accessory", "bobber", "pattern", "title", "tail", "legs") var category = ""
export  var cos_internal_id = 0

var dynamic_species_id:int
var dynamic_body_pattern_id:int

export  var in_rotation = false
export  var chest_reward = false
export  var cost = 10
