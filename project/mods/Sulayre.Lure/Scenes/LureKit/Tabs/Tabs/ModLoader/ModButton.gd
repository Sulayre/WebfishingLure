extends GenericUIButton

signal _mod_btn_pressed(mod_id)

func _on_ModButton_pressed():
	emit_signal("_mod_btn_pressed",name)
