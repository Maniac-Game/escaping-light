extends Node2D
@onready var player = $"y-sort/Player"

func _on_win_trigger_body_entered(body: Node2D) -> void:
	if body is Player:
		#trigger win
		print("Win")
		player.launch_winscreen()
		pass
