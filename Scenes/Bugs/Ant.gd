extends Node2D

var direction = 0 #the direction player is moving
var radius = 1 #the direction player is 
var change = 0.5

var anthead: Texture
var antabdomen: Texture
var antthorax: Texture

func _ready():
	anthead = load("res://Assets/Bugs/Ants/anthead-brown.png")
	antabdomen = load("res://Assets/Bugs/Ants/antabdomen.png")
	antthorax = load("res://PrototypeAssets/ants/antthoraxlargetest.png")

func _process(_delta):
	$".".rotation = -global_position.angle_to_point(get_global_mouse_position())
	queue_redraw()

#func _draw():
	#draw_line(Vector2.ZERO, direction, Color.WHITE, 5)

func _on_player_direction_changed(new_direction):
	direction = new_direction
	print(direction)
