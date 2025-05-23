extends CharacterBody2D

enum State {IDLE, ATTACK, CHASE, HIT, DEAD}

@export var level = "Level"
@export var speed = 150.0
@export var detection_range = 700
@export var health = 100

@onready var animated_sprite = $AnimatedSprite2D
@onready var hurtbox = $Hurtbox
@onready var hitbox_left = $HitboxLeft
@onready var hitbox_right = $HitboxRight
@onready var active_hitbox = hitbox_left
@onready var invincibility_window = $InvincibilityWindow
@onready var bite_sound = $BiteSound
@onready var hurt_sound = $HurtSound
@onready var death_sound = $DeathSound
@onready var player_character = get_node("/root/" + level + "/y-sort/Player")
@onready var player_hurtbox = get_node("/root/" + level + "/y-sort/Player/Hitbox")
@onready var light = get_node("/root/" + level + "/y-sort/Player/Body/Flashlight/Light")

var current_state = State.IDLE
var player_pos
var direction
var has_damaged_player = false
var invincible = false

func _ready():
	animated_sprite.play("idle")

func _physics_process(delta):
	check_status()
	update_position()
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

func update_position():
	player_pos = player_character.global_position
	direction = (player_pos - global_position).normalized()

func check_status():
	if health <= 0:
		current_state = State.DEAD
	elif light in hurtbox.get_overlapping_areas() and not invincible:
		current_state = State.HIT

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
		dest.x += 10
	else:
		dest.x -= 10
		animated_sprite.flip_h = true
	position = position.move_toward(dest, speed * _delta)
	
	if is_in_attack_range():
		current_state = State.ATTACK

func confirm_chase():
	if not player_character or player_hurtbox not in active_hitbox.get_overlapping_areas():
			current_state = State.CHASE
			return

func handle_attack():
	animated_sprite.play("attack")
	if not bite_sound.playing:
		bite_sound.play()
		
	if animated_sprite.flip_h == false:
		active_hitbox = hitbox_left
	else:
		active_hitbox = hitbox_right
	if is_attack_window() and has_damaged_player == false:
		if player_hurtbox in active_hitbox.get_overlapping_areas():
			player_character.get_hit()
			has_damaged_player = true
	
func handle_hit():
	animated_sprite.play("hit")
	if not hurt_sound.playing:
		hurt_sound.play()
	invincible = true
	health -= 1

func invincible_over() -> void:
	invincible = false

func handle_dead():
	animated_sprite.play("death")
	if not death_sound.playing:
		death_sound.play()

func animation_finished():
	if current_state == State.ATTACK:
		has_damaged_player = false
		confirm_chase()
	elif current_state == State.HIT:
		invincibility_window.start()
		confirm_chase()
	elif current_state == State.DEAD:
		queue_free()

func is_in_attack_range():
	var in_attack_range_left:bool = player_hurtbox in hitbox_left.get_overlapping_areas()
	var in_attack_range_right:bool = player_hurtbox in hitbox_right.get_overlapping_areas()
	return player_hurtbox and (in_attack_range_left or in_attack_range_right)

func is_attack_window():
	var is_attack_animation = animated_sprite.animation == "attack"
	var frame = animated_sprite.frame
	return is_attack_animation and frame >= 4 and frame <= 6
