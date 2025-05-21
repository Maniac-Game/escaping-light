extends CharacterBody2D
class_name Player

@export var speed = 200
@export var run_multiplier = 1.5

func get_input():
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = input_direction * speed * (run_multiplier if Input.is_action_pressed("sprint") else 1)

func _physics_process(_delta):
	get_input()
	move_and_slide()
