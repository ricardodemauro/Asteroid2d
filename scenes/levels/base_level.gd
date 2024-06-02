extends Node2D

@onready var lasers = $Lasers
@onready var player : CharacterBody2D = $Player
@onready var asteroids = $Asteroids
@onready var hud = %HUD as HudController
@onready var player_spawn_position = $PlayerSpawnPosition
@onready var player_span_area : GameSpawnArea = $PlayerSpawnPosition/GameSpawnArea

@export var asteroid_scene : Array[PackedScene]
@export var asteroid_count : int = 1
@export var asteroid_velocity : float = 1
#@onready var asteroid_scene = preload("res://scenes/asteroid.tscn")


@onready var lives : int = 3:
	set(value):
		lives = value
		hud.init_lives(lives)

var score := 0:
	set(value):
		score = value
		hud.score = score

func _ready():
	score = 0
	lives = 3
	
	setup_initial_asteroids(asteroid_count)
	
	player.connect("died", _on_player_died)

func _on_player_laser_shot(laser):
	$LaserSound.play()
	lasers.add_child(laser)

func _on_asteroid_exploded(asteroid_position, size, points, identifier):
	score += points
	
	$AsteroidHitSound.play()
	
	match size:
		Asteroid.AsteroidSize.LARGE:
			var spaw_times = randf_range(1, 5)
			for i in spaw_times:
				spaw_asteroid(identifier, asteroid_position, Asteroid.AsteroidSize.MEDIUM, randf_range(50, 100))
			
		Asteroid.AsteroidSize.MEDIUM:
			var spaw_times = randf_range(1, 10)
			for i in spaw_times:
				spaw_asteroid(identifier, asteroid_position, Asteroid.AsteroidSize.SMALL, randf_range(50, 100))
		Asteroid.AsteroidSize.SMALL:
			pass
	
func setup_initial_asteroids(quantity : int):
	for i in quantity:
		var asteroid_position = Vector2(0, 0)
		var idx = i % asteroid_scene.size()
		spaw_asteroid(idx, asteroid_position, Asteroid.AsteroidSize.LARGE, randf_range(50, 100))

func spaw_asteroid(identifier : int, asteroid_position : Vector2, size : Asteroid.AsteroidSize, speed : float):
	
	var tmp = asteroid_scene[identifier].instantiate() as Asteroid
	tmp.global_position = asteroid_position
	tmp.size = size
	
	tmp.speed = speed
	tmp.identifier = identifier
	
	tmp.connect("exploded", _on_asteroid_exploded)
	
	asteroids.call_deferred("add_child", tmp)

func _on_player_died():
	lives = lives - 1
	
	$PlayerDieSound.play()
	
	player.global_position = player_spawn_position.global_position
	
	if lives == 0:
		#get_tree().reload_current_scene()
		await  get_tree().create_timer(1).timeout
		$UI/GameOverScreen.visible = true
	else:
		await  get_tree().create_timer(1).timeout
		
		while !player_span_area.is_empty:
			await  get_tree().create_timer(0.3).timeout
		
		player.respawn(player_spawn_position.position)


func _on_game_over_screen_on_restart_game_signal():
	$UI/GameOverScreen.visible = false
	lives = 3
	#player.respawn(player_spawn_position.position)
	get_tree().reload_current_scene()
