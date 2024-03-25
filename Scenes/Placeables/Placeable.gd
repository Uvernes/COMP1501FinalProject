extends Node2D

# Enum for all buildings
enum placeables {
	PLAYER_WALL,
	ROAD,
	TORCH
}

# Scene paths
var scene_paths: Dictionary = {
	placeables.PLAYER_WALL: "res://Scenes/Placeable/PlayerWall.tscn",
	placeables.TORCH: "res://Scenes/Placeable/Torch.tscn",
	placeables.ROAD: "res://Scenes/Placeable/Road.tscn",
}

# Fields
@export var can_traverse = false   # If false, the player and other objects cannot move through the object

# Resources cost <-- Redefine in child classes
static func get_cost()-> Dictionary:
	return {
		"dirt": 0,
		"stone": 0,
		"leaves": 0,
		"wood": 0
	}
