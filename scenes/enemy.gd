class_name UfoEnemy extends CharacterBody2D

#readthedocs, kind of: https://docs.godotengine.org/en/stable/tutorials/navigation/navigation_using_navigationagents.html#actor-as-characterbody3d
#readtehdocs: https://docs.godotengine.org/en/stable/tutorials/navigation/navigation_introduction_2d.html#setup-for-2d-scene

@export var target_position : Vector2 = Vector2(30, 30)
@export var acceleration := 50.0
@export var max_speed := 250.0

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var compute_destination : bool = true

func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 4.0

	# Make sure to not await during _ready.
	call_deferred("actor_setup")

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(target_position)
	
func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target

func _physics_process(_delta):
	
	if navigation_agent.is_navigation_finished():
		if compute_destination:
			queue_free()
		return
		
	var direction = Vector3()
	
	direction = navigation_agent.get_next_path_position() - global_position
	direction = direction.normalized()
	
	velocity += direction.rotated(rotation) * acceleration
	velocity = velocity.limit_length(max_speed)

	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(velocity)
	else:
		_on_velocity_computed(velocity)
	
	move_and_slide()

func _on_velocity_computed(safe_velocity: Vector2):
	velocity = safe_velocity
	move_and_slide()
