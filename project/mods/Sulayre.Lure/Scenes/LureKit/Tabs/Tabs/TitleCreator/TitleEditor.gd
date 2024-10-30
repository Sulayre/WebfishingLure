extends Panel

const TITLE_ICON = preload("res://Assets/Textures/CosmeticIcons/cosmetic_icons62.png")

onready var LureKit = get_tree().get_current_scene()

onready var idfield = $"%IDField"
onready var namefield = $"%NameField"
onready var descfield = $"%DescField"
onready var textfield = $"%TextField"
onready var idpreview = $"%IdPreview"
onready var titlepreview = $"%TitlePreview"
onready var invid = $"%InvalidID"

var requirements = [false,false,false]

func _on_GamePath_text_changed():
	var valid = idfield.text.is_valid_filename() and !(" " in idfield.text)
	var modid = LureKit.selected_mod_data["manifest"]["Id"]
	if valid:
		idpreview.text = modid+"."+idfield.text
	invid.visible = !valid
	requirements[0] = valid
	_refresh_create()


func _on_NameField_focus_exited():
	requirements[1] = !(namefield.text == "")
	if namefield.text == "": 
		namefield.text = "Name can't be empty!"
	_refresh_create()


func _on_TextField_text_changed():
	$"%InvalidTitle".visible = textfield.text == ""
	requirements[2] = !(textfield.text == "")
	titlepreview.bbcode_text = "[center]"+textfield.text+"[/center]"
	_refresh_create()

func _refresh_create():
	$"CreateButton".disabled = !(requirements[0] and requirements[1] and requirements[2])

func _on_CreateButton_pressed():
	var title_res = CosmeticResource.new()
	title_res.icon = TITLE_ICON
	title_res.name = namefield.text
	title_res.desc = descfield.text
	title_res.title = textfield.text
	LureKit.selected_mod_data["files"]["resources"].append(title_res)
	
