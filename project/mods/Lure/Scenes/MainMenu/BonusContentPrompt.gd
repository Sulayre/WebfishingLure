extends Control

func _disable_prompt(bonus:bool):
	var path = OS.get_executable_path().get_base_dir().plus_file("GDWeave/configs/Lure.json")
	var file = File.new()
	if file.open(path,File.READ) == OK:
		var p = JSON.parse(file.get_as_text())
		file.close()
		var result = p.result
		result["bonus_prompt"] = false
		result["bonus_content"] = bonus
		if file.open(path,File.WRITE) == OK:
			file.store_string(JSON.print(result," "))
			file.close()
	queue_free()

func _on_Sure_pressed():
	get_node("/root/SulayreLure")._bonus_content_load()
	_disable_prompt(true)


func _on_Nah_pressed():
	_disable_prompt(false)
