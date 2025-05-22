extends State

@export var anim_sprite: AnimatedSprite2D
@export var player: CharacterBody2D

@export var walk_speed: int

var last_animation
func enter():
	anim_sprite.play("idle")

func exit():
	pass

func physics_update(delta):
	player.velocity = Vector2(1,0) * walk_speed
	
