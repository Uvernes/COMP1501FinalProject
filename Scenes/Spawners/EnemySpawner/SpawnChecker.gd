extends Area2D


var usage_allowed: bool = false
var collisionList = []

func _ready():
	position = Vector2(-100000, -100000)

func _on_body_entered(body):
	if usage_allowed:
		collisionList.add(body)
