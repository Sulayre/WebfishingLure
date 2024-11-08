extends "res://mods/Lure/classes/lure_content.gd"

export  var name = "cos name"
export  var desc = "cos desc"
export  var title = ""
export (Texture) var icon
export (Mesh) var mesh
export (Array, Mesh) var species_alt_mesh = []
export (Skin) var mesh_skin
export (Material) var material
export (Material) var secondary_material
export (Material) var third_material
export (Color) var main_color = Color(1.0, 1.0, 1.0, 1.0)
export (Array, Texture) var body_pattern
export (PackedScene) var scene_replace

export  var mirror_face = true
export  var flip = false
export  var allow_blink = true
export (Texture) var alt_eye
export (Texture) var alt_blink

export (String, "species", "primary_color", "secondary_color", "eye", "nose", "mouth", "hat", "undershirt", "overshirt", "accessory", "bobber", "pattern", "title", "tail", "legs") var category = ""
export  var cos_internal_id = 0

export  var in_rotation = false
export  var chest_reward = false
export  var cost = 10
