"""
Class for maintaining and handling all resources logic.
Includes:
-Storing amounts of each resources
-Handling player build requests and deletes
"""
extends Node2D

# Resource field
var resources = {
	"dirt": 20,
	"stone": 20,
	"leaves": 20,
	"wood": 20,
	"mobdrops": 20
}

var hud

var Placeable = preload("res://Scenes/Placeables/Placeable.gd")

func check_upgrade_cost(amount):
	if resources["mobdrops"] < amount:
		return false
	resources["mobdrops"] -= amount
	return true

func attempt_base_purchase():
	if resources["dirt"] < 10 || resources["stone"] < 6 || resources["leaves"] < 8:
		return false
	resources["dirt"] -= 10
	resources["stone"] -= 6
	resources["leaves"] -= 8
	return true


func resource_picked_up(type, amount):
	if resources[type] < 999:
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


# Calculates and returns the resources from the deletion of the building (placeable)
# instance passed in. Currently half the amount it costs to build for now (rounded down)
func return_resources_from_delete(build_instance):
	var build_cost  = Placeable.costs[build_instance.build_id]
	# print(build_cost)
	for resource in build_cost:
		#print("cost: " + str(build_cost[resource]))
		#print(int(ceil(build_cost[resource]/2.0)))
		resources[resource] += int(floor(build_cost[resource]/2.0))

