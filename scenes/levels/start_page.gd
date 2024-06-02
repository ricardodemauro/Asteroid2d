extends Node2D

@export var level1_scene : PackedScene

func _on_start_button_pressed():
	var path = "res://scenes/levels/level1_starting.tscn"
	
	Global.change_scene_with_transition(path)
	#Global.goto_packed_scene(level1_scene)
