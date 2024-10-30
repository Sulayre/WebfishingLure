extends Panel

onready var LureKit = get_tree().get_current_scene()

func _on_GamePath_text_changed():
	var id = $"%IDField"
	id.text = id.text.replace(" ","")
	var valid = id.text.is_valid_filename()
	var modid = LureKit.selected_mod_data["manifest"]["Id"]
	if valid:
		$"%IdPreview".text = modid+"."+id.text
	$"%InvalidID".visible = valid
