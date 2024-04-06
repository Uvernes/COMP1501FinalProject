extends "res://Scenes/Placeables/Placeable.gd"

@onready var _animated_sprite = $AnimatedSprite2D

func _ready():
	super()
	build_id = placeables.TORCH
	_animated_sprite.play()
