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
	PlayerData.player_saved_position = Vector3.ZERO
	prints("ATTEMPTING TO LOAD MAP:",selected_map)
	if selected_map:
		var world = get_tree().current_scene
		var map_holder = world.get_node("Viewport/main/map")
		var old_map = map_holder.get_node("main_map")
		var new_map = map_holder.add_child(selected_map["scene"].instance())
		var lobby_id = Network.STEAM_LOBBY_ID
		Globals.GAME_VERSION_LURE = str(Globals.GAME_VERSION)+"#"+selected_map["id"]
		var lobby_name = Steam.getLobbyData(lobby_id, "name")
		var new_title = "[color=#D87093][Lure Modded Map][/color] "+lobby_name
		print(PREFIX+"Modded lobby name: ",new_title)
		print(PREFIX+"Modded lobby version: ",Globals.GAME_VERSION_LURE)
		Steam.setLobbyData(lobby_id, "name",new_title)
		Steam.setLobbyData(lobby_id, "version", Globals.GAME_VERSION_LURE)
		map_holder.remove_child(old_map)
		Lure.emit_signal("mod_map_loaded")
		world.map = new_map
