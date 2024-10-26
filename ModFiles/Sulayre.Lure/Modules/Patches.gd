extends Node
var Lure:Node

const BODY_COLORS_SHADER = preload("res://mods/Sulayre.Lure/Resources/Shaders/body_colors_patch.tres")
const PREFIX = "[LURE/PATCHES]: "

const SAVE_TEMPLATE = {
	"cosmetics_unlocked":[],
	"cosmetics_equipped":{},
	"inventory":[],
	"hotbar":{},
	#"saved_aqua_fish":{},
}

func _custom_species_patterns(mesh:MeshInstance,pattern:CosmeticResource,species:String="none"):
	var modded_species:Array = Lure.modded_species
	var index = modded_species.find(species)
	print(pattern.body_pattern)
	if modded_species.find(species) != -1:
		#print("found modded species with index "+index)
		var variant = pattern.body_pattern[index+1]
		if variant:
			print(PREFIX+"Assigned variant "+index+" to species "+species)
			var material = mesh.material_override
			material.shader = BODY_COLORS_SHADER
			mesh.material_override.set_shader_param("texture_albedo", variant)
			return
	#if there isn't a texture assigned to the species for this pattern we just
	#make it solid color
	mesh.material_override.set_shader_param("texture_albedo", null)
	#print("running fallback texture")

func _custom_species_faces(player:AnimationPlayer,species_id:String):
	var animation = Lure.animation_buffer[species_id]
	#print("rrrrrrrrrrr")
	if Lure.VANILLA_SPECIES.has(species_id):
		return #the game handles vanilla faces so we don't need this to run here
	elif animation:
		player.add_animation(species_id,animation)
		player.play(species_id)

func _instance_species_voices(manager:Spatial):
	print(PREFIX+ "loading modded voices on a new player character.")
	var new_voices = []
	var template = manager.get_node("bark_cat")
	for id in Lure.modded_voices.keys():
		print(id)
		for action in Lure.modded_voices[id].keys():
			print(action)
			var sound = Lure.modded_voices[id][action]
			var new_sound:AudioStreamPlayer3D = template.duplicate()
			var formatted = Lure.Util._specie_sfx_name(action,id)
			new_sound.name = formatted
			var just_in_case:AudioStreamRandomPitch = new_sound.stream.duplicate()
			just_in_case.audio_stream = sound
			new_sound.stream = just_in_case
			manager.add_child(new_sound)
			print(PREFIX+"added SFX '"+formatted+"' to sound manager")

func _get_voice_bundle(species_id:String) -> Array:
	# temporary
	match species_id:
		"species_dog":
			return ["bark_dog", "growl_dog", "whine_dog"]
		"species_cat":
			return ["bark_cat", "growl_cat", "whine_cat"]
	var converted_name = Lure.Util._format_node_name(species_id)
	var data = [
		"bark_"+converted_name,
		"growl_"+converted_name,
		"whine_"+converted_name
		]
	#print(data)
	return data

func _call_action(action_id:String,params:=[]) -> bool:
	var data = Lure.action_references[action_id]
	print(action_id,params)
	if !data:
		return false
	if !data[0]:
		Lure.emit_signal("lurlog",Lure.ACTION_NODE_NULL)
		return false
	data[0].callv(data[1],params)
	return true

func _call_release(action_id) -> bool:
	var data = Lure.action_references[action_id]
	print(action_id)
	if !data:
		return false
	if !data[0]:
		Lure.emit_signal("lurlog",Lure.ACTION_NODE_NULL)
		return false
	data[0].call(data[1])
	return true

func _filter_save(new_save:Dictionary) -> Dictionary:
	var modded_save = SAVE_TEMPLATE.duplicate(true)
	var missing_save = SAVE_TEMPLATE.duplicate(true)
	var filtered_save = new_save.duplicate(true)
	var item_list = Lure.item_list.keys()
	var cosmetic_list = Lure.cosmetic_list.keys()
	var items_vanilla = Lure.vanilla_items
	var cosmetics_vanilla = Lure.vanilla_cosmetics
	print(PREFIX+"Lure is storing modded content on a separate save file to avoid corruption")
	#print(item_list,cosmetic_list)
	var missing = 0
	var filtered_items = []
	for k in modded_save.keys():
		if new_save[k] == null: continue
		match k:
			#"saved_aqua_fish":
			#	if item_list.has(new_save[k]["id"]):
			#		modded_save[k] = new_save[k]["id"]
			#		filtered_save[k] = {"id": "empty", "ref": 0, "size": 50.0, "quality": PlayerData.ITEM_QUALITIES.NORMAL}
					
			"inventory":
				for item_data in new_save[k]:
					if item_list.has(item_data["id"]):
						modded_save[k].append(item_data)
						print("[",item_data["id"],"]")
					elif items_vanilla.has(item_data["id"]):
						filtered_items.append(item_data)
					else:
						missing += 1
						missing_save[k].append(item_data)
				print(filtered_items)
				filtered_save[k] = filtered_items
#			"hotbar":
#				for hot_k in new_save[k].keys():
#					var hot_v = new_save[k][hot_k]
#					var id = PlayerData._find_item_code(hot_v)
#					if item_list.has(id):
#						modded_save[k][hot_k] = hot_v
#						print("[",id," ",modded_save[k][hot_k],"]")
#						filtered_save[k][hot_k] = 0;
			"cosmetics_unlocked":
				for cosmetic in new_save[k]:
					if cosmetic_list.has(cosmetic):
						modded_save[k].append(cosmetic)
						print("[",cosmetic,"]")
						filtered_save[k].erase(cosmetic)
					elif !cosmetics_vanilla.has(cosmetic):
						missing += 1
						missing_save[k].append(cosmetic)
						filtered_save[k].erase(cosmetic)
			"cosmetics_equipped":
				for e_k in new_save[k].keys():
					var e_v = new_save[k][e_k]
					if e_k == "accessory":
						modded_save[k][e_k] = []
						for cosmetic in e_v:
							if cosmetic_list.has(cosmetic):
								modded_save[k][e_k].append(cosmetic)
								print("[",cosmetic,"]")
								filtered_save[k][e_k].erase(cosmetic)
					else:
						if cosmetic_list.has(e_v):
							var fallback:String
							match e_k:
								"species":
									fallback = "species_cat"
								"pattern":
									fallback = "pattern_none"
								"primary_color":
									fallback = "pcolor_white"
								"secondary_color":
									fallback = "scolor_white"
								"hat":
									fallback = "hat_none"
								"undershirt":
									fallback = "shirt_none"
								"overshirt":
									fallback = "overshirt_none"
								"title":
									fallback = "title_none"
								"bobber":
									fallback = "bobber_default"
								"eye":
									fallback = "eye_halfclosed"
								"nose":
									fallback = "nose_cat"
								"mouth":
									fallback = "mouth_default"
								"tail":
									fallback = "tail_none"
								"legs":
									fallback = "legs_none"
							modded_save[k][e_k] = new_save[k][e_k]
							print("[",modded_save[k][e_k],"]")
							filtered_save[k][e_k] = fallback
	var file = File.new()
	file.open("user://webfishing_lure_data.save", File.WRITE)
	file.store_var(modded_save)
	file.close()
	print(PREFIX,missing," possible missing modded items/cosmetics will be saved on a different save as well! (they will be automatically restored if reinstalled in a future update)")
	file.open("user://webfishing_missing_data.save", File.WRITE)
	file.store_var(missing_save)
	file.close()
	print(PREFIX+"Stored the modded items and cosmetics owned on a separate save file successfully.")
	return filtered_save
