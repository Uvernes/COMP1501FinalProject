"""
RoomController.gd: 
This is the common script shared between all rooms.
Handles logic such as detecting when the player exits the room 
(looking at Area2D) and from which side they exited.
"""
extends TileMap


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func return_base():
	return get_node("Base")


# Detect when player exits the room and from which side, and relay this to
# the game map controller (parent).
# Possible exit sides: "left", "right", "up", "down"
func _on_area_2d_body_exited(body):
	if not body.is_in_group("Player"):
		return
	# Determine which side player exited from
	var direction
	var room_width = $Area2D/CollisionShape2D.shape.size.x
	var room_height = $Area2D/CollisionShape2D.shape.size.y
	if (body.global_position.x <= 
			$Area2D/CollisionShape2D.global_position.x - room_width/2):
		direction = "left"
	elif (body.global_position.x >= 
			$Area2D/CollisionShape2D.global_position.x + room_width/2):
		direction = "right"
	elif (body.global_position.y <= 
			$Area2D/CollisionShape2D.global_position.y - room_height/2):
		direction = "up"
	else:
		direction = "down"

	get_parent().handle_room_exit(direction)
