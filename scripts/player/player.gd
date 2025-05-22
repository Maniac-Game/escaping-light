extends CharacterBody2D
class_name Player

@onready var animation_state_machine: StateMachine = $StateMachine/MovementState
@export var health = 100

func _process(delta: float) -> void:
	move_and_slide()
	
func launch_winscreen():
	var current_state = animation_state_machine.current_state
	animation_state_machine.on_child_transition(current_state,"disabled")
	#winscreen.show()

func get_state() -> State:
	return animation_state_machine.current_state

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.name == "AttackArea":
		health -= 25
		if health <= 0:
			$Hitbox/CollisionShape2D.disabled = true
			var current_state = animation_state_machine.current_state
			animation_state_machine.on_child_transition(current_state,"death")
			#trigger lose screen
