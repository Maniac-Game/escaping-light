extends CharacterBody2D

enum State {IDLE, CHASE, ATTACK}

@onready var animated_sprite = $AnimatedSprite2D
@onready var hurtbox = $Hurtbox
@onready var hitbox = $Hitbox
@onready var player_character = get_node("/root/Level/Player")

@export var speed = 150.0
@export var detection_range = 200
@export var attack_range = 50.0

var current_state = State.IDLE
var player_pos
var direction

func _ready():
	animated_sprite.play("idle")

func _physics_process(delta):
	player_pos = player_character.global_position
	direction = (player_pos - global_position).normalized()
	if current_state != State.IDLE:
		if direction.x < 0:
			animated_sprite.flip_h = false
		else:
			animated_sprite.flip_h = true
	match current_state:
		State.IDLE:
			handle_idle()
		State.CHASE:
			handle_chase(delta)
		State.ATTACK:
			handle_attack()

func handle_idle():
	animated_sprite.play("idle")
	
	if player_character and global_position.distance_to(player_pos) < detection_range:
		current_state = State.CHASE

func handle_chase(_delta):
	if not player_character:
		current_state = State.IDLE
		return

	animated_sprite.play("fly")
	position = position.move_toward(player_character.global_position, speed * _delta)
	if global_position.distance_to(player_character.global_position) <= attack_range:
		current_state = State.ATTACK

func handle_attack():
	animated_sprite.play("attack")
	
		
func attack_finished():
	if not player_character or global_position.distance_to(player_character.global_position) > attack_range:
		current_state = State.CHASE
		return
