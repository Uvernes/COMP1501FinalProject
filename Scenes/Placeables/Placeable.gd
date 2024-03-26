extends Node2D

# Enum for all buildings
enum placeables {
	TORCH,
	PLAYER_WALL,
	WEB,
	MINE,
	TOWER
}

# Preloaded packed scenes for all builds
const packed_scenes: Dictionary = {
	placeables.TORCH: preload("res://Scenes/Placeables/Torch.tscn"),
	placeables.PLAYER_WALL: preload("res://Scenes/Placeables/PlayerWall.tscn"),
	# TODO - create actual scenes + update paths
	placeables.WEB: preload("res://Scenes/Placeables/Road.tscn"),
	placeables.MINE: preload("res://Scenes/Placeables/Road.tscn"),
	placeables.TOWER: preload("res://Scenes/Placeables/Road.tscn"),
}

# All resource costs defined here. Done here so we don't need to load 
# all other scenes beforehand.
const costs: Dictionary = {
		placeables.TORCH: {
		"dirt": 0,
		"stone": 0,
		"leaves": 2,
		"wood": 2
		},
	placeables.PLAYER_WALL: {
		"dirt": 1,
		"stone": 0,
		"leaves": 0,
		"wood": 0
		},
	placeables.WEB: {
		"dirt": 2,
		"stone": 0,
		"leaves": 0,
		"wood": 0
		},
	placeables.MINE: {
		"dirt": 2,
		"stone": 0,
		"leaves": 0,
		"wood": 0
		},
	placeables.TOWER: {
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
