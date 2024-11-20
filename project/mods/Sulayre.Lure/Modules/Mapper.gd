extends Node
var Lure:Node
var selected_map
var player_bodies = []
const PREFIX = "[LURE/MAPPER]: "

func _refresh_players(node):
	player_bodies = []
	print("refreshing")
	var entities = get_tree().get_current_scene().get_node("Viewport/main/entities").get_children()
	for entity in entities:
		if "player" in entity.name:
			player_bodies.append(entity)
	print(player_bodies)
	
func _swap_map(index):
	match index:
		-1:
			pass
		0:
			selected_map = null
		_:
			selected_map = Lure.modded_maps[index-1]

func _load_map():
	if selected_map:
		prints("ATTEMPTING TO LOAD MAP:",selected_map)
		var world = get_tree().current_scene
		var map_holder = world.get_node("Viewport/main/map")
		var new_map:Spatial = selected_map["scene"].instance()
		var old_map = map_holder.get_node("main_map")
		var lobby_id = Network.STEAM_LOBBY_ID
		var lobby_name = Steam.getLobbyData(lobby_id, "name")
		
		var new_title = "[color=#D87093][Lure Modded Map][/color] "+lobby_name
		
		print(PREFIX+"Modded lobby name: ",new_title)
		
		Steam.setLobbyData(lobby_id, "name",new_title)
		Steam.setLobbyData(lobby_id, "version", str(Globals.GAME_VERSION)+".lure")
		
		Steam.setLobbyData(lobby_id, "lure_map_id", selected_map["id"])
		Steam.setLobbyData(lobby_id, "lure_map_name", selected_map["name"])
		
		print(PREFIX+"Modded lobby map id: ",Steam.getLobbyData(lobby_id, "lure_map_id"))
		print(PREFIX+"Modded lobby map name: ",Steam.getLobbyData(lobby_id, "lure_map_name"))
		
		map_holder.remove_child(old_map)
		map_holder.add_child(new_map)
		world.map = new_map
		new_map.name = "main_map"
		prints(map_holder.get_children(),world.map)
		
		var groups = [
			"fish_spawn",
			"aqua_spawn_loc",
			"bush",
			"shoreline_point",
			"trash_point",
			"deep_spawn",
			"hidden_spot"
			]
		
		var anticrash = Spatial.new()
		anticrash.name = "missing_groups_crash_prevention_node"
		new_map.add_child(anticrash)
			
		#crash prevention
		for group in groups:
			if get_tree().get_nodes_in_group(group).size() < 1:
				anticrash.add_to_group(group)
		
		if !new_map.get_node_or_null("tutorial_spawn_position"):
			var tutsp = Position3D.new()
			tutsp.name = "tutorial_spawn_position"
			new_map.add_child(tutsp)
		
		PlayerData.player_saved_position = Vector3.ZERO
		Lure.emit_signal("mod_map_loaded")
	
