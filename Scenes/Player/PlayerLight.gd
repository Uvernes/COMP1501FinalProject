extends PointLight2D

func _process(delta):
	$".".rotation = -global_position.angle_to_point(get_global_mouse_position())