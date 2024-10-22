class_name Lure extends Node

signal main_menu_enter()
signal game_enter()

const ID = "Sulayre.Lure"
const MODS_FOLDER = "res://mods"
const PREFIX = "[LURE]: "

enum LURE_FLAGS {
	SHOP_POSSUM,
	SHOP_FROG,
	SHOP_BEACH,
	FREE_UNLOCK,
}

enum LOG_ID {
	MOD_NOT_FOUND,
	RESOURCE_PATH_INVALID,
	RESOURCE_NOT_FOUND,
	RESOURCE_UNKNOWN_ERROR,
	RESOURCE_CLASS_INCORRECT,
	PATTERN_TEXTURE_MISSING,
	BUFFER_MISSING_PATTERN_REFERENCE,
	BUFFER_MISSING_SPECIES_REFERENCE,
	SPECIES_ANIMATION_MISSING,
	SPECIES_ANIMATION_UNREGISTERED,
	ASSIGNED_NOT_ANIMATION,
	VOICE_BARK_MISSING,
	VOICE_SECONDARY_MISSING,
}

const LURE_ERRORS = {
	# [Content Loader Errors]
	LOG_ID.MOD_NOT_FOUND:PREFIX + "Mod not found, make sure the mod_id argument is the same as the name of your mod's folder",
	LOG_ID.RESOURCE_PATH_INVALID: PREFIX + "Resource path invalid, make your resource path start with 'mod://', then search like your mod folder is the root.",
	LOG_ID.RESOURCE_NOT_FOUND: PREFIX + "Resource path is valid but the resource you're trying to load was not found, verify your resource's path in your mod folder!",
	LOG_ID.RESOURCE_UNKNOWN_ERROR: PREFIX + "An unknown error has occured while trying to find the resource file inside your mod, sorry!",
	LOG_ID.RESOURCE_CLASS_INCORRECT: PREFIX + "Resource file was found and it was successfully loaded, but its neither a Cosmetic nor an Item, what are you trying to do?",
	# [Buffer Errors]
	LOG_ID.PATTERN_TEXTURE_MISSING: PREFIX + "Pattern texture path not found, check the path!",
	LOG_ID.SPECIES_ANIMATION_MISSING: PREFIX + "Species animation path not found, check the path!",
	LOG_ID.VOICE_BARK_MISSING: PREFIX + "Species' bark sound file is missing, check the path!",
	LOG_ID.VOICE_SECONDARY_MISSING: PREFIX + "Either the Growl or the Whine sound is missing, it will be replaced by the bark.",
	
	LOG_ID.BUFFER_MISSING_PATTERN_REFERENCE: PREFIX + "Stored texture buffer data references a non-existing pattern, however it may be found in a future refresh, skipping!",
	LOG_ID.BUFFER_MISSING_SPECIES_REFERENCE: PREFIX + "Stored texture buffer data references a non-existing species, however it may be found in a future refresh, skipping!",
	# [Animation Patch Errors]
	LOG_ID.SPECIES_ANIMATION_UNREGISTERED: PREFIX + "This species doesn't have a face animation attached to it! make sure you buffer the animation that contains the offset data with the 'assign_face_animation' function."
}
onready var root = get_tree().root
var dir = Directory.new()

#zea's upgraded shader for body colors
var body_colors_patch = load("res://mods/"+ID+"/Resources/Shaders/body_colors_patch.tres")

const VANILLA_SPECIES = ["body_texture","species_cat","species_dog"]
var modded_species = []

# resource buffers
var texture_buffer = []
var animation_buffer = {}
var modded_voices = {}

func _init():
	# we attach the vanilla species to the modded list since we're overwriting how the game handles shaders and textures
	# ill rework this later so its update friendly cus rn it will break if more vanilla species get added
	modded_species.append_array(VANILLA_SPECIES)

# we use ID a lot because loaded resource ids in lure are <mod_id>.<item_id> to avoid clashing
# assigning pattern textures for vanilla species is optional unless you're overwriting, just replace
# the texture for the corresponding id in the resource's body pattern:
# 0 -> Body texture
# 0 -> Cat texture
# 0 -> Dog texture
#[====================================================================================================================================]
#                          | we tell the assigner in what mod the texture will be
# (ID is my mod's folder)  |  | we tell the assigner what is the id of the pattern we're attaching the texture to
#                          |  |                 | we tell the assigner what is the id of the species this pattern texture will be for
#                          |  |                 |                       | we give the assigner a path relative to the folder of the mod we gave it
func _ready():#            |  |                 |                       |
	assign_pattern_texture(ID,"pattern_calico",		ID+".species_bird",		"mod://Assets/Textures/bird/body_pattern_1_bird.png")
	assign_pattern_texture(ID,"pattern_collie",		ID+".species_bird",		"mod://Assets/Textures/bird/body_pattern_2_bird.png")
	assign_pattern_texture(ID,"pattern_spotted",	ID+".species_bird",		"mod://Assets/Textures/bird/body_pattern_3_bird.png")
	assign_pattern_texture(ID,"pattern_tux",		ID+".species_bird",		"mod://Assets/Textures/bird/body_pattern_4_bird.png")
	assign_pattern_texture(ID,ID+".pattern_custom",	ID+".species_bird",		"mod://Assets/Textures/custom/bird.png")
	
	assign_face_animation(ID,ID+".species_bird","mod://Resources/Animations/bird_face.tres")
	assign_species_voice(ID,ID+".species_bird","mod://Assets/Audio/yipee.ogg")
	
	add_content(ID,"species_bird","mod://Resources/Cosmetics/species_bird.tres") # this turns into <Sulayre.Lure.species_bird>
	add_content(ID,"pattern_custom","mod://Resources/Cosmetics/pattern_custom.tres")
	add_content(ID,"kade_shirt","mod://Resources/Cosmetics/undershirt_graphic_tshirt_kade.tres") # this turns into <Sulayre.Lure.kade_shirt>
	
	root.connect("child_entered_tree",self,"_on_enter")
	self.connect("main_menu_enter",self,"_add_watermark")

func _on_enter(node:Node):
	if node.name == "main_menu" and node.is_class("Control"):
		emit_signal("main_menu_enter")

func _add_watermark():
	var prefab:PackedScene =load("res://mods/Sulayre.Lure/Scenes/Watermark.tscn")
	var dupe:Node = prefab.instance()
	get_tree().root.get_node("main_menu").add_child(dupe)
	dupe.visible = true

# makes sure the mod id is valid (its loaded) and that the path format is proper
func _validate_paths(mod:String,path:String) -> bool:
	var folder = MODS_FOLDER.plus_file(mod)
	if !dir.dir_exists(folder):
		printerr(LURE_ERRORS[LOG_ID.MOD_NOT_FOUND])
		return false
	if !path.begins_with("mod://"): 
		printerr(LURE_ERRORS[LOG_ID.RESOURCE_PATH_INVALID])
		return false
	return true

#this sucks so much im so sorry
func assign_species_voice(mod_id:String,species_id:String,bark_path:String,growl_path:String="",whine_path:String=""):
	if _validate_paths(mod_id,bark_path):
		var real_bark = bark_path.replace("mod://",MODS_FOLDER.plus_file(mod_id)+"/")
		var real_growl = real_bark
		var real_whine = real_bark
		if _validate_paths(mod_id,growl_path):
			real_growl = growl_path.replace("mod://",MODS_FOLDER.plus_file(mod_id)+"/")
		if _validate_paths(mod_id,whine_path):
			real_whine = whine_path.replace("mod://",MODS_FOLDER.plus_file(mod_id)+"/")
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
		print(modded_voices)
	else:
		printerr(LURE_ERRORS[LOG_ID.VOICE_BARK_MISSING])

func assign_face_animation(mod_id:String,species_id:String,animation_path:String):
	if _validate_paths(mod_id,animation_path):
		var real_path = animation_path.replace("mod://",MODS_FOLDER.plus_file(mod_id)+"/")
		var animation:Animation = load(real_path)
		if !animation:
			print(LURE_ERRORS[LOG_ID.SPECIES_ANIMATION_MISSING])
			return
		animation_buffer[species_id] = animation

# stores a texture and dynamically sets it up so you can have custom patterns
# for both vanila and modded species
# (you can add textures to other people's modded species btw!)

func assign_pattern_texture(mod_id:String,pattern_id:String,species_id:String,texture_path:String):
	if _validate_paths(mod_id,texture_path):
		var real_path = texture_path.replace("mod://",MODS_FOLDER.plus_file(mod_id)+"/")
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

func _register_resource(resource_data:Dictionary):
	var mod_id = resource_data.mod
	var item_id = resource_data.id
	var final_id = mod_id+"."+item_id
	var res_path = resource_data.file.replace("mod://",MODS_FOLDER.plus_file(mod_id)+"/")
	match dir.open("res://mods/"+mod_id):
		OK:
			var loaded_resource = load(res_path)
			if loaded_resource is ItemResource:
				Globals.item_data[final_id] = {"file":loaded_resource}
			elif loaded_resource is CosmeticResource:
				Globals.cosmetic_data[final_id] = {"file":loaded_resource}
				match loaded_resource.category:
					"species":
						_species_loader(final_id)
						_refresh_patterns()
					"pattern":
						_refresh_patterns()
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

# stores the custom species in the modded_species array for later use
func _species_loader(id:String):
	if modded_species.has(id):
		print(PREFIX + "Custom species id "+ id + " is already taken! make sure your species ids are unique to avoid mods clashing! Expect UV issues.")
		return
	modded_species.append(id)
	print(modded_species)

func _refresh_patterns():
	var patterns = {}
	# we grab all the patterns
	for cosmetic_id in Globals.cosmetic_data.keys():
		var cosmetic_resource = Globals.cosmetic_data[cosmetic_id].file
		if cosmetic_resource.category == "pattern":
			patterns[cosmetic_id] = cosmetic_resource
	#print(patterns)
	# now we organize the textures patterns and species
	var textures_applied:int
	for texture_data in texture_buffer:
		var pattern = patterns[texture_data.pattern]
		if !pattern:
			printerr(LURE_ERRORS[7])
			continue
		var found:bool
		for species in modded_species:
				if species == texture_data.species:
					var index = modded_species.find(species)
					var length = pattern.body_pattern.size()
					print(PREFIX+index+" "+length+" ("+length-1+")")
					if index > length-1:
						pattern.body_pattern.resize(index+1)
						print(PREFIX+"resized")
					pattern.body_pattern[index] = texture_data.texture
					print(PREFIX+"Attached new texture to pattern '"+texture_data.pattern+"' for species '"+texture_data.species+"'")
					found = true
					textures_applied+=1
					break
		if !found:
			#print(modded_species)
			printerr(LURE_ERRORS[8])

# a C# patch makes player.gd call this function after setting the texture on
# pattern calls, so technically base game's way of setting patterns is obsolete
# since its designed around purely the cat and dog species
func custom_species_patterns(mesh:MeshInstance,pattern:CosmeticResource,species:String="none"):
	var index = modded_species.find(species)
	print("attempting to assign custom pattern")
	print(PREFIX+species," ",index)
	print(pattern.body_pattern)
	if modded_species.find(species) != -1:
		print("found modded species with index "+index)
		var variant = pattern.body_pattern[index]
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

func _format_node_name(name:String) -> String:
	return name.replace(".","_").replace(":","").replace("@","")

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
			new_sound.stream = sound
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

func _specie_sfx_name(action:String,specie_id) -> String:
	return(action+"_"+_format_node_name(specie_id))
