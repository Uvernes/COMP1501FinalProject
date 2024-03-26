"""
Class for maintaining and handling all resources logic.
Includes:
-Storing amounts of each resources
-Handling player build requests and deletes
"""
extends Node2D

# Resource field
var resources = {
	"dirt": 0,
	"stone": 0,
	"leaves": 0,
	"wood": 0,
	"mobdrops": 0
}

var Placeable = preload("res://Scenes/Placeables/Placeable.gd")


func resource_picked_up(type, amount):
	resources[type] += amount
	get_parent().get_node("HUD").update_resource(type, resources[type])


# Attempts to purchase a building. If enough resource, returns an instance of 
# the building. Otherwise returns null
func attempt_build_purchase(build_id):
	# Check if enough resources to build
	var build_cost = Placeable.costs[build_id]
	var can_build = true
	for resource in build_cost:
		if resources[resource] < build_cost[resource]:
			can_build = false
			return null
	# If enough, spend resources, and create and return build instance
	for resource in build_cost:
		resources[resource] -= build_cost[resource]
	var build_scene = Placeable.packed_scenes[build_id]
	var build_instance = build_scene.instantiate()
	return build_instance
