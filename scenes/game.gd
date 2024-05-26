extends Node2D

@onready var lasers = $Lasers
@onready var player : CharacterBody2D = $Player
@onready var asteroids = $Asteroids
@onready var hud = %HUD as HudController
@onready var player_spawn_position = $PlayerSpawnPosition
@onready var player_span_area : GameSpawnArea = $PlayerSpawnPosition/GameSpawnArea
@onready var asteroid_scene = preload("res://scenes/asteroid.tscn")
@onready var enemy_scene = preload("res://scenes/enemy.tscn")
@onready var rng = RandomNumberGenerator.new()

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
	for asteroid in asteroids.get_children():
		asteroid.connect("exploded", _on_asteroid_exploded)
		
	player.connect("died", _on_player_died)
	
func _process(_delta):
	if Input.is_action_just_pressed("alien"):
		spaw_ufo()

func _on_player_laser_shot(laser):
	$LaserSound.play()
	lasers.add_child(laser)

func _on_asteroid_exploded(asteroid_position, size, points):
	score += points
	
	$AsteroidHitSound.play()
	
	match size:
		Asteroid.AsteroidSize.LARGE:
			var spaw_times = randf_range(1, 5)
			for i in spaw_times:
				spaw_asteroid(asteroid_position, Asteroid.AsteroidSize.MEDIUM)
			
		Asteroid.AsteroidSize.MEDIUM:
			var spaw_times = randf_range(1, 10)
			for i in spaw_times:
				spaw_asteroid(asteroid_position, Asteroid.AsteroidSize.SMALL)
		Asteroid.AsteroidSize.SMALL:
			pass
	

func spaw_asteroid(asteroid_position, size):
	var tmp = asteroid_scene.instantiate() as Asteroid
	tmp.global_position = asteroid_position
	tmp.size = size
	
	tmp.speed = randf_range(50, 100)
	
	tmp.connect("exploded", _on_asteroid_exploded)
	
	#asteroids.add_child(tmp)
	asteroids.call_deferred("add_child", tmp)
	
func spaw_ufo():
	var h = get_viewport_rect().size.y
	var w = get_viewport_rect().size.x
	
	rng.randomize()
	var rand_landing = rng.randi_range(1, h)
	var landing_location = Vector2(-40, rand_landing)
	
	var rand_spawn = rng.randi_range(1, h)
	var spawn_location = Vector2(w, rand_spawn)
	
	var scene = enemy_scene.instantiate() as UfoEnemy
	scene.target_position = landing_location
	scene.global_position = spawn_location
	#scene.max_speed = 400
	
	get_tree().root.add_child(scene)

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


func _on_timer_timeout():
	spaw_ufo()
