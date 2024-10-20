class_name Lure extends Node

signal main_menu_enter()
signal game_enter()

var Lure = {}
var mods = []

var dir = Directory.new()
var mods_folder = "res://mods"

func _ready():
	if dir.open(mods_folder) == OK:
		dir.list_dir_begin(true,true)
		var mod_folder = dir.get_next()
		while mod_folder != "":
			if dir.current_is_dir():
				mods.append(mod_folder)
			mod_folder = dir.get_next()
		print("Mods folder prewarming concluded.")
		print(mods)
	_load_modded_resources()
	get_tree().root.connect("child_entered_tree",self,"_on_enter")
	self.connect("main_menu_enter",self,"_add_watermark")
	self.connect("game_enter",self,"_debug_on_enter")

func _on_enter(node:Node):
	if node.name == "main_menu" and node.is_class("Control"):
		emit_signal("main_menu_enter")
	elif node.name == "world":
		emit_signal("game_enter")
		
func _add_watermark():
	var prefab:PackedScene =load("res://mods/sulayre.lureapi/Scenes/Watermark.tscn")
	var dupe:Control = prefab.instance()
	dupe.get_node("TextureRect").texture = load("res://mods/sulayre.lureapi/icon.png")
	get_tree().root.get_node("main_menu").add_child(dupe)
	dupe.visible = true

# there is probably a better way of doing this but not no
#Globals._add_resource(file[0], file[1])

func _load_modded_resources():
	var resource_count = 0
	print("Loading Modded Resources...")
	for id in mods:
		var files = []
		var dir = Directory.new()
		var path = mods_folder.plus_file(id)+"/Resources/Lure"
		
		if dir.open(path) != OK:
			print("error (or missing) loading resources folder from "+id)
			print(path)
			break
		dir.list_dir_begin(true, true)
		while true:
			var file = dir.get_next()
			print(path+"/"+file)
			if file == "":
				break
			elif file.ends_with(".tres"):
				var file_res = load(path+"/"+file)
				if file_res is ItemResource or file_res is CosmeticResource:
					files.append([path + "/" + file, file])
					print("registered item "+file)
					resource_count += 1
				else:
					print(file_res.get_class())
					print("Skipping "+file+" since its not a cosmetic nor an item.")
		
		for file in files:
			print(file[0]+" "+file[1])
			Globals._add_resource(file[0], file[1])
		
		dir.list_dir_end()
		print(str(resource_count) + " Resources Loaded from "+id)

		
func _debug_on_enter():
	if Network.SERVER_CREATION_TYPE == 0 and Network.GAME_MASTER:
		Steam.setLobbyData(Network.STEAM_LOBBY_ID, "name", "[b][color=seagreen][Modded w/ GDWeave+LureAPI][/color][/b] "+Network.STEAM_USERNAME)
	#PlayerData._add_item("little_shit",-1,10)
