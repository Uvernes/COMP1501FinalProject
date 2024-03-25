extends "res://Scenes/Placeables/Placeable.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# Define resources cost
static func get_cost() -> Dictionary:
	return {
		"dirt": 0,
		"stone": 0,
		"leaves": 5,
		"wood": 5
	}

