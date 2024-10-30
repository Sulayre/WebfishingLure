extends GenericUIButton

var stored_mod = ""
signal _mod_btn_pressed(mod_id)

func _on_ModButton_pressed():
	print("ping")
	emit_signal("_mod_btn_pressed",stored_mod)
