extends "res://mods/Sulayre.Lure/Scenes/LureKit/Tabs/TabNode.gd"

onready var setup = $Steps/ManifestSetup
onready var review = $Steps/ManifestReview

func _ready():
	connect("changed_step",setup,"_on_modgen_changed_step")
	connect("changed_step",review,"_on_modgen_changed_step")

func _on_CreateMod_pressed():
	var dir:Directory = Directory.new()
	var file:File = File.new()
	var mod_data = LureKit.DATA_TEMPLATE.duplicate(true)
	var manifest = {
		"Id": $"%FinalId".text,
		"PackPath": $"%FinalPck".text,
		"Dependencies": ["Sulayre.Lure"],
		"Metadata": {
			"Name": $"%FinalName".text,
			"Author": $"%FinalAuthor".text,
			"Version": $"%FinalVersion".text,
			"Description": $"%FinalDescription".text,
			"Tags": ["LureKit"],
		}
	}
	mod_data["manifest"] = manifest
	LureKit.selected_mod_data = mod_data
	LureKit.emit_signal("refresh_selected")
	LureKit.tab_swap()
	PopupMessage._show_popup("Mod created successfuly!")


func _on_modgen_changed_step(step):
	print(step)
	$"StepButtons".visible = false if step == 0 else true
