extends Area2D
class_name Light

var on : bool

func _ready() -> void:
	on = false
	_toggle_light()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("toggle"):
		on = !on
		_toggle_light()

func _toggle_light():
	self.visible = true if on else false
	$CollisionPolygon2D.set_deferred("disabled", false if on else true)
