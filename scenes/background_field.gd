extends Node2D

@export var planet_velocity : float = 10

func _process(_delta):
	var velocit_vector = Vector2(planet_velocity, 0)
	var new_position = $PlanetAnimated2d.global_position + velocit_vector
	
	$PlanetAnimated2d.global_position = new_position
