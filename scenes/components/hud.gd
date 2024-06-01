class_name HudController extends Control

var uilife_scene = preload("res://scenes/components/ui_life.tscn")

@onready var lives = $Lives

@onready var score = $Score as Label:
	set(value):
		score.text = "SCORE: " + str(value)

func init_lives(amount):
	for ul in lives.get_children():
		ul.queue_free()
		
	for i in amount:
		var ul = uilife_scene.instantiate()
		lives.add_child(ul)
