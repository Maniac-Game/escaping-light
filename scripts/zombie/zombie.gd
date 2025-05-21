extends Enemy

enum State {
	IDLE,
	CHASE,
	ATTACK,
	FLEE,
	DEAD
}

enum AttackPhase {
	CHARGE,
	DASH,
	END
}

@export var speed: float = 80
@export var dash_multiplier = 3.0
@export var flee_multiplier = 2.0
@export var light_damage: float = 20.0

@onready var sprite = $AnimatedSprite2D

var current_state = State.IDLE
var current_attack_phase = AttackPhase.CHARGE
var target: Node2D = null
var health: float = 100.0
var dash_direction: Vector2 = Vector2.ZERO
var hit_direction: Vector2 = Vector2.ZERO

func _physics_process(delta):
	match current_state:
		State.IDLE:
			handle_idle(delta)
		State.CHASE:
			handle_chase(delta)
		State.ATTACK:
			handle_attack(delta)
		State.FLEE:
			handle_flee(delta)
		State.DEAD:
			handle_dead()
	move_and_slide()


func handle_idle(_delta):
	if target:
		$TimeUntilDash.start(randf_range(3.0, 5.0))
		current_state = State.CHASE
		return
	
	velocity = Vector2.ZERO
	sprite.play("idle")


func handle_chase(_delta):
	if not target:
		current_state = State.IDLE
		return
	var direction = (target.global_position - global_position).normalized()
	
	if direction.x < 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	
	sprite.play("chase")
	
	velocity = direction * speed


func handle_attack(_delta):
	match current_attack_phase:
		AttackPhase.CHARGE:
			velocity = Vector2.ZERO
			
			if target:
				dash_direction = (target.global_position - global_position).normalized()
			
			velocity = Vector2.ZERO
			sprite.play("charge")
			await sprite.animation_finished
			
			$DashLength.start()
			current_attack_phase = AttackPhase.DASH
		AttackPhase.DASH:
			if dash_direction.x < 0:
				sprite.flip_h = true
			else:
				sprite.flip_h = false
				
			velocity = dash_direction * speed * dash_multiplier
			sprite.play("dash")
		AttackPhase.END:
			velocity = Vector2.ZERO
			dash_direction = Vector2.ZERO
			sprite.play("rest")
			await sprite.animation_finished
			
			current_attack_phase = AttackPhase.CHARGE
			current_state = State.IDLE


func handle_flee(_delta):
	if hit_direction.x > 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	
	sprite.play("flee")
	
	velocity = -hit_direction.normalized() * speed * flee_multiplier


func handle_dead():
	set_physics_process(false)
	sprite.play("dead")
	await sprite.animation_finished
	self.call_deferred('queue_free')


func take_damage(amount: float):
	health -= amount
	print(health)
	if health <= 0:
		die()


func die():
	current_state = State.DEAD


func _on_sight_range_body_entered(body: Node2D) -> void:
	if body is Player:
		target = body


func _on_chase_range_body_exited(body: Node2D) -> void:
	if body is Player:
		$TimeUntilDash.stop()
		target = null


func _on_hit_box_area_entered(area: Area2D) -> void:
	if area is Light and (current_state != State.FLEE and current_state != State.ATTACK):
		$TimeUntilDash.stop()
		take_damage(light_damage)
		
		if current_state != State.DEAD:
			hit_direction = Vector2.RIGHT.rotated(get_angle_to(area.global_position))
			target = null
			current_state = State.FLEE
			$FleeTimer.start()


func _on_flee_timer_timeout() -> void:
	current_state = State.IDLE


func _on_dash_length_timeout() -> void:
	current_attack_phase = AttackPhase.END


func _on_time_until_dash_timeout() -> void:
	dash_direction = (target.global_position - global_position).normalized()
	current_attack_phase = AttackPhase.CHARGE
	current_state = State.ATTACK
