extends Node

signal main_menu_enter()
signal game_enter()

const ID = "Sulayre.Lure"
const MODS_FOLDER = "res://mods"
const PREFIX = "[LURE]: "
const OWN_MOD_PREFIX = "mod://"

enum LURE_FLAGS {
	SHOP_POSSUM, # THESE
	SHOP_FROG, # ARE
	SHOP_BEACH, # UNUSED !!!!
	FREE_UNLOCK,
}

enum LOG_ID {
	MOD_NOT_FOUND,
	NEIGHBOR_MOD_NOT_FOUND,
	RESOURCE_PATH_INVALID,
	RESOURCE_NOT_FOUND,
	RESOURCE_UNKNOWN_ERROR,
	RESOURCE_CLASS_INCORRECT,
	PATTERN_TEXTURE_MISSING,
	ALTERNATIVE_MESH_MISSING,
	SPECIES_ANIMATION_MISSING,
	TEXTURE_BUFFER_MISSING_PATTERN_REFERENCE,
	TEXTURE_BUFFER_MISSING_SPECIES_REFERENCE,
	MESH_BUFFER_MISSING_COSMETIC_REFERENCE,
	MESH_BUFFER_MISSING_SPECIES_REFERENCE,
	SPECIES_ANIMATION_UNREGISTERED,
	ASSIGNED_NOT_ANIMATION,
	VOICE_BARK_MISSING,
	VOICE_SECONDARY_MISSING,
}

const LURE_ERRORS = {
	# [Content Loader Errors]
	LOG_ID.MOD_NOT_FOUND:PREFIX + "Your mod was not found, make sure the mod_id argument is the same as the name of your mod's folder",
	LOG_ID.NEIGHBOR_MOD_NOT_FOUND:PREFIX + "The mod you're trying to load your resource from was not found, make sure the ",
	LOG_ID.RESOURCE_PATH_INVALID: PREFIX + "Resource path invalid, make your resource path start with 'mod://', then search like your mod folder is the root.",
	LOG_ID.RESOURCE_NOT_FOUND: PREFIX + "Resource path is valid but the resource you're trying to load was not found, verify your resource's path in your mod folder!",
	LOG_ID.RESOURCE_UNKNOWN_ERROR: PREFIX + "An unknown error has occured while trying to find the resource file inside your mod, sorry!",
	LOG_ID.RESOURCE_CLASS_INCORRECT: PREFIX + "Resource file was found and it was successfully loaded, but its neither a Cosmetic nor an Item, what are you trying to do?",
	# [Buffer Errors]
	LOG_ID.PATTERN_TEXTURE_MISSING: PREFIX + "Pattern texture path not found, check the path!",
	LOG_ID.ALTERNATIVE_MESH_MISSING: PREFIX + "Alternative mesh path not found, check the path!",
	LOG_ID.SPECIES_ANIMATION_MISSING: PREFIX + "Species animation path not found, check the path!",
	LOG_ID.VOICE_BARK_MISSING: PREFIX + "Species' bark sound file is missing, check the path!",
	LOG_ID.VOICE_SECONDARY_MISSING: PREFIX + "Either the Growl or the Whine sound is missing, it will be replaced by the bark.",
	LOG_ID.TEXTURE_BUFFER_MISSING_PATTERN_REFERENCE: PREFIX + "Stored texture buffer data references a non-existing pattern, however it may be found in a future refresh, skipping!",
	LOG_ID.TEXTURE_BUFFER_MISSING_SPECIES_REFERENCE: PREFIX + "Stored texture buffer data references a non-existing species, however it may be found in a future refresh, skipping!",
	LOG_ID.MESH_BUFFER_MISSING_COSMETIC_REFERENCE: PREFIX + "Stored mesh buffer data references a non-existing cosmetic, however it may be found in a future refresh, skipping!",
	LOG_ID.MESH_BUFFER_MISSING_SPECIES_REFERENCE: PREFIX + "Stored mesh buffer data references a non-existing species, however it may be found in a future refresh, skipping!",
	# [Animation Patch Errors]
	LOG_ID.SPECIES_ANIMATION_UNREGISTERED: PREFIX + "This species doesn't have a face animation attached to it! make sure you buffer the animation that contains the offset data with the 'assign_face_animation' function."
}

onready var root = get_tree().root
var dir = Directory.new()

#zea's upgraded shader for body colors
var body_colors_patch = load("res://mods/"+ID+"/Resources/Shaders/body_colors_patch.tres")

var VANILLA_SPECIES = ["species_cat","species_dog"]
var modded_species = []

# resource buffers
var texture_buffer = []
var mesh_buffer = []
var animation_buffer = {}
var modded_voices = {}

# godot calls

func _init():
	modded_species.append_array(VANILLA_SPECIES)

func _ready():
	add_content(ID,"kade_shirt","mod://Resources/Cosmetics/undershirt_graphic_tshirt_kade.tres",[]) # this turns into <Sulayre.Lure.kade_shirt>
	root.connect("child_entered_tree",self,"_on_enter")
	self.connect("main_menu_enter",self,"_add_watermark")

# Stores a voice bank for a specific modded species.
func assign_species_voice(mod_id:String,species_id:String,bark_path:String,growl_path:String="",whine_path:String=""):
	if _validate_paths(mod_id,bark_path):
		var real_bark = _mod_path_converter(mod_id,bark_path)
		var real_growl = real_bark
		var real_whine = real_bark
		if _validate_paths(mod_id,growl_path):
			real_growl = _mod_path_converter(mod_id,growl_path)
		if _validate_paths(mod_id,whine_path):
			real_whine = _mod_path_converter(mod_id,whine_path)
		if real_growl == real_bark or real_whine == real_bark:
			printerr(LURE_ERRORS[LOG_ID.VOICE_SECONDARY_MISSING])
		var bark_res = load(real_bark)
		var growl_res = load(real_growl)
		var whine_res = load(real_whine)
		modded_voices[species_id] = {
			"bark": bark_res,
			"growl": growl_res,
			"whine": whine_res
		}
		#print(modded_voices)
	else:
		printerr(LURE_ERRORS[LOG_ID.VOICE_BARK_MISSING])

# Stores face animation data for a specific modded species.
func assign_face_animation(mod_id:String,species_id:String,animation_path:String):
	if _validate_paths(mod_id,animation_path):
		var real_path = _mod_path_converter(mod_id,animation_path)
		var animation:Animation = load(real_path)
		if !animation:
			print(LURE_ERRORS[LOG_ID.SPECIES_ANIMATION_MISSING])
			return
		animation_buffer[species_id] = animation

# stores an alternative mesh for a cosmetic and dynamically sets it up so you can have custom patterns
# for both vanila and modded species
# (you can add meshes for other people's modded species btw!)
func assign_cosmetic_mesh(mod_id:String,cosmetic_id:String,species_id:String,mesh_path:String):
	if _validate_paths(mod_id,mesh_path):
		var real_path = _mod_path_converter(mod_id,mesh_path)
		var mesh:Mesh = load(real_path)
		if !mesh:
			print(LURE_ERRORS[LOG_ID.ALTERNATIVE_MESH_MISSING])
			return
		mesh_buffer.append(
			{
				"cosmetic":cosmetic_id,
				"species":species_id,
				"mesh":mesh
			}
		)
		print(PREFIX+"buffered alternative mesh for cosmetic "+ cosmetic_id + " for species "+species_id)

# stores a texture and dynamically sets it up so you can have custom patterns
# for both vanila and modded species
# (you can add textures for other people's modded species btw!)
func assign_pattern_texture(mod_id:String,pattern_id:String,species_id:String,texture_path:String):
	if _validate_paths(mod_id,texture_path):
		var real_path = _mod_path_converter(mod_id,texture_path)
		var texture:Texture = load(real_path)
		if !texture:
			print(LURE_ERRORS[LOG_ID.PATTERN_TEXTURE_MISSING])
			return
		texture_buffer.append(
			{
				"pattern":pattern_id,
				"species":species_id,
				"texture":texture
			}
		)
		print(PREFIX+"buffered texture for pattern "+pattern_id + " and species "+species_id)
		#_refresh_patterns()

# loads a new cosmetic or item into the game
# it sets it's name as <mod_id.resource_id>
# the resource id doesn't have to match the filename necessarily
# just make sure the path is right
# if its a cosmetic it saves it in the modded_species array so we can assign
# dynamic ids to patterns and yada yada
func add_content(mod_id:String,resource_id:String,resource_path:String, flags:Array=[LURE_FLAGS.FREE_UNLOCK]):
	var data = {
		"mod":	mod_id,
		"id":	resource_id,
		"file":	resource_path,
		"flags":[]
	}
	data.mod = mod_id
	data.item = resource_id
	data.file = resource_path
	data.flags = flags
	if _validate_paths(mod_id,resource_path):
		_register_resource(data)

# gives you the res:// path of another mod using the relative path
func get_other_mod_asset_path(path:String):
	if !path.begins_with("mods/"): return null
	var slice = path.get_slice("/",1)
	var id = slice.get_slice("://",0)
	return path.replace("mods/"+id+"://",MODS_FOLDER.plus_file(id)+"/")
	
# Refreshers

func _refresh_patterns():
	var patterns = {}
	# we grab all the patterns
	for cosmetic_id in Globals.cosmetic_data.keys():
		var cosmetic_resource = Globals.cosmetic_data[cosmetic_id].file
		if cosmetic_resource.category == "pattern":
			patterns[cosmetic_id] = cosmetic_resource
	#print(patterns)
	# now we organize the textures patterns and species
	for texture_data in texture_buffer:
		var pattern = patterns[texture_data.pattern]
		if !pattern:
			printerr(LURE_ERRORS[LOG_ID.TEXTURE_BUFFER_MISSING_PATTERN_REFERENCE])
			continue
		var found:bool
		for species in modded_species:
			if species == texture_data.species:
				var index = modded_species.find(species)+1
				var length = pattern.body_pattern.size()
				#print(PREFIX+index+" "+length+" ("+length-1+")")
				if index > length-1:
					pattern.body_pattern.resize(index+1)
					#print(PREFIX+"resized")
				pattern.body_pattern[index] = texture_data.texture
				print(PREFIX+"Attached new texture to pattern '"+texture_data.pattern+"' for species '"+texture_data.species+"'")
				found = true
				break
		if !found:
			#print(modded_species)
			printerr(LURE_ERRORS[LOG_ID.TEXTURE_BUFFER_MISSING_SPECIES_REFERENCE])

func _refresh_alt_meshes():
	var cosmetics = {}
	var compatible_categories = [
		"undershirt",
		"overshirt",
		"legs",
		"hat",
		"accessory"
		]
	# we grab all the patterns
	for cosmetic_id in Globals.cosmetic_data.keys():
		var cosmetic_resource = Globals.cosmetic_data[cosmetic_id].file
		for category in compatible_categories:
			if cosmetic_resource.category == category:
				cosmetics[cosmetic_id] = cosmetic_resource
	for mesh_data in mesh_buffer:
		var mesh = cosmetics[mesh_data.cosmetic]
		if !mesh:
			#print(mesh_data.cosmetic," "," ",cosmetics.keys())
			printerr(LURE_ERRORS[LOG_ID.MESH_BUFFER_MISSING_COSMETIC_REFERENCE])
			continue
		var found:bool
		for species in modded_species:
			if species == mesh_data.species:
				var index = modded_species.find(species)
				var length = mesh.species_alt_mesh.size()
				mesh.species_alt_mesh.resize(modded_species.size())
				for i in range(0,mesh.species_alt_mesh.size()):
					if !mesh.species_alt_mesh[i]:
						mesh.species_alt_mesh[i] = mesh.mesh
				mesh.species_alt_mesh[index] = mesh_data.mesh
				print(mesh.species_alt_mesh)
				print(PREFIX+"Attached new alt mesh to cosmetic '"+mesh_data.cosmetic+"' for species '"+mesh_data.species+"'"+"with internal index",index)
				found = true
				break
		if !found:
			#print(modded_species)
			printerr(LURE_ERRORS[LOG_ID.MESH_BUFFER_MISSING_SPECIES_REFERENCE])

# C# Patches

func custom_species_patterns(mesh:MeshInstance,pattern:CosmeticResource,species:String="none"):
	var index = modded_species.find(species)
	print("attempting to assign custom pattern")
	print(PREFIX+species," ",index)
	print(pattern.body_pattern)
	if modded_species.find(species) != -1:
		print("found modded species with index "+index)
		var variant = pattern.body_pattern[index+1]
		if variant:
			print("assigned variant "+index+" to species "+species)
			var material = mesh.material_override
			material.shader = body_colors_patch
			mesh.material_override.set_shader_param("texture_albedo", variant)
			return
	else:
		printerr("dafuck")
	#if there isn't a texture assigned to the species for this pattern we just
	#make it solid color
	mesh.material_override.set_shader_param("texture_albedo", null)
	print("running fallback texture")

func custom_species_faces(player:AnimationPlayer,species_id:String):
	var animation = animation_buffer[species_id]
	print("rrrrrrrrrrr")
	if VANILLA_SPECIES.has(species_id):
		return #the game handles vanilla faces so we don't need this to run here
	elif animation:
		player.add_animation(species_id,animation)
		player.play(species_id)

func instance_species_voices(manager:Spatial):
	print("instancing voices for a player")
	var new_voices = []
	var template = manager.get_node("bark_cat")
	for id in modded_voices.keys():
		print(id)
		for action in modded_voices[id].keys():
			print(action)
			var sound = modded_voices[id][action]
			var new_sound:AudioStreamPlayer3D = template.duplicate()
			var formatted = _specie_sfx_name(action,id)
			new_sound.name = formatted
			var just_in_case:AudioStreamRandomPitch = new_sound.stream.duplicate()
			just_in_case.audio_stream = sound
			new_sound.stream = just_in_case
			manager.add_child(new_sound)
			print(PREFIX+"added SFX '"+formatted+"' to sound manager")

func get_voice_bundle(species_id:String) -> Array:
	# temporary
	match species_id:
		"species_dog":
			return ["bark_dog", "growl_dog", "whine_dog"]
		"species_cat":
			return ["bark_cat", "growl_cat", "whine_cat"]
	var converted_name = _format_node_name(species_id)
	var data = [
		"bark_"+converted_name,
		"growl_"+converted_name,
		"whine_"+converted_name
		]
	print(data)
	return data

# Internal Util

func _mod_path_converter(mod_id:String,path:String):
	if path.begins_with("res://"):
		return path
	return path.replace("mod://",MODS_FOLDER.plus_file(mod_id)+"/")

func _validate_paths(mod:String,path:String) -> bool:
	var folder = MODS_FOLDER.plus_file(mod)
	if !dir.dir_exists(folder):
		printerr(LURE_ERRORS[LOG_ID.MOD_NOT_FOUND])
		return false
	var valid_other_mod = path.begins_with("mods/")
	if path.begins_with(OWN_MOD_PREFIX) or valid_other_mod:
		# mods/modid://
		if valid_other_mod:
			var slice = path.get_slice("/",1)
			var id = slice.get_slice("://",0)
			if dir.dir_exists(MODS_FOLDER.plus_file(id)):
				return true
			else:
				printerr(LURE_ERRORS[LOG_ID.NEIGHBOR_MOD_NOT_FOUND])
				return false
		# mod:// technically 
		return true
	elif path.begins_with("res://"):
		return true
	printerr(LURE_ERRORS[LOG_ID.RESOURCE_PATH_INVALID])
	return false

func _specie_sfx_name(action:String,specie_id) -> String:
	return(action+"_"+_format_node_name(specie_id))

func _format_node_name(name:String) -> String:
	return name.replace(".","_").replace(":","").replace("@","")

func _species_loader(id:String,resource:CosmeticResource):
	if modded_species.has(id):
		print(PREFIX + "Custom species id "+ id + " is already taken! make sure your species ids are unique to avoid mods clashing! Expect UV issues.")
		return
	modded_species.append(id)
	resource.cos_internal_id = modded_species.find(id)
	print(modded_species.size()," ",modded_species)
	#print("species "+id+" now has index ",resource.cos_internal_id)

func _register_resource(resource_data:Dictionary):
	var mod_id = resource_data.mod
	var item_id = resource_data.id
	var final_id = mod_id+"."+item_id
	var res_path = _mod_path_converter(mod_id,resource_data.file)
	match dir.open("res://mods/"+mod_id):
		OK:
			var loaded_resource = load(res_path)
			if loaded_resource is ItemResource:
				Globals.item_data[final_id] = {"file":loaded_resource}
			elif loaded_resource is CosmeticResource:
				Globals.cosmetic_data[final_id] = {"file":loaded_resource}
				match loaded_resource.category:
					"species":
						_species_loader(final_id,loaded_resource)
						_refresh_patterns()
						_refresh_alt_meshes()
					"pattern":
						_refresh_patterns()
				_refresh_alt_meshes()
				if resource_data.flags.has(LURE_FLAGS.FREE_UNLOCK):
					if !PlayerData.cosmetics_unlocked.has(final_id):
						PlayerData.cosmetics_unlocked.append(final_id)
						PlayerData.emit_signal("_inventory_refresh")
						print(PREFIX+final_id+" has the unlock flag but wasn't found in the inventory, unlocking automatically!")
					else:
						print(PREFIX+final_id+" already unlocked, ignoring append")
			else:
				printerr(LURE_ERRORS[5])
				return
			print(PREFIX+final_id+" has been loaded successfully!")
		7:
			printerr(LURE_ERRORS[3])
			return
		_:
			printerr(LURE_ERRORS[4])
			return

# Signal Calls

func _on_enter(node:Node):
	if node.name == "main_menu" and node.is_class("Control"):
		emit_signal("main_menu_enter")

func _add_watermark():
	var prefab:PackedScene =load("res://mods/Sulayre.Lure/Scenes/Watermark.tscn")
	var dupe:Node = prefab.instance()
	get_tree().root.get_node("main_menu").add_child(dupe)
	dupe.visible = true
