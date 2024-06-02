extends CanvasLayer

enum AnimationState { STOPPED, PLAYING_FORWARD, PLAYING_BACKWARDS }

var player_state : AnimationState = AnimationState.STOPPED
var next_scene : String
var next_packed_scene : PackedScene

func change_to_scene(target: String, type: String = 'dissolve') -> void:
	if type == 'dissolve':
		transition_dissolve()
		next_scene = target
		
		if $AnimationPlayer.is_connected("animation_finished", _on_packed_animation_finished):
			$AnimationPlayer.disconnect("animation_finished", _on_packed_animation_finished)
			
		$AnimationPlayer.connect("animation_finished", _on_animation_finished)
		
func change_to_packed_scene(target: PackedScene, type: String = 'dissolve') -> void:
	if type == 'dissolve':
		transition_dissolve()
		next_packed_scene = target
		
		if $AnimationPlayer.is_connected("animation_finished", _on_animation_finished):
			$AnimationPlayer.disconnect("animation_finished", _on_animation_finished)

		$AnimationPlayer.connect("animation_finished", _on_packed_animation_finished)

func transition_dissolve() -> void:
	$AnimationPlayer.play('dissolve')
	player_state = AnimationState.PLAYING_FORWARD
	

func transition_clouds(target: String) -> void:
	await $AnimationPlayer.play('clouds_in')
	#yield($AnimationPlayer,'animation_finished')
	get_tree().change_scene(target)
	await  $AnimationPlayer.play('clouds_out')

func _on_animation_finished(animation_name: String) -> void:
	if player_state == AnimationState.PLAYING_FORWARD:
		Global.goto_scene(next_scene)
	
	_on_animation_player_animation_finished(animation_name)
	
func _on_packed_animation_finished(animation_name: String) -> void:
	if player_state == AnimationState.PLAYING_FORWARD:
		Global.goto_packed_scene(next_packed_scene)
	
	_on_animation_player_animation_finished(animation_name)

func _on_animation_player_animation_finished(_anim_name):
	
	if player_state == AnimationState.PLAYING_FORWARD:
		player_state = AnimationState.PLAYING_BACKWARDS
		$AnimationPlayer.play_backwards('dissolve')
	else:
		player_state = AnimationState.STOPPED	
	
