extends Node

var current_scene = null

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)

func goto_packed_scene(scene : PackedScene):
	call_deferred("_deferred_goto_packed_scene", scene)
	
func change_scene_with_transition(path : String) -> void:
	SceneTransition.change_to_scene(path)

func change_packed_scene_with_transition(path : PackedScene) -> void:
	SceneTransition.change_to_packed_scene(path)

func _deferred_goto_packed_scene(scene : PackedScene):
	# It is now safe to remove the current scene.
	current_scene.free()

	# Instance the new scene.
	current_scene = scene.instantiate()

	# Add it to the active scene, as child of root.
	get_tree().root.add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene_to_file() API.
	get_tree().current_scene = current_scene


func goto_scene(path : String):
	call_deferred("_deferred_goto_scene", path)


func _deferred_goto_scene(path : String):
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
