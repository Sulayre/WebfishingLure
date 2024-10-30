extends Control

onready var gerald:Texture = preload("res://mods/Sulayre.Lure/GeraldLogo.png")
onready var btn:TextureButton = $Gerald

func _ready():
	pass
	#btn.texture_click_mask = BitMap.new().create_from_image_alpha(gerald.get_data())


func _on_Gerald_mouse_entered():
	$AnimationPlayer.play("hover")


func _on_Gerald_mouse_exited():
	$AnimationPlayer.play_backwards("hover")


func _on_Gerald_pressed():
	get_tree().change_scene("res://mods/Sulayre.Lure/Scenes/LureKit/LureKitMain.tscn")
