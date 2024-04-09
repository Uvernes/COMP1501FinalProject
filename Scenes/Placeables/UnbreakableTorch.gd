extends Area2D

@onready var _animated_sprite = $AnimatedSprite2D

func _ready():
	_animated_sprite.play()


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
