class_name Player extends CharacterBody2D

signal laser_shot(laser)
signal died

@export var acceleration := 10.0
@export var max_speed := 350.0
@export var rotation_speed := 250.0
@export var rate_fire : float = 0.30

var alive := true

@onready var muzzle = $Muzzle
@onready var sprite = $Sprite2D

@export var laser_scene : PackedScene
#var laser_scena = preload("res://scenes/characters/player/laser.tscn")

var shoot_cd = false

func _process(_delta):
	if !alive: return
	
	if Input.is_action_pressed("fire"):
		if !shoot_cd:
			shoot_cd = true
			
			shoot_laser()
			
			await  get_tree().create_timer(rate_fire).timeout
			
			shoot_cd = false

func _physics_process(delta):
	if !alive: return
	
	var input_vector := Vector2(0, Input.get_axis("up", "down"))
	
	velocity += input_vector.rotated(rotation) * acceleration
	velocity = velocity.limit_length(max_speed)
	
	if Input.is_action_pressed("right"):
		rotate(deg_to_rad(rotation_speed*delta))
	if Input.is_action_pressed("left"):
		rotate(deg_to_rad(-rotation_speed*delta))
	
	if input_vector.y == 0:
		velocity = velocity.move_toward(Vector2.ZERO, 3)
	
	move_and_slide()
	
	var screen_size = get_viewport_rect().size
	if global_position.y < 0:
		global_position.y = screen_size.y
	elif global_position.y > screen_size.y:
		global_position.y = 0
	if global_position.x < 0:
		global_position.x = screen_size.x
	elif global_position.x > screen_size.x:
		global_position.x = 0

func shoot_laser():
	var l = laser_scene.instantiate() as LaserNode
	l.global_position = muzzle.global_position
	print("global_position", l.global_position)
	
	l.rotation = rotation
	print("rotation", l.rotation)
	
	get_tree().root.add_child(l)
	
	emit_signal("laser_shot", l)

func die():
	if alive == true:
		alive = false
		emit_signal("died")
		
		sprite.visible = false
		#process_mode = Node.PROCESS_MODE_DISABLED
		$CollisionShape2D.set_deferred("disabled", true)
		

func respawn(pos):
	if alive == false:
		alive = true
		global_position = pos
		velocity = Vector2.ZERO
		
		sprite.visible = true
		#process_mode = Node.PROCESS_MODE_INHERIT
		$CollisionShape2D.set_deferred("disabled", false)
