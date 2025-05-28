extends CharacterBody2D
class_name Player

@onready var animation_state_machine: StateMachine = $StateMachine/MovementState
@export var health = 100

@export var stamina = 100
@export var max_stamina := 100
@export var stamina_depletion_rate := 20.0
@export var stamina_recovery_rate := 10.0
var is_sprinting := false

@onready var enemy: CharacterBody2D = null
var current_state: State

func _process(delta: float) -> void:
	current_state = animation_state_machine.current_state
	move_and_slide()
	
	# Handle stamina
	if is_sprinting:
		pass # handle in sprint.gd
	else:
		stamina += stamina_recovery_rate * delta
		stamina = clamp(stamina, 0, max_stamina)
	
func launch_winscreen():
	animation_state_machine.on_child_transition(current_state,"disabled")
	#winscreen.show()

func get_state() -> State:
	return animation_state_machine.current_state

func get_health():
	return health

func get_stamina():
	return stamina

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.name == "AttackArea" || area.name == "HitboxRight" || area.name == "HitboxLeft":
		enemy = area.get_parent()
		if area.name == "AttackArea":
			get_hit()

func get_hit():
		print_debug("Health: ", health)
		health -= 20
		if health <= 0:
			$Hitbox/CollisionShape2D.disabled = true
			$BodyCollision.disabled = true
			var current_state = animation_state_machine.current_state
			animation_state_machine.on_child_transition(current_state,"death")
		else:
			animation_state_machine.on_child_transition(current_state, "knockback")
