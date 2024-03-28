extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if position.x == 0:
		position.x = 200
	else:
		position.x = 0

func _on_area_2d_body_entered(body):
	print("Body entered.")
