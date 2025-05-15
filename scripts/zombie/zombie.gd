extends Enemy

@export var speed = 80
@export var flee_multiplier = 1.8
@export var deceleration_rate = 2

@onready var flee_timer = $FleeTimer
@onready var sprite = $Sprite

var target: CharacterBody2D
var fleeing: bool = false
var last_light: Vector2

# Flee from Player's flashlight, opposite to angle of light
func flee_from_light(delta):
	velocity = -last_light.normalized() * speed * flee_multiplier

# Chase identified target
func chase_target(delta):
	if target != null:
		var direction = target.position - position
		velocity = direction.normalized() * speed
	else:
		# Stop if target is lost
		velocity = velocity.move_toward(Vector2.ZERO, speed * deceleration_rate * delta)


func _physics_process(delta):
	if fleeing:
		flee_from_light(delta)
	else:
		chase_target(delta)

	move_and_slide()

# Set target when entering line of sight
func _on_sight_range_body_entered(body: Node2D) -> void:
	if body is Player:
		target = body

# Lose target when leaving chase range
func _on_chase_range_body_exited(body: Node2D) -> void:
	if body is Player:
		target = null

# Process contact with light
func _on_hit_box_area_entered(area: Area2D) -> void:
	if area is Light and !fleeing:
		# Get angle of light
		last_light = Vector2.RIGHT.rotated(get_angle_to(area.global_position))
		
		# Start fleeing
		fleeing = true
		flee_timer.start()
		sprite.set_modulate(Color.hex(0xb84025ff))


func _on_flee_timer_timeout() -> void:
	# End fleeing
	fleeing = false
	sprite.set_modulate(Color.hex(0x6ed04bff))
