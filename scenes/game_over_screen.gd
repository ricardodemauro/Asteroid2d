class_name GameOverScreen extends Control

signal on_restart_game_signal()

func _on_restart_button_pressed():
	emit_signal("on_restart_game_signal")
