extends CharacterBody2D

enum State {
	IDLE,
	CHASE,
	ATTACK,
	PETRIFIED,
	DEAD
}

@export var speed: float = 150.0
@export var attack_damage: float = 10.0
@export var attack_cooldown: float = 1.0
@export var light_damage_per_second: float = 15.0
@export var detection_range: float = 300.0
@export var attack_range: float = 50.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var area_2d: Area2D = $Area2D
@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D

var current_state = State.IDLE
var player_ref: Node2D = null
var health: float = 100.0
var time_in_light: float = 0.0
var can_attack: bool = true
var is_facing_left: bool = true

func _ready():
	animated_sprite.play("idleLeft")

func _physics_process(delta):
	match current_state:
		State.IDLE:
			handle_idle()
		State.CHASE:
			handle_chase(delta)
		State.ATTACK:
			handle_attack()
		State.PETRIFIED:
			handle_petrified(delta)
		State.DEAD:
			handle_dead()
	
	move_and_slide()

func handle_idle():
	if is_facing_left:
		animated_sprite.play("idleLeft")
	else:
		animated_sprite.play("idleRight")
	
	if player_ref and global_position.distance_to(player_ref.global_position) < detection_range:
		current_state = State.CHASE

func handle_chase(_delta):
	if not player_ref:
		current_state = State.IDLE
		return
	
	var direction = (player_ref.global_position - global_position).normalized()
	
	if direction.x < 0:
		animated_sprite.play("walkLeft")
		is_facing_left = true
	else:
		animated_sprite.play("walkRight")
		is_facing_left = false
	
	velocity = direction * speed
	
	if global_position.distance_to(player_ref.global_position) <= attack_range:
		current_state = State.ATTACK

func handle_attack():
	if not player_ref or global_position.distance_to(player_ref.global_position) > attack_range:
		current_state = State.CHASE
		return
	
	if is_facing_left:
		animated_sprite.play("kill")
	else:
		animated_sprite.play("hostileRight")

	if can_attack:
		attack_player()

func attack_player():
	if player_ref and player_ref.has_method("take_damage"):
		player_ref.take_damage(attack_damage)
		can_attack = false
		$AttackCooldown.start(attack_cooldown)
		audio_player.play()

func handle_petrified(delta):
	velocity = Vector2.ZERO
	
	if is_facing_left:
		animated_sprite.play("idleLeft")
	else:
		animated_sprite.play("idleRight")
	
	time_in_light += delta
	if time_in_light >= 1.0:
		take_damage(light_damage_per_second)
		time_in_light = 0.0
	
	if not is_in_light():
		current_state = State.CHASE
		time_in_light = 0.0

func handle_dead():
	animated_sprite.play("dead")
	set_physics_process(false)
	collision_shape.disabled = true

func take_damage(amount: float):
	health -= amount
	if health <= 0:
		die()

func die():
	current_state = State.DEAD
	# Additional death handling (particles, sound, etc.)

func is_in_light() -> bool:
	return false

func _on_Area2D_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_ref = body
		if current_state == State.IDLE:
			current_state = State.CHASE

func _on_Area2D_body_exited(body: Node2D) -> void:
	if body == player_ref:
		player_ref = null
		current_state = State.IDLE

func _on_attack_cooldown_timeout():
	can_attack = true

func _on_light_detected(_light_source):
	if current_state != State.DEAD:
		current_state = State.PETRIFIED
		time_in_light = 0.0
