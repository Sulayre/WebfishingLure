extends Control

onready var steps = $Steps.get_children()
onready var current = steps[0]

onready var LureKit = get_tree().get_current_scene()

signal changed_step(step)

func _ready():
	_change_step(0)

func _change_step(increment:int):
	var current_index = steps.find(current)
	var new_index = current_index + increment
	var step_count = steps.size()
	if new_index > -1 and new_index < step_count:
		current = steps[new_index]
	for step in steps:
		step.visible = current == step
	$"%Previous".visible = new_index > 0
	if new_index == 0:$"%Next".disabled = false
	$"%Next".visible = new_index < step_count - 1
	emit_signal("changed_step",new_index)
	
func _on_Next_pressed():
	_change_step(1)


func _on_Previous_pressed():
	_change_step(-1)
