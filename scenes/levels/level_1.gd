extends Node2D
@onready var player = $"y-sort/Player"

func _ready() -> void:
	$CanvasLayer/WinScreen.hide()
	$CanvasLayer/LoseScreen.hide()
	$CanvasLayer/InGameGUI.show()
	
func _process(delta: float) -> void:
	if player:
		var player_state = player.get_state()
		if player_state.name.to_lower() == "death":
			launch_losescreen()
			return

func _on_win_trigger_body_entered(body: Node2D) -> void:
	if body is Player:
		#trigger win
		print("Win")
		player.launch_winscreen()
		await get_tree().create_timer(1).timeout
		$CanvasLayer/WinScreen.show()
		pass

func launch_losescreen():
	await get_tree().create_timer(1).timeout
	$CanvasLayer/LoseScreen.show()
	
