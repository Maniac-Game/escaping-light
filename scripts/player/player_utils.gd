class_name PlayerUtils
extends Node

static func get_face_direction(player: CharacterBody2D):
	return player.get_global_mouse_position() - player.position

static func character_face_mouse(character_body: Node2D, player: CharacterBody2D, anim_sprite: AnimatedSprite2D, state: String):
	var face_direction = get_face_direction(player)
	var face_angle = rad_to_deg(face_direction.angle())
	if face_direction.x < 0:
		character_body.scale.x = -1
	elif face_direction.x > 0:
		character_body.scale.x = 1
	if abs(face_angle) < 45 or abs(face_angle) > 135:
		anim_sprite.play(state + "1")
	elif face_angle >= 45 and face_angle <= 135:
		anim_sprite.play(state + "0")
	else:
		anim_sprite.play(state + "2")

static func flash_face_mouse(object: Node2D, player: CharacterBody2D):
	var face_direction = get_face_direction(player)
	var flash_angle = rad_to_deg(face_direction.angle())
	if flash_angle < -90:
		flash_angle = -180 - flash_angle
	elif flash_angle > 90:
		flash_angle = 180 - flash_angle
	object.rotation_degrees = flash_angle
	
static func get_movement_direction() -> Vector2:
	var horizontal_movement = Input.get_axis("move_left","move_right")
	var vertical_movement = Input.get_axis("move_up","move_down")
	return Vector2(horizontal_movement, vertical_movement)
