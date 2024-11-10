tool
extends "res://mods/Lure/classes/lure_content.gd"

var item_name: String = "Item Name"
var category: String = "none"
var item_description: String = "Item Description"
var icon: Texture = StreamTexture.new()
var help_text: String = ""

var item_is_hidden: bool = false
var arm_value: float = 0.0
var hold_offset: float = 0.0
var unrenamable: bool = false
var unobtainable: bool = false
var stackable: bool = false
var max_stacks: int = 99
var show_bait: bool = false
var detect_item: bool = false
var alive = true

var item_scene: PackedScene
var show_item: bool = true
var show_scene: bool = false
var unselectable: bool = false

var mesh: Mesh

var action: String = ""
var action_params: Array = []
var release_action: String = ""

var loot_table: String = "none"
var catch_blurb: String = ""
var catch_difficulty: float = 1.0
var catch_speed: float = 120.0
var loot_weight: float = 1.0
var uses_size: bool = false
var average_size: float = 75.0
var rare = false
var tier: int = 0
var obtain_xp: int = 30

var prop_code: String = ""

var can_be_sold = true
var sell_value: int = 5
var sell_multiplier: float = 1.0
var generate_worth: bool = true


func _get_property_list() -> Array:
	var export_properties: Array = [{
		# Lure item metadata
		name = "Metadata",
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE,
	}, {
		name = "item_name",
		type = TYPE_STRING,
	}, {
		name = "category",
		type = TYPE_STRING,
		hint = PROPERTY_HINT_ENUM,
		hint_string = "none,fish,bug,tool,furniture",
	}, {
		name = "item_description",
		type = TYPE_STRING,
		hint = PROPERTY_HINT_MULTILINE_TEXT,
	}, {
		name = "icon",
		type = TYPE_OBJECT,
		hint = PROPERTY_HINT_RESOURCE_TYPE,
		hint_string = "Texture",
	}, {
		name = "help_text",
		type = TYPE_STRING,
		hint = PROPERTY_HINT_MULTILINE_TEXT,
	}, {
		# Lure item properties
		name = "Properties",
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE,
	}, {
		name = "item_is_hidden",
		type = TYPE_BOOL,
	},{
		name = "arm_value",
		type = TYPE_REAL,
		hint = PROPERTY_HINT_RANGE,
		hint_string = "0.0,0.4,0.1",
	}, {
		name = "hold_offset",
		type = TYPE_REAL,
	}, {
		name = "unrenamable",
		type = TYPE_BOOL,
	}, {
		name = "unobtainable",
		type = TYPE_BOOL,
	}, {
		name = "stackable",
		type = TYPE_BOOL,
	}, {
		name = "max_stacks",
		type = TYPE_INT,
	}, {
		name = "show_bait",
		type = TYPE_BOOL,
	}, {
		name = "detect_item",
		type = TYPE_BOOL,
	}, {
		name = "alive",
		type = TYPE_BOOL,
	}, {
		# Lure item scene data
		name = "PackedScene",
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE,
	}, {
		name = "item_scene",
		type = TYPE_OBJECT,
		hint = PROPERTY_HINT_RESOURCE_TYPE,
		hint_string = "PackedScene",
	}, {
		name = "show_item",
		type = TYPE_BOOL,
	}, {
		name = "show_scene",
		type = TYPE_BOOL,
	}, {
		name = "unselectable",
		type = TYPE_BOOL,
	}, {
		# Lure item mesh data
		name = "Mesh",
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE,
	}, {
		name = "mesh",
		type = TYPE_OBJECT,
		hint = PROPERTY_HINT_RESOURCE_TYPE,
		hint_string = "Mesh",
	}, {
		# Lure item script data
		name = "GDScript",
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE,
	}, {
		name = "action",
		type = TYPE_STRING,
	}, {
		name = "action_params",
		type = TYPE_ARRAY,
	}, {
		name = "release_action",
		type = TYPE_STRING,
	}, {
		# Lure item catch data
		name = "Catch",
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE,
	}, {
		name = "loot_table",
		type = TYPE_STRING,
		hint = PROPERTY_HINT_ENUM,
		hint_string = "none,lake,ocean,deep,prehistoric,bush_bug,shoreline_bug,tree_bug,seashell,trash,water_trash,rain,alien,metal,void",
	}, {
		name = "catch_blurb",
		type = TYPE_STRING,
		hint = PROPERTY_HINT_MULTILINE_TEXT,
	}, {
		name = "catch_difficulty",
		type = TYPE_REAL,
	}, {
		name = "catch_speed",
		type = TYPE_REAL,
	}, {
		name = "loot_weight",
		type = TYPE_REAL,
	}, {
		name = "uses_size",
		type = TYPE_BOOL,
	}, {
		name = "average_size",
		type = TYPE_REAL,
	}, {
		name = "rare",
		type = TYPE_BOOL,
	}, {
		name = "tier",
		type = TYPE_INT,
	}, {
		name = "obtain_xp",
		type = TYPE_INT,
	}, {
		# Lure item prop data
		name = "Props",
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE,
	}, {
		name = "prop_code",
		type = TYPE_STRING,
	}, {
		# Lure item reward data
		name = "Value",
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE,
	},{
		name = "can_be_sold",
		type = TYPE_BOOL,
	}, {
		name = "sell_value",
		type = TYPE_INT,
	}, {
		name = "sell_multiplier",
		type = TYPE_REAL,
	}, {
		name = "generate_worth",
		type = TYPE_BOOL,
	}]
	
	return export_properties
