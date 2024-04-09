extends "res://Scenes/Placeables/Placeable.gd"

var health = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	build_id = placeables.PLAYER_WALL

