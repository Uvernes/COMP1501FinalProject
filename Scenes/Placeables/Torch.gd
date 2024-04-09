extends "res://Scenes/Placeables/Placeable.gd"

@onready var _animated_sprite = $AnimatedSprite2D

func _ready():
	super()
	build_id = placeables.TORCH
	_animated_sprite.play()
	$PointLight2D.enabled = false  # Disabled until player within torch emission zone


# Activate torch once player within torch emmision range
func _on_torch_emission_zone_body_entered(body):
	#print("Body entered.")
	#print(body.get_groups())
	#print(body)
	if body.is_in_group("Player"):
		$PointLight2D.enabled = true


# Deactivate torch once player outside torch emmision range
func _on_torch_emission_zone_body_exited(body):
	if body.is_in_group("Player"):
		$PointLight2D.enabled = false
