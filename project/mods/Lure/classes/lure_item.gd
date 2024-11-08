extends "res://mods/Lure/classes/lure_content.gd"

export  var item_name = ""
export (String, MULTILINE) var item_description = ""
export  var catch_blurb = ""
export  var item_is_hidden = false
export (Texture) var icon
export  var show_item = true
export (PackedScene) var item_scene
export  var show_scene = false
export  var uses_size = false
export (Mesh) var mesh
export  var action = ""
export  var action_params = []
export  var release_action = ""
export  var prop_code = ""
export  var help_text = ""
export (float, 0.0, 0.4, 0.1) var arm_value = 0.0
export  var hold_offset = 0.0
export  var unselectable = false
export  var unrenamable = false
export (String, "none", "fish", "bug", "tool", "furniture") var category = "none"
export  var alive = true
export  var tier = 0


export  var catch_difficulty = 1.0
export  var catch_speed = 120.0
export (String, "none", "lake", "ocean", "deep", "prehistoric", "bush_bug", "shoreline_bug", "tree_bug", "seashell", "trash", "water_trash", "rain", "alien", "metal", "void") var loot_table = "none"
export  var loot_weight = 1.0
export  var average_size = 75.0
export  var sell_value = 5
export  var sell_multiplier = 1.0
export  var obtain_xp = 30
export  var generate_worth = true
export  var can_be_sold = true
export  var rare = false
export  var stackable = false
export  var max_stacks = 99
export  var unobtainable = false

export  var show_bait = false
export  var detect_item = false
