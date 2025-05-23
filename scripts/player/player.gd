extends CharacterBody2D
class_name Player

@onready var animation_state_machine: StateMachine = $StateMachine/MovementState
@export var health = 100
@export var stamina = 100
@onready var enemy: CharacterBody2D = null
var current_state: State

func _process(delta: float) -> void:
	current_state = animation_state_machine.current_state
	move_and_slide()
	
func launch_winscreen():
	animation_state_machine.on_child_transition(current_state,"disabled")
	#winscreen.show()

func get_state() -> State:
	return animation_state_machine.current_state

func get_health():
	return health

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.name == "AttackArea":
		enemy = area.get_parent()
		print_debug("Health: ", health)
		health -= 20
		if health <= 0:
			$Hitbox/CollisionShape2D.disabled = true
			$BodyCollision.disabled = true
			var current_state = animation_state_machine.current_state
			animation_state_machine.on_child_transition(current_state,"death")
		else:
			animation_state_machine.on_child_transition(current_state, "knockback")
