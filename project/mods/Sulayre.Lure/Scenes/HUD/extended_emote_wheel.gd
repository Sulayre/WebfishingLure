extends Control

var Lure
var index:int = 0
var open = false
var pressed = false
var hovered = null

onready var wheel = $wheel
const button:PackedScene = preload("res://mods/Sulayre.Lure/Scenes/HUD/emote_button_lure.tscn")

signal _play_emote(emote_id, emotion)

func _ready():
	if !OS.has_feature("editor"):
		Lure = get_node("/root/SulayreLure")
		var emotes:Array = Lure.modded_emotes.duplicate(true)
		var emote_count = emotes.size()
		var pages = ceil(float(emote_count)/8.0)
		for page in pages:
			prints("generating emote page number",page)
			var new_page = $wheel/GridContainer.duplicate()
			$wheel.add_child(new_page,true)
			for wheel_index in range(8):
				print(wheel_index)
				var next_emote = emotes.pop_front()
				var new_button = button.instance()
				var old_button = new_page.get_node(str(wheel_index))
				print(old_button)
				new_page.add_child_below_node(old_button,new_button,true)
				old_button.queue_free()
				if next_emote:
					new_button.add_to_group("modded_emote")
					new_button.set("emote_id",next_emote["id"])
					new_button.set("emotion",next_emote["emotion"])
					new_button.set("emote_icon",next_emote["icon"])
					new_button.get_node("TextureRect").texture = next_emote["icon"]
					new_button.name = next_emote["id"]
				else:
					new_button.get_node("Button").disabled = true
	else:
		print("LURE'S CUSTOM EMOTES DON'T CURRENTLY WORK IN THE EDITOR WITHOUT SOME TWEAKS IN PLAYER.GD")
	hovered = null
	for w in wheel.get_children():
		if w is HBoxContainer: continue
		var i = 0
		for child in w.get_children():
			if child.is_in_group("emote_ignore"): continue
			child.connect("mouse_entered", self, "_highlight", [child])
			child.connect("mouse_exited", self, "_dehighlight", [child])
			child.connect("pressed", self, "_pressed", [child])
			i += 1
	_swap_page(0)

func _swap_page(increment:int):
	var pages = wheel.get_children()
	pages.remove(0) # we take out the arrow controls
	index += increment
	index = clamp(index,0,pages.size()-1)
	for page in pages:
		page.visible = index == pages.find(page)
	$"%Left".modulate.a = 255 if index > 0 else 0
	$"%Right".modulate.a = 255 if index < pages.size()-1 else 0

func _open():
	
	open = true
	pressed = false

func _close():
	if not open: return 
	open = false
	if hovered and not pressed: hovered.emit_signal("pressed")

func _pressed(child):
	pressed = true
	emit_signal("_play_emote", child.emote_id, child.emotion)

func _physics_process(delta):
	modulate.a = lerp(modulate.a, float(open), 0.4)
	visible = modulate.a > 0.02
	
	var scale = 1.0 if open else 0.6
	wheel.rect_scale.x = lerp(wheel.rect_scale.x, scale, 0.4)
	wheel.rect_scale.y = lerp(wheel.rect_scale.y, scale, 0.4)

func _highlight(button):
	hovered = button
	for tab in $wheel.get_children():
		if tab is HBoxContainer: continue
		for child in tab.get_children():
			if child.is_in_group("emote_ignore"): continue
			print(child.emote_id)
			child._highlight(child == button)

func _dehighlight(button):
	if hovered == button: hovered = null
	for tab in $wheel.get_children():
		if tab is HBoxContainer: continue
		for child in tab.get_children():
			if child.is_in_group("emote_ignore"): continue
			child._highlight(false)

func _on_Button_pressed():
	pressed = true
	emit_signal("_play_emote", "", "")


func _on_Left_pressed():
	_swap_page(-1)


func _on_Right_pressed():
	_swap_page(1)
