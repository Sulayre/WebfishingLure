extends Node
var Lure:Node

const PREFIX = "[LURE/LOADER]: "

func _species_loader(id:String,resource:CosmeticResource):
	if Lure.modded_species.has(id):
		#print(PREFIX + "Custom species id "+ id + " is already taken! make sure your species ids are unique to avoid mods clashing! Expect UV issues.")
		return
	Lure.modded_species.append(id)
	resource.cos_internal_id = Lure.modded_species.find(id)
	#print(modded_species.size()," ",Lure.modded_species)
	#print("species "+id+" now has index ",resource.cos_internal_id)

func _register_resource(resource_data:Dictionary):
	if Globals.GAME_VERSION != 1.08:
		print("LURE HAS NOT BEEN UPDATED TO RUN THIS VERSION OF THE GAME, LURE WONT ADD NEW ITEMS TO PREVENT SAVE CORRUPTION!!!!")
		return
	var dir = Directory.new()
	var mod_id = resource_data.mod
	var item_id = resource_data.id
	var final_id = mod_id+"."+item_id
	var res_path = Lure.Util._mod_path_converter(mod_id,resource_data.file)
	
	match dir.open("res://mods/"+mod_id):
		OK:
			dir = null
			var loaded_resource = load(res_path)
			if loaded_resource is ItemResource:
				Globals.item_data[final_id] = {"file":loaded_resource}
				Lure.item_list[final_id] = {"resource":loaded_resource, "flags":resource_data.flags}
				Lure.loaded_items.append(final_id)
				if loaded_resource.category in ["tool","furniture"]:
					#print(PREFIX+"Item has either tool or furniture as category, checking ownership.")
					#print(loaded_resource.prop_code+" ",Lure.modded_props)
					var owned = false
					match loaded_resource.category:
						"furniture":
							loaded_resource.prop_code = mod_id + "." + loaded_resource.prop_code
						"tool":
							pass
					#else:
						#prints(Lure.FLAGS.FREE_UNLOCK,resource_data.flags)
				if loaded_resource.category in ["fish","bug"]:
					var journal_logs = PlayerData.journal_logs
					#print(PlayerData.journal_logs)
					var tables = [loaded_resource.loot_table]
					for flag in resource_data["flags"]:
						if flag is String:
							if flag.begins_with("LURE_LOOT_TABLE_"):
								if tables.has(loaded_resource.loot_table):
									tables.remove(0)
									loaded_resource.loot_table = "modded"
								var final_loot = flag.replace("LURE_LOOT_TABLE_","")
								if final_loot in Lure.modded_pools:
									if !(final_loot in Lure.journal_categories[3][1]):
										!Lure.journal_categories[3][1].append(loaded_resource.loot_table)
								tables.append(final_loot)
					prints(final_id,tables)
					for table in tables:
						if !journal_logs.get(table,null):
							journal_logs[table] = {}
						var journal_log = journal_logs[table]
						if !journal_log.has(final_id):
							PlayerData._log_item(final_id,0.0,0,true)
						Lure.Util._regenerate_loot_table(loaded_resource.category,table)
			elif loaded_resource is CosmeticResource:
				Lure.cosmetic_list[final_id] = {"resource":loaded_resource, "flags":resource_data.flags}
				Lure.loaded_cosmetics.append(final_id)
				Globals.cosmetic_data[final_id] = {"file":loaded_resource}
				match loaded_resource.category:
					"species":
						_species_loader(final_id,loaded_resource)
						_refresh_patterns()
						_refresh_alt_meshes()
					"pattern":
						_refresh_patterns()
				_refresh_alt_meshes()
			else:
				Lure.emit_signal("lurlog",Lure.RESOURCE_CLASS_INCORRECT)
				return
			#print(PREFIX+final_id+" has been loaded successfully! ("+res_path+")")
		7:
			dir = null
			Lure.emit_signal("lurlog",Lure.RESOURCE_NOT_FOUND)
			return
		_:
			dir = null
			Lure.emit_signal("lurlog",Lure.RESOURCE_UNKNOWN_ERROR)
			return

func _refresh_patterns():
	var patterns = {}
	# we grab all the patterns
	for cosmetic_id in Globals.cosmetic_data.keys():
		var cosmetic_resource = Globals.cosmetic_data[cosmetic_id].file
		if cosmetic_resource.category == "pattern":
			patterns[cosmetic_id] = cosmetic_resource
	#print(patterns)
	# now we organize the textures patterns and species
	for texture_data in Lure.texture_buffer:
		var pattern = patterns[texture_data.pattern]
		if !pattern:
			#Lure.emit_signal("lurlog",Lure.TEXTURE_BUFFER_MISSING_PATTERN_REFERENCE)
			continue
		var found:bool
		for species in Lure.modded_species:
			if species == texture_data.species:
				var index = Lure.modded_species.find(species)+1
				var length = pattern.body_pattern.size()
				#print(PREFIX+index+" "+length+" ("+length-1+")")
				if index > length-1:
					pattern.body_pattern.resize(index+1)
					#print(PREFIX+"resized")
				pattern.body_pattern[index] = texture_data.texture
				#print(PREFIX+"Attached new texture to pattern '"+texture_data.pattern+"' for species '"+texture_data.species+"'")
				found = true
				break
		#if !found:
			#print(modded_species)
			#Lure.emit_signal("lurlog",Lure.TEXTURE_BUFFER_MISSING_SPECIES_REFERENCE)

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
	for mesh_data in Lure.mesh_buffer:
		var mesh = cosmetics[mesh_data.cosmetic]
		if !mesh:
			#print(mesh_data.cosmetic," "," ",cosmetics.keys())
			#Lure.emit_signal("lurlog",Lure.MESH_BUFFER_MISSING_COSMETIC_REFERENCE)
			continue
		var found:bool
		for species in Lure.modded_species:
			if species == mesh_data.species:
				var index = Lure.modded_species.find(species)
				var length = mesh.species_alt_mesh.size()
				mesh.species_alt_mesh.resize(Lure.modded_species.size())
				for i in range(0,mesh.species_alt_mesh.size()):
					if !mesh.species_alt_mesh[i]:
						mesh.species_alt_mesh[i] = mesh.mesh
				mesh.species_alt_mesh[index] = mesh_data.mesh
				#print(mesh.species_alt_mesh)
				#print(PREFIX+"Attached new alt mesh to cosmetic '"+mesh_data.cosmetic+"' for species '"+mesh_data.species+"'"+"with internal index",index)
				found = true
				break
		#if !found:
		#	Lure.emit_signal("lurlog",Lure.MESH_BUFFER_MISSING_SPECIES_REFERENCE)

func _refresh_modded_unlocks():
	#print(PREFIX+"Refreshing modded automatic unlocks.")
	var item_list = Lure.item_list
	var cosmetic_list = Lure.cosmetic_list
	for id in item_list.keys():
		var res = item_list[id]["resource"]
		var flags = item_list[id]["flags"]
		#prints(item_list[id],FLAGS.FREE_UNLOCK)
		if (flags.has(Lure.FLAGS.LOCK_AFTER_SHOP_UPDATE) or flags.has(Lure.FLAGS.FREE_UNLOCK)) and (res.category == "tool" or res.category == "furniture"):
				var owned = false
				for item in PlayerData.inventory.duplicate(true):
					if item.id == id:
						owned = true
				if !owned:
					#print(PREFIX+id+" is a tool/prop that is unlocked automatically but isn't owned, adding to inventory.")
					var ref = randi()
					var entry = {"id": id, "size": 1, "ref": ref, "quality": PlayerData.ITEM_QUALITIES.NORMAL, "tags": []}
					PlayerData.inventory.append(entry)
	PlayerData.emit_signal("_inventory_refresh")
				#else: print(PREFIX+"Tool or prop with id "+id+" is already owned, skipping!")
	for id in cosmetic_list.keys():
		var flags = cosmetic_list[id]["flags"]
		if flags.has(Lure.FLAGS.LOCK_AFTER_SHOP_UPDATE) or flags.has(Lure.FLAGS.FREE_UNLOCK):
			if !PlayerData.cosmetics_unlocked.has(id):
				PlayerData.cosmetics_unlocked.append(id)
				#print(PREFIX+id+" is a cosmetic that's unlocked automatically but isn't owned, adding to unlocked cosmetics.")
			#print(PREFIX+id,"has unlocked index ",PlayerData.cosmetics_unlocked.find(id))

func _load_modded_save_data():
	var _file = File.new()
	if !_file.file_exists("user://webfishing_lure_data.save"):
		print(PREFIX+"Save data file for modded assets was not found, skipping load.")
		return
	match _file.open("user://webfishing_lure_data.save",File.READ):
		OK:
			var save = _file.get_var()
			for c in save.keys():
				var d = save[c]
				print(PREFIX,"Loading modded save data for ",c)
				match c:
					"inventory":
						var unique := {}
						for i in d:
							if i["id"] in Lure.loaded_items:
								if Lure.item_list[i["id"]]["resource"].category in ["tool","furniture"]:
									unique[i["id"]] = i
								else:
									PlayerData.inventory.append(i)
									print(PREFIX,i["id"])
						print(PREFIX,"uniques: ",unique.keys())
						PlayerData.inventory.append_array(unique.values())
						PlayerData.emit_signal("_inventory_refresh")
								
					"hotbar":
						for i in save["hotbar"].keys():
							if i.id in Lure.loaded_items:
								print(PREFIX,i,": ",save["hotbar"][i])
								PlayerData.hotbar[i] = save["hotbar"][i]
					"cosmetics_unlocked":
						for c_u in d:
							if !PlayerData.cosmetics_unlocked.has(c_u):
								if Lure.loaded_cosmetics.has(c_u):
									print(PREFIX,c_u)
									PlayerData.cosmetics_unlocked.append(c_u)
					"cosmetics_equipped":
						for e_k in save[c].keys():
							var e_v = save[c][e_k]
							if e_k == "accessory":
								for cosmetic in e_v:
									if PlayerData.cosmetics_equipped["accessory"].size() < 4:
										if Lure.loaded_cosmetics.has(cosmetic):
											print(PREFIX,cosmetic)
											PlayerData.cosmetics_equipped["accessory"].append(cosmetic)
									else: break
							else:
								if Lure.loaded_cosmetics.has(e_v):
									PlayerData.cosmetics_equipped[e_k] = e_v
							print(PREFIX,e_k,"/",e_v)
					"journal":
						for p in save["journal"].keys():
							if !Lure.modded_pools.has(p):
								print(Lure.modded_pools)
								continue
							if !PlayerData.journal_logs.has(p):
									PlayerData.journal_logs[p] = {}
							for id in save["journal"][p].keys():
								var entry = save["journal"][p][id]
								PlayerData.journal_logs[p][id] = entry
								print(p,"/",entry)
						PlayerData.emit_signal("_journal_update")
		_:
			Lure.emit_signal("lurlog",Lure.SAVE_UNKNOWN)
	_file.close()
	print(PREFIX+"Finished loading saved mod data!")
	_refresh_modded_unlocks()
