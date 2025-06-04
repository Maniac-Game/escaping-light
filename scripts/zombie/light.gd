extends Area2D
class_name Light

var on : bool
var battery: float = 100

func _ready() -> void:
	on = true
	_toggle_light()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("toggle") and battery > 0:
		_toggle_light()
	if on:
		battery -= 0.05
		if battery <= 0:
			_toggle_light()

func _toggle_light():
	on = !on
	self.visible = true if on else false
	$CollisionPolygon2D.set_deferred("disabled", false if on else true)
