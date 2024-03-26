extends Node2D

# Enum for all buildings
enum placeables {
	PLAYER_WALL,
	ROAD,
	TORCH
}


# Preloaded packed scenes for all builds
const packed_scenes: Dictionary = {
	placeables.PLAYER_WALL: preload("res://Scenes/Placeables/PlayerWall.tscn"),
	placeables.TORCH: preload("res://Scenes/Placeables/Torch.tscn"),
	placeables.ROAD: preload("res://Scenes/Placeables/Road.tscn"),
}

# All resource costs defined here. Done here so we don't need to load 
# all other scenes beforehand.
const costs: Dictionary = {
	placeables.PLAYER_WALL: {
		"dirt": 1,
		"stone": 0,
		"leaves": 0,
		"wood": 0
		},
	placeables.TORCH: {
		"dirt": 0,
		"stone": 0,
		"leaves": 2,
		"wood": 2
		},
	placeables.ROAD: {
		"dirt": 2,
		"stone": 0,
		"leaves": 0,
		"wood": 0
		},
}

# Fields
@export var can_traverse = false   # If false, the player and other objects cannot move through the object

## Resources cost <-- Redefine in child classes
#static func get_cost()-> Dictionary:
	#return {
		#"dirt": 0,
		#"stone": 0,
		#"leaves": 0,
		#"wood": 0
	#}
