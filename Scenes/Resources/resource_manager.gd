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


func resource_picked_up(type, amount):
	resources[type] += amount
	get_parent().get_node("HUD").update_resource(type, resources[type])


#TODO - implement
func handle_build_request(build_id):
	pass
