extends Reference


static func save_data(save_slot: int, save: Dictionary) -> void:
	var save_path := "user://Lure/lure_save_slot_%s.dat" % save_slot
	
	var dir := Directory.new()
	if !dir.dir_exists("user://Lure"):
		dir.make_dir("user://Lure")
	
	var file := File.new()
	file.open(save_path, File.WRITE)
	file.store_string(JSON.print(save))
	file.close()


static func load_data(save_slot: int) -> Dictionary:
	var save_path := "user://Lure/lure_save_slot_%s.dat" % save_slot
	var save := {}
	
	var file := File.new()
	if not file.file_exists(save_path):
		return {}
	file.open(save_path, File.READ)
	var content := file.get_as_text()
	file.close()
	
	var stored_json := JSON.parse(content)
	if stored_json.error == OK:
		save = stored_json.result
	
	return save


static func filter_player_data(lure_content: Array, player_data: Dictionary) -> Dictionary:
	var filtered_data: Dictionary = {
		"inventory": [],
		"cosmetics_unlocked": [],
		"cosmetics_equipped": {},
		"bait_inv": {},
		"bait_selected": "",
		"bait_unlocked": [],
		"journal_logs": {},
		"lure_selected": "",
		"lure_unlocked": [],
		"saved_aqua_fish": {}
	}
	
	for entry in player_data.inventory:
		if entry.id in lure_content:
			filtered_data.inventory.append(entry.id)
	
	for id in player_data.cosmetics_unlocked:
		if id in lure_content:
			filtered_data.cosmetics_unlocked.append(id)
	
	for category in player_data.cosmetics_equipped.keys():
		if player_data.cosmetics_equipped[category] is Array:
			if not category in filtered_data.cosmetics_equipped:
				filtered_data.cosmetics_equipped[category] = []
			for cosmetic in player_data.cosmetics_equipped[category]:
				if cosmetic in lure_content:
					filtered_data.cosmetics_equipped[category].append(cosmetic)
		
		elif player_data.cosmetics_equipped[category] is String:
			var cosmetic: String = player_data.cosmetics_equipped[category]
			if cosmetic in lure_content:
				filtered_data.cosmetics_equipped[category] = cosmetic
	
	for id in player_data.bait_inv.keys():
		if id in lure_content:
			filtered_data.bait_inv[id] = player_data.bait_inv[id]
	
	if player_data.bait_selected in lure_content:
		filtered_data.bait_selected = player_data.bait_selected
	
	for id in player_data.bait_unlocked:
		if id in lure_content:
			filtered_data.bait_unlocked.append(id)
	
	for category in player_data.journal_logs.keys():
		if not category in filtered_data.journal_logs.keys():
			filtered_data.journal_logs[category] = {}
		
		for id in player_data.journal_logs[category]:
			var journal_log: Dictionary = player_data.journal_logs[category][id]
			
			if id in lure_content:
				filtered_data.journal_logs[category][id] = journal_log
	
	if player_data.lure_selected in lure_content:
		filtered_data.lure_selected = player_data.lure_selected
	
	for id in player_data.lure_unlocked:
		if id in lure_content:
			filtered_data.lure_unlocked.append(id)
	
	if player_data.saved_aqua_fish.id in lure_content:
		filtered_data.saved_aqua_fish = player_data.saved_aqua_fish
	
	return filtered_data


static func initialise_data(save: Dictionary, player_data) -> void:
	for entry in save.inventory:
		player_data.inventory.append(entry.id)
	
	for id in save.cosmetics_unlocked:
		player_data.cosmetics_unlocked.append(id)
	
	for category in save.cosmetics_equipped.keys():
		if save.cosmetics_equipped[category] is Array:
			var cosmetics: Array = save.cosmetics_equipped[category]
			for cosmetic in cosmetics:
				player_data.cosmetics_equipped[category].append(cosmetic)
		elif save.cosmetics_equipped[category] is String:
			var cosmetic: String = save.cosmetics_equipped[category]
			if cosmetic:
				player_data.cosmetics_equipped[category] = cosmetic
	
	for id in save.bait_inv.keys():
		player_data.bait_inv[id] = save.bait_inv[id]
	
	for id in save.bait_unlocked:
		player_data.bait_unlocked.append(id)
	
	for category in save.journal_logs.keys():
		if not category in player_data.journal_logs.keys():
			player_data.journal_logs[category] = {}
		
		for id in save.journal_logs[category]:
			var journal_log: Dictionary = save.journal_logs[category][id]
			player_data.journal_logs[category][id] = journal_log
	
	for id in save.lure_unlocked:
		player_data.lure_unlocked.append(id)
	
	if save.saved_aqua_fish:
		player_data.saved_aqua_fish = save.saved_aqua_fish
