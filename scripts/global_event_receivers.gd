extends Node


func _on_asteroid_exploded(asteroid_position, size : Asteroid.AsteroidSize):
	Global.update_score_asteroid(size)
	
	GlobalAudio.play_asteroid_hit()
	
	match size:
		Asteroid.AsteroidSize.LARGE:
			var spaw_times = randf_range(1, 5)
			for i in spaw_times:
				Global.respaw_asteroid(asteroid_position, Asteroid.AsteroidSize.MEDIUM)
			
		Asteroid.AsteroidSize.MEDIUM:
			var spaw_times = randf_range(1, 10)
			for i in spaw_times:
				Global.respaw_asteroid(asteroid_position, Asteroid.AsteroidSize.SMALL)
		Asteroid.AsteroidSize.SMALL:
			pass

func _on_player_died():
	Global.lives = Global.lives - 1
	GlobalAudio.play_player_die()
	
	if Global.lives == 0:
		Global.show_game_over()
	else:
		Global.spaw_player()

func _on_restart_requested():
	Global.restart_game()
