extends MarginContainer

var player: Player

func _ready() -> void:
	player = get_tree().root.get_node_or_null("Level/y-sort/Player")

func _process(delta: float) -> void:
	if player != null:
		var current_health = player.get_health()
		$Health.set_health(current_health)
