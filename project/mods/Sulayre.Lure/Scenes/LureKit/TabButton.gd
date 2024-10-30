extends GenericUIButton

export var tab_id:String

signal _pressed_tab(tab_id)

func _on_BtnGen_pressed():
	emit_signal("_pressed_tab",tab_id)
