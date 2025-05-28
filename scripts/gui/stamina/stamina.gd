extends Node2D

@onready var staminabar = $StaminaBar

func set_stamina(value):
	staminabar.value = value
