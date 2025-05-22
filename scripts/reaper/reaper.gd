extends Enemy

@export var speed: float = 80
@export var petrification_damage_per_second: float = 5
@export var attack_radius: float = 100
@export var attack_damage: int = 20
@export var deceleration_rate: float = 2
@export var max_health: int = 100

@onready var animated_sprite = $AnimatedSprite
@onready var hitbox = $HitBox
@onready var petrification_timer = $PetrifiedTimer

var target: CharacterBody2D
var is_attacking: bool = false
var is_petrified: bool = false
var petrification_start_time: float = 0
var current_health: int = max_health
var is_facing_left: bool = true
var dead: bool = false
var flipped:bool = false

func _ready() -> void:
	animated_sprite.play("idleLeft")

func enter_petrification():
	is_petrified = true
	velocity = Vector2.ZERO
	petrification_timer.start()
	animated_sprite.play("idleLeft" if is_facing_left else "idleRight")

func exit_petrification():
	is_petrified = false
	petrification_timer.stop()

func attack_target(delta):
	if target != null:
		var distance_to_player = (target.global_position - global_position).length()
		if distance_to_player <= attack_radius:
			is_attacking = true
			if (target.global_position - global_position).x < 0:
				animated_sprite.flip_h = true
				flipped = true
				$AttackArea.scale.x = -1
			animated_sprite.play("kill")
			$AttackArea/CollisionShape2D.disabled = false
			# Deal damage to the player
			if target.has_method("take_damage"):
				target.take_damage(attack_damage)
		else:
			$AttackArea/CollisionShape2D.disabled = true
			if flipped:
				animated_sprite.flip_h = false
				flipped = false
				$AttackArea.scale.x = 1
			is_attacking = false
			play_idle_animation()
	else:
		$AttackArea/CollisionShape2D.disabled = true
		is_attacking = false
		if flipped:
			animated_sprite.flip_h = false
			flipped = false
			$AttackArea.scale.x = 1

func update_facing_direction(direction: Vector2):
	if direction.x < 0:
		animated_sprite.play("hostileLeft")
		is_facing_left = true
	else:
		animated_sprite.play("hostileRight")
		is_facing_left = false

func play_idle_animation():
	if is_facing_left:
		animated_sprite.play("idleLeft")
	else:
		animated_sprite.play("idleRight")

func _physics_process(delta: float) -> void:
	if !dead:
		if is_petrified:
			var elapsed_time = Time.get_ticks_msec() / 1000.0 - petrification_start_time
			if elapsed_time > 0:
				current_health -= petrification_damage_per_second * delta
				if current_health <= 0 && !dead:
					dead = true
					die()
				# Optional debug
				print_debug("Health: ", current_health)
		else:
			if target != null:
				attack_target(delta)

				if !is_attacking:
					chase_target(delta)
			else:
				chase_target(delta)

		move_and_slide()

func chase_target(delta: float):
	$AttackArea/CollisionShape2D.disabled = true
	if target != null:
		var direction = (target.global_position - global_position).normalized()
		velocity = direction * speed
		update_facing_direction(direction)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed * deceleration_rate * delta)
		play_idle_animation()

func die():
	print_debug("Reaper is dying...")
	$HitBox/CollisionShape2D.disabled = true
	animated_sprite.animation_finished.connect(queue_free)
	animated_sprite.play("dead")

func _on_sight_range_body_entered(body: Node2D) -> void:
	if body is Player:
		target = body

func _on_chase_range_body_exited(body: Node2D) -> void:
	if body is Player:
		target = null

func _on_hit_box_area_entered(area: Area2D) -> void:
	if area is Light and !is_petrified:
		enter_petrification()
		petrification_start_time = Time.get_ticks_msec() / 1000.0

func _on_hit_box_area_exited(area: Area2D) -> void:
	if area is Light and is_petrified:
		exit_petrification()
