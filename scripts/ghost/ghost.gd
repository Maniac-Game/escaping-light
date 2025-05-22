extends CharacterBody2D

enum State {IDLE, CHASE, ATTACK, HIT, DEAD}

@onready var animated_sprite = $AnimatedSprite2D
@onready var hurtbox = $Hurtbox
@onready var hitbox = $Hitbox
@onready var invincibility_window = $InvincibilityWindow
@onready var player_character: CharacterBody2D = get_node("/root/Level/Player")

@export var speed = 150.0
@export var detection_range = 200
@export var health = 200

var invincible = false
var current_state = State.IDLE
var player_pos
var direction

func _ready():
	animated_sprite.play("idle")

func _physics_process(delta):
	if health <= 0:
		current_state = State.DEAD
	player_pos = player_character.global_position
	direction = (player_pos - global_position).normalized()
	if Input.is_action_pressed("ui_accept"):
		current_state = State.DEAD
	elif Input.is_action_pressed("ui_focus_next"):
		current_state = State.HIT
	match current_state:
		State.IDLE:
			handle_idle()
		State.CHASE:
			handle_chase(delta)
		State.ATTACK:
			handle_attack()
		State.HIT:
			handle_hit()
		State.DEAD:
			handle_dead()

func handle_idle():
	animated_sprite.play("idle")
	
	if player_character and global_position.distance_to(player_pos) < detection_range:
		current_state = State.CHASE

func handle_chase(_delta):
	if not player_character:
		current_state = State.IDLE
		return
	if direction.x < 0:
		animated_sprite.flip_h = false
	else:
		animated_sprite.flip_h = true
	animated_sprite.play("fly")
	var dest = player_pos
	if direction.x < 0:
		dest.x += 20
	else:
		dest.x -= 20
		animated_sprite.flip_h = true
	position = position.move_toward(dest, speed * _delta)
	if player_character in hitbox.get_overlapping_bodies():
		current_state = State.ATTACK

func on_attack_range(body: Node2D) -> void:
	current_state = State.ATTACK

func handle_attack():
	animated_sprite.play("attack")
	
func handle_hit():
	if not invincible:
		animated_sprite.play("hit")

func handle_dead():
	animated_sprite.play("death")

func animation_finished():
	if current_state == State.ATTACK:
		confirm_chase()
	elif current_state == State.HIT:
		health -= 10
		invincible = true
		invincibility_window.start()
		confirm_chase()
	elif current_state == State.DEAD:
		queue_free()

func confirm_chase():
	if not player_character or player_character not in hitbox.get_overlapping_bodies():
			current_state = State.CHASE
			return
