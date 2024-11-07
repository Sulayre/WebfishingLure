extends Control

var model
var category = ""
var selected_cosmetic = ""
var selected_category = ""
var selected_style = 0

onready var Lure = get_node("/root/SulayreLure")

onready var griddata = {
	"species": $"%species_cont", 
	"bodies": $"%bodies_cont",
	"pattern": $"%pattern_cont", 
	"primary_color": $"%primary_color_cont", 
	"secondary_color": $"%sec_color_cont", 
	"tail": $"%tail_cont", 
	
	"eye": $"%eye_cont", 
	"nose": $"%nose_cont", 
	"mouth": $"%mouth_cont", 
	
	"hat": $"%hat_cont", 
	"undershirt": $"%undershirt_cont", 
	"overshirt": $"%overshirt_cont", 
	"legs": $"%leg_cont", 
	"accessory": $"%acc_cont", 
	
	"title": $"%title_cont", 
	"bobber": $"%bob_cont", 
}

onready var tabbtns = $"ScrollContainer/HBoxContainer"
onready var tabpages = $"Panel4/tabs"

onready var base_label = $Panel4/tabs/body/HBoxContainer/vbox/mod_label
onready var base_cont = $Panel4/tabs/body/HBoxContainer/vbox/mod_cont
onready var base_space = $Panel4/tabs/body/HBoxContainer/vbox/mod_space
onready var base_sep = $Panel4/tabs/body/HBoxContainer/vbox/mod_sep
onready var base_btntab = $ScrollContainer/HBoxContainer/mod_btn
onready var base_pagetab = $Panel4/tabs/mod_tab

onready var grid = $Panel4 / Control / GridContainer
onready var categories = $Panel4 / Control / categories
onready var label = $Panel4 / Control / Label

signal _cosmetic_update
signal _finished_setup

func _ready():
	base_label.get_parent().remove_child(base_label)
	base_cont.get_parent().remove_child(base_cont)
	base_space.get_parent().remove_child(base_space)
	base_sep.get_parent().remove_child(base_sep)
	base_btntab.get_parent().remove_child(base_btntab)
	base_pagetab.get_parent().remove_child(base_pagetab)
	
	PlayerData.connect("_clear_new", self, "_refresh")
	
	$"%next_style".connect("pressed", self, "_change_style", [1])
	$"%prev_style".connect("pressed", self, "_change_style", [ - 1])
	
	for tab in Lure.cosmetic_categories.keys():
		if tab in Lure.vanilla_tabs: continue
		_create_tab(tab)
		var categories = Lure.cosmetic_categories[tab]
		for category in categories:
			_create_group(tab,category[0],category[1])

	_refresh()
	_change_tab("body")
	
	model = preload("res://Scenes/Entities/Player/player.tscn").instance()
	model.dead_actor = true
	model.delete_on_owner_disconnect = false
	$Panel3 / player_view / Viewport.add_child(model)
	model.call_deferred("_change_cosmetics")

func _create_tab(tab_name:String):
	var new_tab:Button = base_btntab.duplicate()
	var btns = tabbtns.get_children()
	tabbtns.add_child(new_tab)
	new_tab.name = tab_name.to_lower()
	new_tab.get_node("new_icon").visible = false
	new_tab.text = tab_name.to_upper()
	new_tab.connect("pressed",self,"_change_tab",[new_tab.name])
	var new_page:ScrollContainer = base_pagetab
	tabpages.add_child(new_page)
	new_page.name = new_tab.name

func _create_group(tab_name:String,category_name:String,unused_toggle_bool:bool):
	var new_name = base_label.duplicate()
	new_name.text = category_name.replace("_"," ")
	var new_cont = base_cont.duplicate()
	var new_space = base_space.duplicate()
	var new_sep = base_sep.duplicate()
	var list:Node = tabpages.get_node(tab_name.plus_file("HBoxContainer/vbox"))
	list.add_child(new_name)
	list.add_child(new_cont)
	list.add_child(new_space)
	list.add_child(new_sep)
	griddata[category_name] = new_cont

func _change_tab(tab):
	category = tab

	var buttons = tabbtns.get_children()
	for button in buttons:
		button.modulate = Color(0.7, 0.7, 0.7) if tab != button.name else Color(1.0, 1.0, 1.0)
	
	var tabs = tabpages.get_children()
	for child in tabs:
		child.visible = child.name == tab

func _refresh():
	for key in griddata.keys():
		for child in griddata[key].get_children():
			child.queue_free()
	
	for cosm in PlayerData.cosmetics_unlocked:
		print(cosm)
		if not Globals._cosmetic_exists(cosm): continue
		
		var data = Globals.cosmetic_data[cosm]["file"]
		print(data.category)
		if not griddata.keys().has(data.category): continue
		
		var button = preload("res://Scenes/HUD/CosmeticMenu/cosmetic_button.tscn").instance()
		
		button._setup(cosm)
		button.connect("pressed", self, "_cosmetic_select", [data.category, cosm])
		
		connect("_cosmetic_update", button, "_refresh")
		griddata[data.category].add_child(button)
	
	$ScrollContainer/HBoxContainer / body / new_icon.visible = false
	$ScrollContainer/HBoxContainer / face / new_icon.visible = false
	$ScrollContainer/HBoxContainer / clothes / new_icon.visible = false
	$ScrollContainer/HBoxContainer / misc / new_icon.visible = false
	
	for cosm in PlayerData.new_cosmetics:
		var data = Globals.cosmetic_data[cosm]["file"]
		match data.category:
			"species", "pattern", "primary_color", "secondary_color", "tail": $ScrollContainer/HBoxContainer / body / new_icon.visible = true
			"eye", "nose", "mouth": $ScrollContainer/HBoxContainer / face / new_icon.visible = true
			"hat", "undershirt", "overshirt", "accessory": $ScrollContainer/HBoxContainer / clothes / new_icon.visible = true
			"title", "bobber": $ScrollContainer/HBoxContainer / misc / new_icon.visible = true

func _cosmetic_select(category, id, style = 0):
	
	
	
	
	
	
	if category != "accessory":
		PlayerData._change_cosmetic(category, id)
	else :
		PlayerData._change_accessory(id)
	
	if model: model._change_cosmetics()
	emit_signal("_cosmetic_update")

func _cosmetic_highlight(category, id, style = - 1):
	return 
	
	selected_category = category
	selected_cosmetic = id
	
	var cos_data = Globals.cosmetic_data[id]["file"]
	if style == - 1: selected_style = max(0, cos_data.styles.find(PlayerData.cosmetics_equipped[category]))
	else : selected_style = style
	
	$Panel3 / style_display / HBoxContainer / VBoxContainer / Label2.text = "style " + str(selected_style + 1) + "/" + str(cos_data.styles.size())

func _change_style(modif):
	return 
	
	var cos_data = Globals.cosmetic_data[selected_cosmetic]["file"]
	
	selected_style += modif
	if selected_style >= cos_data.styles.size(): selected_style = 0
	if selected_style < 0: selected_style = cos_data.styles.size() - 1
	
	_cosmetic_select(selected_category, selected_cosmetic, selected_style)

func _on_HScrollBar_value_changed(value):
	model.rotation_degrees.y = value
