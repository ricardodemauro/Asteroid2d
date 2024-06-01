class_name Asteroid extends Area2D

signal exploded(position, size, points)

var movement_vector := Vector2(0, -1)
var points : int:
	get:
		match(size):
			AsteroidSize.LARGE:
				return 200
			AsteroidSize.MEDIUM:
				return 100
			AsteroidSize.SMALL:
				return 50	
			_:
				return 0

enum AsteroidSize{LARGE, MEDIUM, SMALL}

@export var size : AsteroidSize = AsteroidSize.LARGE
@export var speed : float = 50

@onready var sprite = $Sprite2D
@onready var cshape = $CollisionShape2D

func _ready():
	rotation = randf_range(0, 2  * PI)
	
	match size:
		AsteroidSize.LARGE:
			speed = randf_range(50, 100)
			sprite.texture = preload("res://assets/textures/meteorGrey_big4.png")
			#cshape.shape = preload("res://resources/asteroid_cshape_large.tres")
			cshape.set_deferred("shape", preload("res://resources/asteroid_cshape_large.tres"))
		AsteroidSize.MEDIUM:
			speed = randf_range(100, 150)
			sprite.texture = preload("res://assets/textures/meteorGrey_med2.png")
			#cshape.shape = preload("res://resources/asteroid_cshape_medium.tres")
			cshape.set_deferred("shape", preload("res://resources/asteroid_cshape_medium.tres"))
		AsteroidSize.SMALL:
			speed = randf_range(100, 200)
			sprite.texture = preload("res://assets/textures/meteorGrey_tiny1.png")
			#cshape.shape = preload("res://resources/asteroid_cshape_small.tres")
			cshape.set_deferred("shape", preload("res://resources/asteroid_cshape_small.tres"))

func _process(_delta):
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()

func _physics_process(delta):
	global_position += movement_vector.rotated(rotation) * speed * delta
	
	var radius = cshape.shape.radius
	var screen_size = get_viewport_rect().size
	if (global_position.y+radius) < 0:
		global_position.y = (screen_size.y+radius)
	elif (global_position.y-radius) > screen_size.y:
		global_position.y = -radius
	if (global_position.x+radius) < 0:
		global_position.x = (screen_size.x+radius)
	elif (global_position.x-radius) > screen_size.x:
		global_position.x = -radius


func explode():
	emit_signal("exploded", global_position, size, points)
	queue_free()

func _on_body_entered(body):
	if body is Player:
		var player = body as Player
		player.die()
