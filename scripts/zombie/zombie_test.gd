extends Node2D

@onready var zombie = $Zombie
@onready var state_label = $CanvasLayer/Label


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_instance_valid(zombie):
		state_label.text = str(zombie.current_state) + " " + str(zombie.current_attack_phase)
	else:
		state_label.text = "dead"
