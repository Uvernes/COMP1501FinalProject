"""
Hover tile scene. Controlled by the gameMap scene and moves around with the player
mouse when in build mode. Contains a list that maintains any areas or bodies currently
within the hover tile area.
"""
extends Area2D

var objects_in_area = []  # Objects currently in hover tile area

# Hovertile can be in one of three statuses. Able to build at current tile,
# able to delete at current tile, and unable to do anything.
# Depends on both the player (mode, build selection) and the game map.
# Controlled by the game map.
enum STATUSES { CAN_BUILD, CAN_DELETE, NO_OPTION }

const status_to_color_rect  = {
	STATUSES.CAN_BUILD: "CanPlaceRect",
	STATUSES.CAN_DELETE: "CanDeleteRect",
	STATUSES.NO_OPTION: "NoOptionRect"
}

var status

func _ready():
	$CanPlaceRect.hide()
	$CanDeleteRect.hide()
	$NoOptionRect.hide()
	status = STATUSES.NO_OPTION  # Default value
	
	
func _on_area_entered(area):
	objects_in_area.append(area)
	#print(objects_in_area)


func _on_body_entered(body):
	objects_in_area.append(body)
	#print(objects_in_area)


func _on_area_exited(area):
	objects_in_area.erase(area)


func _on_body_exited(body):
	objects_in_area.erase(body)


func set_status(new_status):
	if status == new_status:
		return
	get_node(status_to_color_rect[status]).hide()
	status = new_status
	get_node(status_to_color_rect[status]).show()
		
