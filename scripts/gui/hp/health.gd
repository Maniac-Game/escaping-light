extends Node2D

@onready var hpbar = $HealthBar

func set_health(value):
	hpbar.value = value
