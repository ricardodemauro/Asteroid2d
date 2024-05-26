extends Node

#readthedocs : https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html

var rng = RandomNumberGenerator.new()

#region Properties
@onready var lives : int = 3:
	set(value):
		lives = value
		NodeHud.set_lives(value)
		
@onready var score : int = 0:
	set(value):
		score = value
		NodeHud.set_score(value)
#endregion

#region Scenes
@onready var enemy_scene = preload("res://scenes/enemy.tscn")
@onready var asteroid_scene = preload("res://scenes/asteroid.tscn")
#endregion

#region Nodes
var NodeHud : Hud:
	get:
		return current_scene.get_node_or_null("%HUD") as Hud
		
var NodeAsteroids : Node:
	get:
		return current_scene.get_node_or_null("%Asteroids") as Node
		
var NodePlayer : Player:
	get:
		return current_scene.get_node_or_null("%Player") as Player
		
var NodeGameOverScreen : GameOverScreen:
	get:
		return current_scene.get_node_or_null("%GameOverScreen") as GameOverScreen
		
var NodePlayerSpawnPosition : Node2D:
	get:
		return current_scene.get_node_or_null("%PlayerSpawnPosition") as Node2D
		
var NodeGameSpawnArea : GameSpawnArea:
	get:
		return current_scene.get_node_or_null("%GameSpawnArea") as GameSpawnArea
#endregion

var current_scene : Node2D = null
var viewport_size : Rect2 = Rect2(0, 0, 0, 0)

var viewport_heigth : float:
	get: return viewport_size.size.y
var viewport_width : float:
	get: return viewport_size.size.x

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
	
	create_connections()
	
func create_connections():
	for asteroid in NodeAsteroids.get_children():
		asteroid.connect("exploded", GlobalEventReceivers._on_asteroid_exploded)
		
	NodePlayer.connect("died", GlobalEventReceivers._on_player_died)
	NodeGameOverScreen.connect("on_restart_game_signal", GlobalEventReceivers._on_restart_requested)
	
func goto_scene(path): 
	call_deferred("_deferred_goto_scene", path)
	
func realod_scene():
	current_scene.get_tree().reload_current_scene()

func _deferred_goto_scene(path):
	# It is now safe to remove the current scene.
	current_scene.free()

	# Load the new scene.
	var s = ResourceLoader.load(path)

	# Instance the new scene.
	current_scene = s.instantiate()

	# Add it to the active scene, as child of root.
	get_tree().root.add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene_to_file() API.
	get_tree().current_scene = current_scene

func update_score_asteroid(size : Asteroid.AsteroidSize):
	match size:
		Asteroid.AsteroidSize.LARGE:
			score += 50
			
		Asteroid.AsteroidSize.MEDIUM:
			score += 100
			
		Asteroid.AsteroidSize.SMALL:
			score += 200
			
		_:
			pass

func spaw_ufo():

	rng.randomize()
	var rand_landing = rng.randi_range(1, viewport_heigth)
	var landing_location = Vector2(-40, rand_landing)
	
	var rand_spawn = rng.randi_range(1, viewport_heigth)
	var spawn_location = Vector2(viewport_width, rand_spawn)
	
	var scene = enemy_scene.instantiate() as UfoEnemy
	scene.target_position = landing_location
	scene.global_position = spawn_location
	#scene.max_speed = 400
	
	get_tree().root.add_child(scene)

func respaw_asteroid(asteroid_position, size):
	var tmp = asteroid_scene.instantiate() as Asteroid
	tmp.global_position = asteroid_position
	tmp.size = size
	
	tmp.speed = randf_range(50, 100)
	
	tmp.connect("exploded", GlobalEventReceivers._on_asteroid_exploded)
	
	#asteroids.add_child(tmp)
	NodeAsteroids.call_deferred("add_child", tmp)

func spaw_player():
	while NodeGameSpawnArea.is_empty:
		await current_scene.get_tree().create_timer(0.3).timeout

	NodePlayer.respawn(NodeGameSpawnArea.position)

func show_game_over():
	await  get_tree().create_timer(1).timeout
	NodeGameOverScreen.visible = true

func restart_game():
	NodeGameOverScreen.visible = false
	Global.lives = 3
	Global.realod_scene()
