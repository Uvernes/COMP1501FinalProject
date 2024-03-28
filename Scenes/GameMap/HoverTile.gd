"""
Hover tile scene. Controlled by the gameMap scene and moves around with the player
mouse when in build mode. Contains a list that maintains any areas or bodies currently
within the hover tile area.
"""
extends Area2D

var objects_in_area = []  # Objects currently in hover tile area


func _on_area_entered(area):
	objects_in_area.append(area)
	print(objects_in_area)
	pass # Replace with function body.


func _on_body_entered(body):
	objects_in_area.append(body)
	print(objects_in_area)
	pass # Replace with function body.


func _on_area_exited(area):
	objects_in_area.erase(area)
	pass # Replace with function body.


func _on_body_exited(body):
	objects_in_area.erase(body)

