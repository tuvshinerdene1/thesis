# levelManager.gd
extends Node

func change_level(target_level: PackedScene) -> void:
	if not target_level:
		return
		
	# optional : add fade-out animation here
	
	get_tree().call_deferred("change_scene_to_packed", target_level)
