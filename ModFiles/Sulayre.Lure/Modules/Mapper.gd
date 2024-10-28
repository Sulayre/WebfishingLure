extends Node
var Lure:Node
var selected_map
const PREFIX = "[LURE/MAPPER]: "

func _on_main():
	var mode:OptionButton = get_tree().current_scene.get_node_or_null("%serv_options")
	var options:OptionButton = mode.duplicate()
	options.name = "serv_maps"
	var container:HBoxContainer = mode.get_parent()
	var label:Label = container.get_node("Label")
	prints(options.name,container.name,label.name)
	container.add_child_below_node(label,options)
	options.connect("item_selected",self,"_swap_map")
	options.add_item("Original Map")
	var maps = Lure.modded_maps
	for map_data in maps:
		options.add_item(map_data["name"])
		
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
		PlayerData.player_saved_position = Vector3.ZERO
		var new_map = selected_map["scene"].instance()
		var old_map = map_holder.get_node("main_map")
		var lobby_id = Network.STEAM_LOBBY_ID
		var lobby_name = Steam.getLobbyData(lobby_id, "name")
		
		var new_title = "[color=#D87093][Lure Modded Map][/color] "+lobby_name
		
		print(new_map)
		
		print(PREFIX+"Modded lobby name: ",new_title)
		
		Steam.setLobbyData(lobby_id, "name",new_title)
		Steam.setLobbyData(lobby_id, "version", str(Globals.GAME_VERSION)+".lure")
		
		Steam.setLobbyData(lobby_id, "lure_map_id", selected_map["id"])
		Steam.setLobbyData(lobby_id, "lure_map_name", selected_map["name"])
		
		print(PREFIX+"Modded lobby map id: ",Steam.getLobbyData(lobby_id, "lure_map_id"))
		print(PREFIX+"Modded lobby map name: ",Steam.getLobbyData(lobby_id, "lure_map_name"))
		
		map_holder.add_child(new_map)
		print(map_holder.get_children())
		world.map = new_map
		map_holder.remove_child(old_map)
		new_map.name = "main_map"
		Lure.emit_signal("mod_map_loaded")
	
