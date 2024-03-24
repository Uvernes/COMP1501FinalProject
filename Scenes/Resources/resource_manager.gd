extends Node2D

var dirt_amount = 0
var stone_amount = 0
var leaves_amount = 0
var wood_amount = 0

var mobdrops_amount = 0

func resource_picked_up(type):
	if type == "dirt":
		dirt_amount += 1
	elif type == "stone":
		stone_amount += 1
	elif type == "leaves":
		leaves_amount += 1
	elif type == "wood":
		wood_amount += 1
	elif type == "mobdrop":
		mobdrops_amount += 1
	else:
		print("Unknown resource picked up")
