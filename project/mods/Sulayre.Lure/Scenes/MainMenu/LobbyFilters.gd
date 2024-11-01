extends HBoxContainer
onready var mainmenu = get_tree().get_current_scene()

func _process(delta):
	if mainmenu:
		$"%LureOnly".disabled = mainmenu.disabled or mainmenu.refreshing
		$"%ShowFull".disabled = mainmenu.disabled or mainmenu.refreshing
		$"%ShowMismatch".disabled = mainmenu.disabled or mainmenu.refreshing
		$"%DedicatedOnly".disabled = mainmenu.disabled or mainmenu.refreshing
