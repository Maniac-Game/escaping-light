class_name StateMachine
extends Node

@export var initial_state: State

var states_map: Dictionary = {}
var current_state: State

func _ready():
	for child in get_children():
		if child is State:
			states_map[child.name.to_camel_case()] = child
			child.transitioned.connect(on_child_transition)

	if initial_state:
		current_state = initial_state
		current_state.enter()
		
func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func on_child_transition(state: State, new_state_name: String):
	if state != current_state:
		return
	
	var new_state: State = states_map.get(new_state_name)
	if !new_state:
		return
	
	if current_state:
		current_state.exit()
	
	new_state.enter()
	current_state = new_state
	
	
