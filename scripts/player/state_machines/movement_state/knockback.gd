extends State

@export var anim_sprite: AnimatedSprite2D
@export var player: CharacterBody2D

func enter() -> void:
	get_tree().create_timer(0.3).timeout.connect(on_timer_timeout)
	if player.enemy != null:
		var knockback_direction = player.global_position - player.enemy.global_position
		player.velocity = knockback_direction.normalized() * 300
	
func exit() -> void:
	player.enemy = null
	
func update(delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	pass
	
func on_timer_timeout():
	transitioned.emit(self,"idle")
