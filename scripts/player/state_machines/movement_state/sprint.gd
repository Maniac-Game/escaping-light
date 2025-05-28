extends State

@export var anim_sprite: AnimatedSprite2D
@export var character_body: Node2D
@export var player: CharacterBody2D
@export var sprint_speed: int
@export var flashlight: Node2D
#@export var dash_state: DashState

var stamina_depletion_rate := 20.0

func enter() -> void:
	anim_sprite.stop()
	player.is_sprinting = true

func exit() -> void:
	player.is_sprinting = false
	
func update(delta: float) -> void:
	if player.stamina <= 0:
		transitioned.emit(self, "walk")
		return
	
	var direction = PlayerUtils.get_movement_direction()
	if direction.x == 0 and direction.y == 0:
		transitioned.emit(self, "idle")
		return
	
	if Input.is_action_just_released("sprint"):
		transitioned.emit(self, "walk")
		return
	
	PlayerUtils.character_face_mouse(character_body, player, anim_sprite, "sprint")
	PlayerUtils.flash_face_mouse(flashlight, player)

func physics_update(delta: float) -> void:	
	var direction = PlayerUtils.get_movement_direction()
	var normalizer = 1/1.4 if direction.x and direction.y else 1
	player.velocity = direction * sprint_speed * normalizer
	
	player.stamina -= stamina_depletion_rate * delta
	player.stamina = clamp(player.stamina, 0, player.max_stamina)
