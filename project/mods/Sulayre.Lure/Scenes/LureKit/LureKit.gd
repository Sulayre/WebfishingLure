extends Control
const PREFIX = "[LUREKIT]"

var packer = PCKPacker.new()
var generator

const DATA_TEMPLATE = {
	"manifest":{
		"id":"",
		"pckpath":"",
		"metadata":{
			"name":"",
			"author":"",
			"version":"",
			"description":"",
			"tags":["LureKit"]
		},
	},
	"files":{
		"textures":[],
		"models":[],
		"audio":[],
		"resources":[],
	},
	"maingd":[],
}

const MAIN_GD_TEMPLATE = [
	["extends Node"],
	[],
	["onready var Lure = get_node_or_null(\"/root/SulayreLure\")"],
	[],
	["func _ready():"],
	["print(\"this mod.gd was generated with LureKit!\")",1],
	["if !Lure:",1],
	["print(\"Lure was not found, Mods made with LureKit require it!\")",2],
	["return",2]
]

# webfishing path for the editor to use
const WEBFISHING_PATH = "D:/SteamLibrary/steamapps/common/WEBFISHING"
const RES_MOD_PATH = "user://lurekit/editormod"

var folders = {
	"textures": "/Assets/Textures",
	"audio": "/Assets/Audio",
	"models": "/Assets/Models",
	"cosmetics": "/Resources/Cosmetics",
	"tools": "/Resources/Items/Tools",
	"props": "/Resources/Items/Props",
	"fish": "/Resources/Items/Fish",
	"actors": "/Scenes/Actors"
}

signal refresh_selected()

var game_folder_path = OS.get_executable_path().get_base_dir() if !OS.has_feature("editor") else WEBFISHING_PATH
var decomp_folder_path = game_folder_path.plus_file("GDWeave/lurekit/decompiled")
var mods_folder_path = game_folder_path.plus_file("GDWeave/mods")

var active_tab

var previous_mod_data
var selected_mod_data
var selected_mod_code

onready var tabs = $"%Tabs".get_children()

func _enter_tree():
	generator = $ResourceManager

func _ready():
	$"%GamePath".text = game_folder_path
	$"%SourcePath".text = decomp_folder_path
	$"%ModsPath".text = mods_folder_path
	var tab_btns = get_tree().get_nodes_in_group("tab_selector")
	var tab_uis = $"%Tabs".get_children()
	for tab in tab_btns:
		tab.connect("_pressed_tab",self,"tab_swap")
		for ui in tab_uis:
			if ui.name == tab.tab_id: tab.disabled = false
	tab_swap("intro")
	$"%GamePath".text = game_folder_path
	$"%BtnDecomp".connect("pressed",self,"export_decompiled_mod")
	$"%BtnPck".connect("pressed",self,"export_compiled_mod")

func _on_ReturnBtn_pressed():
	if selected_mod_data: _toggle_warning(true,0)
	else: get_tree().change_scene("res://Scenes/Menus/Splash/splash.tscn")
		

func tab_swap(tab_id=null):
	var new_tab = null
	if !active_tab and !tab_id: return
	for tab in tabs:
		var check = tab.name == tab_id
		if check: new_tab = tab
		tab.visible = check
	if (active_tab == new_tab) or !tab_id:
		$AnimationPlayer.play("HideTab")
		GlobalAudio._play_sound("guitar_in")
		new_tab = null
	elif !active_tab and new_tab:
		$AnimationPlayer.play_backwards("HideTab")
		GlobalAudio._play_sound("guitar_out")
	else:
		GlobalAudio._play_sound("ui_open")
	active_tab = new_tab

func generate_array_source(lines:Array,file_path:String=""):
	var final_source = ""
	for line in lines:
		if line.size() > 0:
			if line.size() > 1:
				for tab in line[1]:
					final_source += "\t"
			final_source += line[0]+"\n"
		else:
			final_source += "\n"
	print("====[LureKit Generated New Source Code]====")
	print(final_source)
	print("===========================================")
	
	if file_path != "":
		var file = File.new()
		file.open(file_path,File.WRITE)
		file.store_string(final_source)
		file.close()
	
	return final_source

func export_decompiled_mod(mod_data:={}) -> bool:
	if mod_data.size() == 0: mod_data = selected_mod_data
	var dir:Directory = Directory.new()
	if !dir.dir_exists(decomp_folder_path):
		dir.make_dir_recursive(decomp_folder_path)
	if dir.open(decomp_folder_path) == OK:
		dir.make_dir_recursive(mod_data["manifest"]["Id"])
		var mod_dir = decomp_folder_path.plus_file(mod_data["manifest"]["Id"])
		var parsed = JSON.print(mod_data["manifest"],"	")
		var file = File.new()
		file.open(mod_dir.plus_file("manifest.json"),File.WRITE)
		file.store_string(parsed)
		file.close()
		file.open(mod_dir.plus_file("main.gd"),File.WRITE)
		file.store_string(generate_array_source(selected_mod_code.duplicate()))
		file.close()
		PopupMessage._show_popup("Decompilation exported successfuly!")
		return true
	else:
		PopupMessage._show_popup("There was an error exporting the decomp!")
	return false

# TODO: MOVE PCKS GENERATED IN THE EDITOR

func export_compiled_mod(mod_data:={}) -> bool:
	if mod_data.size() == 0: mod_data = selected_mod_data
	var dir:Directory = Directory.new()
	if dir.open(mods_folder_path) == OK:
		var mod_id = mod_data["manifest"]["Id"]
		dir.make_dir(mod_id)
		var mod_dir = mods_folder_path.plus_file(mod_id)
		var parsed = JSON.print(mod_data["manifest"],"	")
		var file = File.new()
		print("Generating and saving manifest.json")
		file.open(mod_dir.plus_file("manifest.json"),File.WRITE)
		file.store_string(parsed)
		file.close()
		print("Generating main.gd")
		var source = generate_array_source(selected_mod_code)
		print("Storing main.gd")
		if dir.dir_exists(RES_MOD_PATH):
			file.open(RES_MOD_PATH+"/main.gd",File.WRITE)
			file.store_string(source)
			file.close()
			print("Generating "+mod_id+".pck")
			packer.pck_start(mod_data["manifest"]["PackPath"])
			packer.add_file("res://mods/"+mod_id+"/main.gd",RES_MOD_PATH+"/main.gd")
			packer.flush(true)
			dir.rename(game_folder_path.plus_file(mod_id+".pck"),mod_dir.plus_file(mod_id+".pck"))
			_empty_directory(RES_MOD_PATH)
			PopupMessage._show_popup("Mod exported successfuly!")
			return true
		else:
			PopupMessage._show_popup("There was an error compiling the mod :B")
	return false

func _empty_directory(path: String) -> void:
	var dir := Directory.new()
	if dir.open(path) != OK:
		return
	print(path)
	dir.list_dir_begin(true, true)
	var file_name := dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			_empty_directory(path.plus_file(file_name))
		file_name = dir.get_next()
		print(path.plus_file(file_name))
		dir.remove(file_name)
	dir.list_dir_end()
	dir.remove(path)

func _folder_cloner(from: String,to: String) -> void:
	var dir := Directory.new()
	if dir.open(from) != OK:
		return
	dir.list_dir_begin(true, true)
	var file_name := dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			_folder_cloner(from.plus_file(file_name),to)
		file_name = dir.get_next()
	dir.list_dir_end()

func _on_LureKit_refresh_selected():
	var selected = selected_mod_data != null
	$"%SelectedMod".visible = selected
	$"%ModSelectors".visible = !selected
	$"%ModExporter".visible = selected
	$"%OptionsScroller".visible = selected
	$"%MenuHolder".size_flags_vertical = SIZE_EXPAND_FILL if selected else !SIZE_EXPAND_FILL
	if selected:
		selected_mod_code = MAIN_GD_TEMPLATE.duplicate(true)
		var dir:Directory = Directory.new()
		$"%selectedLabel".text = selected_mod_data["manifest"]["Id"]
		print(RES_MOD_PATH)
		dir.make_dir_recursive(RES_MOD_PATH)
		if dir.open(RES_MOD_PATH) == OK:
			dir.make_dir_recursive("Assets/Textures")
			dir.make_dir("Assets/Models")
			dir.make_dir("Assets/Audio")
			dir.make_dir_recursive("Resources/Cosmetics")
			dir.make_dir("Resources/Items")
			dir.make_dir_recursive("Scenes/Actors/Props")
			dir.make_dir_recursive("Scenes/Maps/Zones")
	else:
		$"%selectedLabel".text = "none"
	$"%BtnDecomp".disabled = selected_mod_data == null
	$"%BtnPck".disabled = selected_mod_data == null

func _load_mod(mod_id):
	print("pong")
	var file = File.new()
	if selected_mod_data:
		_empty_directory(RES_MOD_PATH)
		selected_mod_code = MAIN_GD_TEMPLATE.duplicate(true)
	print(mods_folder_path+"/"+mod_id.plus_file("manifest.json"))
	if file.open(mods_folder_path+"/"+mod_id.plus_file("manifest.json"),File.READ) == OK:
		var txt = file.get_as_text()
		var parsed = JSON.parse(txt).result
		print(parsed)
		var mod_data = DATA_TEMPLATE.duplicate(true)
		mod_data["manifest"] = parsed
		selected_mod_data = mod_data
		emit_signal("refresh_selected")
		tab_swap()
		PopupMessage._show_popup("Mod imported successfuly!")

func _deselect_mod():
	if selected_mod_data:
		_empty_directory(RES_MOD_PATH)
		selected_mod_code = null
		selected_mod_data = null
	emit_signal("refresh_selected")
	tab_swap()

func _toggle_warning(active:bool=false,index:int=0):
	$"SaveWarning".visible = active
	$"%WrnGame".visible = index == 0
	$"%WrnSwap".visible = index == 1

func _wipe_mod():
	if !$"SaveWarning".visible: return
	if $"%WrnGame".visible:
		get_tree().change_scene("res://Scenes/Menus/Splash/splash.tscn")
	elif $"%WrnSwap".visible:
		_deselect_mod()
		_toggle_warning(false)


func _on_BtnChange_pressed():
	_toggle_warning(true,1)


func _on_BtnWipe_pressed():
	_wipe_mod()


func _on_BtnPckSave_pressed():
	if export_compiled_mod():
		_wipe_mod()


func _on_BtnReturn_pressed():
	_toggle_warning(false)
