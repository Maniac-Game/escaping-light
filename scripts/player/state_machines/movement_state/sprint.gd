extends State

@export var anim_sprite: AnimatedSprite2D
@export var character_body: Node2D
@export var player: CharacterBody2D
@export var sprint_speed: int
#@export var dash_state: DashState

func enter() -> void:
	anim_sprite.play("sprint")

func exit() -> void:
	pass
	
func update(delta: float) -> void:
	var direction = get_direction()
	if !direction.x and !direction.y:
		transitioned.emit(self, "idle")
		return
	
	if Input.is_action_just_released("sprint"):
		transitioned.emit(self, "walk")
		return
	
	var face_direction = player.get_global_mouse_position() - player.position
	if face_direction.x < 0:
		character_body.scale.x = -1
	elif face_direction.x > 0:
		character_body.scale.x = 1

func physics_update(delta: float) -> void:
	var direction = get_direction()
	var normalizer = 1/1.4 if direction.x and direction.y else 1
	player.velocity = direction * sprint_speed * normalizer
	
func get_direction() -> Vector2:
	var horizontal_movement = Input.get_axis("ui_left","ui_right")
	var vertical_movement = Input.get_axis("ui_up","ui_down")
	return Vector2(horizontal_movement, vertical_movement)
