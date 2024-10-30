extends Panel

onready var LureKit = get_tree().get_current_scene()

func _ready():
	_refresh_list()

func _refresh_list():
	for children in $"%ModList".get_children():
		children.queue_free()
	var dir:Directory = Directory.new()
	var file = File.new()
	if dir.open(LureKit.mods_folder_path) == OK:
		dir.list_dir_begin(true)
		var next = dir.get_next()
		while next != "":
			if dir.current_is_dir():
				if file.open(LureKit.mods_folder_path+"/"+next.plus_file("manifest.json"),File.READ) == OK:
					var txt = file.get_as_text()
					var parsed = JSON.parse(txt).result
					print(parsed)
					if typeof(parsed) == TYPE_DICTIONARY:
						var modBtn:Button = preload("res://mods/Sulayre.Lure/Scenes/LureKit/Tabs/Tabs/ModLoader/ModButton.tscn").instance()
						modBtn.name = parsed["Id"]
						modBtn.stored_mod = parsed["Id"]
						if "Metadata" in parsed:
							modBtn.text = parsed["Metadata"]["Name"]
							if "Tags" in parsed["Metadata"].keys():
								if "LureKit" in parsed["Metadata"]["Tags"]:
									modBtn.disabled = false
									modBtn.connect("_mod_btn_pressed",LureKit,"_load_mod")
								else:
									if parsed["Id"] != "Sulayre.Lure":
										modBtn.text += " (Incompatible)"
							else:
								modBtn.text += " (Incompatible)"
						else:
							modBtn.text = parsed["Id"]
							modBtn.text += " (Incompatible)"
						$"%ModList".add_child(modBtn)
					file.close()
			next = dir.get_next()
		dir.list_dir_end()
