class_name Hud extends Control

var uilife_scene = preload("res://scenes/ui_life.tscn")

@onready var lives = $LivesDisplay
@onready var score = $ScoreDisplay as Label

func set_score(value):
	score.text = "SCORE: " + str(value)

func set_lives(value):
	for ul in lives.get_children():
		ul.queue_free()
		
	for i in value:
		var ul = uilife_scene.instantiate()
		lives.add_child(ul)
