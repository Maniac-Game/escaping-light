extends LinkButton

@export var scene_to_load: String

func _on_pressed():
	get_tree().change_scene_to_file("res://scenes/" + scene_to_load + ".tscn")
