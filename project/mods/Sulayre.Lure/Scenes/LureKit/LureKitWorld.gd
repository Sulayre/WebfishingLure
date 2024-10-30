extends ViewportContainer


func _ready():
	PlayerData.connect("_hide_hud_toggle", self, "_hide_hud_toggle")
	PlayerData.emit_signal("_hide_hud_toggle", false)
	$Viewport / main / track_camera / Camera.current = true

func _hide_hud_toggle(on):
	print(on)
	$shader_ignore.visible = not on

func _import_child(child):
	child.get_parent().call_deferred("remove_child", child)
	yield (child, "tree_exited")
	$shader_ignore.add_child(child)
