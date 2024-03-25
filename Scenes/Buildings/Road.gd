extends "res://Scenes/Buildings/Placeable.gd"


# Define resources cost
static func get_cost() -> Dictionary:
	return {
		"dirt": 5,
		"stone": 0,
		"leaves": 0,
		"wood": 0
	}

