class_name Game extends Node2D

@onready var lasers = $Lasers
@onready var player : CharacterBody2D = $Player
@onready var asteroids = $Asteroids
@onready var player_spawn_position = $PlayerSpawnPosition
@onready var player_span_area : GameSpawnArea = $PlayerSpawnPosition/GameSpawnArea

func _ready():
	Global.viewport_size = get_viewport_rect()
	
func _process(_delta):
	if Input.is_action_just_pressed("alien"):
		Global.spaw_ufo()

func _on_player_laser_shot(laser):
	#%LaserSound.play()
	GlobalAudio.play_laser()
	lasers.add_child(laser)

func _on_timer_timeout():
	Global.spaw_ufo()
