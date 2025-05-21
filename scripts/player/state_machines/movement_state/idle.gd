extends State

@export var anim_sprite: AnimatedSprite2D
@export var character_body: Node2D
@export var player: CharacterBody2D
@export var flashlight: Node2D
#@export var dash_state: DashState

func enter() -> void:
	anim_sprite.stop()
	
func exit() -> void:
	pass

	
func update(delta: float) -> void:
	if Input.is_action_pressed("sprint") and PlayerUtils.get_movement_direction() != Vector2(0,0):
		transitioned.emit(self, "sprint")
		return
	
	if Input.get_axis("move_left", "move_right") or Input.get_axis("move_down", "move_up"):
		transitioned.emit(self, "walk")
		return
	
	PlayerUtils.character_face_mouse(character_body, player, anim_sprite, "idle")
	PlayerUtils.flash_face_mouse(flashlight, player)

func physics_update(delta: float) -> void:
	player.velocity = Vector2.ZERO
