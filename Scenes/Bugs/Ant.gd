extends Node2D

func _process(_delta):
	$".".rotation = -global_position.angle_to_point(get_global_mouse_position())

func _draw():
