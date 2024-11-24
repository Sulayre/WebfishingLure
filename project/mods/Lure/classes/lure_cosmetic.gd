tool
extends "res://mods/Lure/classes/lure_content.gd"

const CATEGORIES := [
	"species",
	"primary_color",
	"secondary_color",
	"eye",
	"nose",
	"mouth",
	"hat",
	"undershirt",
	"overshirt",
	"accessory",
	"bobber",
	"pattern",
	"title",
	"tail",
	"legs",
]

var type: String = "cosmetic"

var name: String = "Cosmetic Name"
var category: String = "" setget _set_category
var desc: String = "Cosmetic Description"
var title: String = ""
var icon: Texture
var main_color: Color = Color(1.0, 1.0, 1.0, 1.0)

var mesh: Mesh
var species_alt_mesh: Array
var extended_alt_mesh: Array = [
	SpeciesAltMesh.new("species_cat"), SpeciesAltMesh.new("species_dog")
] setget _set_alt_mesh_resource
var mesh_skin: Skin
var material: Material
var secondary_material: Material
var third_material: Material

var scene_replace: PackedScene

var body_pattern := [null, null, null]
var extended_body_patterns: Array = [
	BodyPattern.new("body"), BodyPattern.new("species_cat"), BodyPattern.new("species_dog")
] setget _set_pattern_resource

var mirror_face: bool = true
var flip: bool = false
var allow_blink: bool = true
var alt_eye: Texture
var alt_blink: Texture

var face_animation: Animation

var voice_bark: AudioStream
var voice_growl: AudioStream
var voice_whine: AudioStream

var pattern_calico: Texture
var pattern_collie: Texture
var pattern_spotted: Texture
var pattern_tux: Texture

var cos_internal_id: int = 0
var dynamic_species_id: int
var dynamic_body_pattern_id: int

var in_rotation: bool = false
var chest_reward: bool = false
var cost: int = 10


class SpeciesAltMesh:
	extends Resource
	export(String) var species
	export(Mesh) var mesh

	func _init(init_species: String = "", init_mesh: Mesh = Mesh.new()) -> void:
		resource_name = "Alt Mesh"
		species = init_species
		mesh = init_mesh


class BodyPattern:
	extends Resource
	export(String) var species
	export(Texture) var pattern

	func _init(init_species: String = "", init_pattern: Texture = ImageTexture.new()) -> void:
		resource_name = "Body Pattern"
		species = init_species
		pattern = init_pattern


func _get_property_list() -> Array:
	var export_properties: Array = []

	# Lure cosmetic metadata
	export_properties.append_array(
		[
			{
				name = "Metadata",
				type = TYPE_NIL,
				usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE,
			},
			{
				name = "name",
				type = TYPE_STRING,
			},
			{
				name = "category",
				type = TYPE_STRING,
				hint = PROPERTY_HINT_ENUM,
				hint_string = ",".join(CATEGORIES),
			},
			{
				name = "desc",
				type = TYPE_STRING,
				hint = PROPERTY_HINT_MULTILINE_TEXT,
			},
			{
				name = "icon",
				type = TYPE_OBJECT,
				hint = PROPERTY_HINT_RESOURCE_TYPE,
				hint_string = "Texture",
			},
			{
				name = "main_color",
				type = TYPE_COLOR,
			},
			{
				name = "lure_flags",
				type = TYPE_INT,
				hint = PROPERTY_HINT_FLAGS,
				hint_string = ",".join(Flags.keys()),
				usage = PROPERTY_USAGE_DEFAULT,
			},
		]
	)

	match category:
		"title":  # Title data
			export_properties.append_array(
				[
					{
						name = "RichTextLabel",
						type = TYPE_NIL,
						usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE,
					},
					{
						name = "title",
						type = TYPE_STRING,
					},
				]
			)
		"species":  # Species data
			export_properties.append_array(
				[
					{
						name = "Species",
						type = TYPE_NIL,
						usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE,
					},
					{
						name = "face_animation",
						type = TYPE_OBJECT,
						hint = PROPERTY_HINT_RESOURCE_TYPE,
						hint_string = "Animation",
					},
					{
						name = "Voice",
						type = TYPE_NIL,
						hint_string = "voice_",
						usage = PROPERTY_USAGE_GROUP | PROPERTY_USAGE_SCRIPT_VARIABLE
					},
					{
						name = "voice_bark",
						type = TYPE_OBJECT,
						hint = PROPERTY_HINT_RESOURCE_TYPE,
						hint_string = "AudioStream",
					},
					{
						name = "voice_growl",
						type = TYPE_OBJECT,
						hint = PROPERTY_HINT_RESOURCE_TYPE,
						hint_string = "AudioStream",
					},
					{
						name = "voice_whine",
						type = TYPE_OBJECT,
						hint = PROPERTY_HINT_RESOURCE_TYPE,
						hint_string = "AudioStream",
					},
					{
						name = "Vanilla Patterns",
						type = TYPE_NIL,
						hint_string = "pattern_",
						usage = PROPERTY_USAGE_GROUP | PROPERTY_USAGE_SCRIPT_VARIABLE
					},
					{
						name = "pattern_collie",
						type = TYPE_OBJECT,
						hint = PROPERTY_HINT_RESOURCE_TYPE,
						hint_string = "Texture",
					},
					{
						name = "pattern_tux",
						type = TYPE_OBJECT,
						hint = PROPERTY_HINT_RESOURCE_TYPE,
						hint_string = "Texture",
					},
					{
						name = "pattern_calico",
						type = TYPE_OBJECT,
						hint = PROPERTY_HINT_RESOURCE_TYPE,
						hint_string = "Texture",
					},
					{
						name = "pattern_spotted",
						type = TYPE_OBJECT,
						hint = PROPERTY_HINT_RESOURCE_TYPE,
						hint_string = "Texture",
					},
				]
			)
		"pattern":  # Pattern data
			export_properties.append_array(
				[
					{
						name = "Patterns",
						type = TYPE_NIL,
						usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE,
					},
					{
						name = "extended_body_patterns",
						type = TYPE_ARRAY,
						hint = PROPERTY_HINT_TYPE_STRING,
						hint_string = "%s:Resource" % [TYPE_OBJECT],
					},
				]
			)
		"eye":  # Eye data
			export_properties.append_array(
				[
					{
						name = "Face",
						type = TYPE_NIL,
						usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE,
					},
					{
						name = "mirror_face",
						type = TYPE_BOOL,
					},
					{
						name = "flip",
						type = TYPE_BOOL,
					},
					{
						name = "allow_blink",
						type = TYPE_BOOL,
					},
					{
						name = "alt_eye",
						type = TYPE_OBJECT,
						hint = PROPERTY_HINT_RESOURCE_TYPE,
						hint_string = "Texture",
					},
					{
						name = "alt_blink",
						type = TYPE_OBJECT,
						hint = PROPERTY_HINT_RESOURCE_TYPE,
						hint_string = "Texture",
					},
				]
			)

	# Scene and cosmetic mesh data
	if (
		category
		in ["hat", "undershirt", "overshirt", "accessory", "species", "legs", "bobber", "tail"]
	):
		export_properties.append_array(
			[
				{
					name = "PackedScene",
					type = TYPE_NIL,
					usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE,
				},
				{
					name = "scene_replace",
					type = TYPE_OBJECT,
					hint = PROPERTY_HINT_RESOURCE_TYPE,
					hint_string = "PackedScene",
				},
				{
					name = "Mesh",
					type = TYPE_NIL,
					usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE,
				},
				{
					name = "mesh",
					type = TYPE_OBJECT,
					hint = PROPERTY_HINT_RESOURCE_TYPE,
					hint_string = "Mesh",
				},
				{
					name = "mesh_skin",
					type = TYPE_OBJECT,
					hint = PROPERTY_HINT_RESOURCE_TYPE,
					hint_string = "Skin",
				},
				{
					name = "material",
					type = TYPE_OBJECT,
					hint = PROPERTY_HINT_RESOURCE_TYPE,
					hint_string = "Material",
				},
				{
					name = "secondary_material",
					type = TYPE_OBJECT,
					hint = PROPERTY_HINT_RESOURCE_TYPE,
					hint_string = "Material",
				},
				{
					name = "third_material",
					type = TYPE_OBJECT,
					hint = PROPERTY_HINT_RESOURCE_TYPE,
					hint_string = "Material",
				},
			]
		)

		if not category in ["species", "bobber", "tail"]:
			export_properties.append(
				{
					name = "extended_alt_mesh",
					type = TYPE_ARRAY,
					hint = PROPERTY_HINT_TYPE_STRING,
					hint_string = "%s:Resource" % [TYPE_OBJECT],
				}
			)

	# Cosmetic acquisition data
	export_properties.append_array(
		[
			{
				name = "Acquisition",
				type = TYPE_NIL,
				usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE,
			},
			{
				name = "in_rotation",
				type = TYPE_BOOL,
			},
			{
				name = "chest_reward",
				type = TYPE_BOOL,
			},
			{
				name = "cost",
				type = TYPE_INT,
			},
		]
	)

	return export_properties


func _set_category(new_value: String) -> void:
	category = new_value
	property_list_changed_notify()


func _set_alt_mesh_resource(new_value: Array) -> void:
	extended_alt_mesh = new_value

	for i in extended_alt_mesh.size():
		if not extended_alt_mesh[i]:
			extended_alt_mesh[i] = SpeciesAltMesh.new()


func _set_pattern_resource(new_value: Array) -> void:
	extended_body_patterns = new_value

	for i in extended_body_patterns.size():
		if not extended_body_patterns[i]:
			extended_body_patterns[i] = BodyPattern.new()
