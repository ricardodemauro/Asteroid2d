extends Camera2D
class_name GameCamera

@export var random_strength : float = 30.0
@export var shake_fade : float = 5.0

var shake_strength : float = 0.0

func _process(delta):
	if Input.is_action_just_pressed("fire"):
		shake()
		
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shake_strength * delta)
		
		offset = random_offset()
	

func shake():
	shake_strength = random_strength

func random_offset() -> Vector2:
	var r = shake_strength
	var rand_y = Global.get_next_random_range(-r, r)
	var rand_x = Global.get_next_random_range(-r, r)
	
	return Vector2(rand_x, rand_y)
