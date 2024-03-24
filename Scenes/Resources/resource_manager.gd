extends Node2D

var dirt_amount = 0
var stone_amount = 0
var leaves_amount = 0
var wood_amount = 0

var mobdrops_amount = 0

func resource_picked_up(type, amount):
	if type == "dirt":
		dirt_amount += 1
		get_node("/root").get_child(1).get_node("HUD").update_resource(type, dirt_amount)
	elif type == "stone":
		stone_amount += 1
		get_node("/root").get_child(1).get_node("HUD").update_resource(type, stone_amount)
	elif type == "leaves":
		leaves_amount += 1
		get_node("/root").get_child(1).get_node("HUD").update_resource(type, leaves_amount)
	elif type == "wood":
		wood_amount += 1
		get_node("/root").get_child(1).get_node("HUD").update_resource(type, wood_amount)
	else:
		# only other possibility (note: could make storage node for multiple checks)
		mobdrops_amount += 1
		get_node("/root").get_child(1).get_node("HUD").update_resource(type, mobdrops_amount)
