extends Node
var Lure:Node

const PREFIX = "[LURE/PRINTER]: "

onready var _logs = {
		Lure.MOD_NOT_FOUND:"Your mod was not found, make sure the mod_id argument is the same as the name of your mod's folder",
		Lure.NEIGHBOR_MOD_NOT_FOUND:"The mod you're trying to load your resource from was not found, make sure the ",
		Lure.RESOURCE_PATH_INVALID: "Resource path invalid, make your resource path start with 'mod://', then search like your mod folder is the root.",
		Lure.RESOURCE_NOT_FOUND: "Resource path is valid but the resource you're trying to load was not found, verify your resource's path in your mod folder!",
		Lure.RESOURCE_UNKNOWN_ERROR: "An unknown error has occured while trying to find the resource file inside your mod, sorry!",
		Lure.RESOURCE_CLASS_INCORRECT: "Resource file was found and it was successfully loaded, but its neither a Cosmetic nor an Item, what are you trying to do?",
		# [Buffer Errors]
		Lure.PATTERN_TEXTURE_MISSING: "Pattern texture path not found, check the path!",
		Lure.ALTERNATIVE_MESH_MISSING: "Alternative mesh path not found, check the path!",
		Lure.SPECIES_ANIMATION_MISSING: "Species animation path not found, check the path!",
		Lure.VOICE_BARK_MISSING: "Species' bark sound file is missing, check the path!",
		Lure.VOICE_SECONDARY_MISSING: "Either the Growl or the Whine sound is missing, it will be replaced by the bark.",
		Lure.TEXTURE_BUFFER_MISSING_PATTERN_REFERENCE: "Stored texture buffer data references a non-existing pattern, however it may be found in a future refresh, skipping!",
		Lure.TEXTURE_BUFFER_MISSING_SPECIES_REFERENCE: "Stored texture buffer data references a non-existing species, however it may be found in a future refresh, skipping!",
		Lure.MESH_BUFFER_MISSING_COSMETIC_REFERENCE: "Stored mesh buffer data references a non-existing cosmetic, however it may be found in a future refresh, skipping!",
		Lure.MESH_BUFFER_MISSING_SPECIES_REFERENCE: "Stored mesh buffer data references a non-existing species, however it may be found in a future refresh, skipping!",
		# [Animation Patch Errors]
		Lure.SPECIES_ANIMATION_UNREGISTERED: "This species doesn't have a face animation attached to it! make sure you buffer the animation that contains the offset data with the 'assign_face_animation' function.",
		Lure.PROPS_SCENE_MISSING: "The scene for the prop you're trying to register is missing, make sure the path is right!",
		Lure.ACTION_NODE_NULL: "Tried storing or calling an action on an null node reference.",
		Lure.ACTION_FUNCTION_MISSING: "Tried to store a function that doesn't exist as an action",
		Lure.ACTION_MISSING: "Attempted to execute a missing action, did you forget to assign it?",
		Lure.SAVE_UNKNOWN: "Separate save file for Lure data was found but there was an unknown error loading it, sorry!"
}

func out(logid,error:bool=false):
	if !_logs.keys().has(logid): print(PREFIX+"Invalid log ID")
	if !error:
		print(PREFIX+_logs[logid])
	else:
		printerr(PREFIX+_logs[logid])
