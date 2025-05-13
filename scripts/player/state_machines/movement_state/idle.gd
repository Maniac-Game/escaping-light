extends State

@export var anim_sprite: AnimatedSprite2D
@export var character_body: Node2D
@export var player: CharacterBody2D
#@export var dash_state: DashState

func enter() -> void:
	anim_sprite.play("idle")
	
func exit() -> void:
	pass

	
func update(delta: float) -> void:
	if Input.is_action_pressed("sprint"):
		transitioned.emit(self, "sprint")
		return
	
	if Input.get_axis("ui_left", "ui_right") or Input.get_axis("ui_down", "ui_up"):
		transitioned.emit(self, "walk")
		return
	
	var face_direction = player.get_global_mouse_position() - player.position
	if face_direction.x < 0:
		character_body.scale.x = -1
	elif face_direction.x > 0:
		character_body.scale.x = 1

func physics_update(delta: float) -> void:
	player.velocity = Vector2.ZERO
