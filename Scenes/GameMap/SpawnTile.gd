

extends Area2D

var objects_in_area = []  # Objects currently in spawn tile area


func _ready():
	position = Vector2.ZERO

func _on_area_entered(area):
	objects_in_area.append(area)


func _on_body_entered(body):
	objects_in_area.append(body)


func _on_area_exited(area):
	objects_in_area.erase(area)


func _on_body_exited(body):
	objects_in_area.erase(body)
