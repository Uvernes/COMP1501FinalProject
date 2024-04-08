extends Area2D


var collisionList = []

func _ready():
	position = Vector2(-100000, -100000)

func _on_body_entered(body):
	collisionList.append(body)

func _on_area_entered(area):
	collisionList.append(area)

func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	collisionList.append(body)

func _on_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	collisionList.append(area)
