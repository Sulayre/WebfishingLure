extends Control

onready var id = $"%ModId"
onready var pck = $"%PckName"
onready var modname = $"%ModName"
onready var author = $"%ModAuthor"
onready var version = $"%ModVersion"
onready var desc = $"%ModDescription"

onready var fid = $"%FinalId"
onready var fpck = $"%FinalPck"
onready var fmodname = $"%FinalName"
onready var fauthor = $"%FinalAuthor"
onready var fversion = $"%FinalVersion"
onready var fdesc = $"%FinalDescription"

func _on_modgen_changed_step(index):
	fid.text = id.text
	fpck.text = pck.text
	fmodname.text = modname.text
	fauthor.text = author.text
	fversion.text = version.text
	fdesc.text = desc.text
