extends Control

onready var id = $"%ModId"
onready var pck = $"%PckName"
onready var modname = $"%ModName"
onready var author = $"%ModAuthor"
onready var version = $"%ModVersion"
onready var desc = $"%ModDescription"

var requirements = {
	"id":false,
	"version":false,
	"name":false,
	"author":false,
}

func _check_complete():
	var can = true
	for requirement in requirements.values():
		if !requirement:
			can = false
	$"%Next".disabled = !can


func _on_ModId_text_changed():
	var valid = id.text.is_valid_filename()
	$"%InvalidId".visible = !valid
	requirements.id = valid
	if valid: pck.text = id.text + ".pck"
	_check_complete()
	
func _on_ModName_focus_exited():
	var valid = modname.text != ""
	requirements.name = valid
	if !valid:
		modname.text = "You must give your mod a name!"
	_check_complete()


func _on_ModVersion_text_changed():
	var valid:bool
	var splits = version.text.split(".",false,2)
	if splits.size() == 3:
		if splits[0].is_valid_integer() and splits[1].is_valid_integer() and splits[2].is_valid_integer():
			valid = true
	requirements.version = valid
	$"%VerHint".visible = valid
	$"%VerFormat".visible = !valid
	_check_complete()


func _on_ModAuthor_focus_exited():
	var valid = author.text != ""
	requirements.author = valid
	if !valid:
		author.text = "Add an author, don't forget to credit your work!"
	_check_complete()



func _on_modgen_changed_step(index):
	_check_complete()


func _on_ModId_focus_exited():
	var mods = _get_mod_ids()
	if id.text in mods:
		id.text = "ID in use by an installed mod!"
	
func _get_mod_ids() -> Array:
	var loaded_mods = []
	var dir:Directory = Directory.new()
	if dir.open("res://mods") == OK:
		dir.list_dir_begin(true)
		var next = dir.get_next()
		while next != "":
			if dir.current_is_dir():
				loaded_mods.append(next)
			next = dir.get_next()
		dir.list_dir_end()
	print(loaded_mods)
	return loaded_mods


func _on_CreateMod_pressed():
	for value in requirements:
		value = false
