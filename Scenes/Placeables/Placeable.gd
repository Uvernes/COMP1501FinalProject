extends Node2D

signal removed(build)  # Emitted when a placeable is deleted by the player or broken / used up

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
	placeables.WEB: preload("res://Scenes/Placeables/Web.tscn"),
	placeables.MINE: preload("res://Scenes/Placeables/Mine.tscn"),
	placeables.TOWER: preload("res://Scenes/Placeables/Tower.tscn"),
}

# All resource costs defined here. Done here so we don't need to load 
# all other scenes beforehand.
const costs: Dictionary = {
		placeables.TORCH: {
		"dirt": 0,
		"stone": 0,
		"leaves": 2,
		"wood": 1
		},
	placeables.PLAYER_WALL: {
		"dirt": 1,
		"stone": 0,
		"leaves": 0,
		"wood": 0
		},
	placeables.WEB: {
		"dirt": 1,
		"stone": 0,
		"leaves": 3,
		"wood": 0
		},
	placeables.MINE: {
		"dirt": 0,
		"stone": 1,
		"leaves": 0,
		"wood": 3
		},
	placeables.TOWER: {
		"dirt": 4,
		"stone": 4,
		"leaves": 0,
		"wood": 0
		},
}

# Fields
# If false, the player and other objects cannot move through the object
@export var can_traverse = false 
var build_id  # Each build specifies its build id in the placeables enum


# Call with super() in all sublcasses so all of them have the base init ran
func _ready():
	add_to_group("Placeable")
	
	
func remove():
	removed.emit(self)
	queue_free()

