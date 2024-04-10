"""
RoomController.gd: 
This is the common script shared between all rooms.
Handles logic such as detecting when the player exits the room 
(looking at Area2D) and from which side they exited.
"""
extends TileMap

signal player_close_to_exit(state)

var player
var base
var base_is_safe = false
var exits = [] #list of all open exits
const exit_range = 150

#used to prevent player_close_to_exit signal from constantly being sent
var already_warned
var already_unwarned



# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_parent().get_parent().get_node("Player")
	base = get_node_or_null("Base")
	already_warned = false
	already_unwarned = false
	if base_is_safe:
		base.becomeSafe()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	check_if_close_to_exit()

#called by game map each time an exit is cleared
func add_exit(type):
	if exits != null:
		exits.append(get_node("Entrances").get_node(type).position)

#checks if the player is close to an open exit
#sends signal to game controller if base is under attack to show/hide leaving warning
#should only send signal if it hasn't already been sent
func check_if_close_to_exit():
	var close = false
	for i in exits.size():
		if ((player.position.x > exits[i].x - exit_range) && (player.position.x < exits[i].x + exit_range) && (player.position.y > exits[i].y - exit_range) && (player.position.y < exits[i].y + exit_range)):
			close = true
			if base != null:
				if !base.safe && base.active:
					if already_warned == false:
						player_close_to_exit.emit(true)
						already_warned = true
						already_unwarned = false
	if close == false:
		if already_unwarned == false:
			player_close_to_exit.emit(false)
			already_warned = false
			already_unwarned = true
			
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
	

# Detect if the global coordinates passed in are in the room's tilemap
func global_coordinates_in_room(global_coordinates):
	var room_width = $Area2D/CollisionShape2D.shape.size.x
	var room_height = $Area2D/CollisionShape2D.shape.size.y
	return (
		(global_coordinates.x > $Area2D/CollisionShape2D.global_position.x - room_width/2) and 
		(global_coordinates.x < $Area2D/CollisionShape2D.global_position.x + room_width/2) and
		(global_coordinates.y > $Area2D/CollisionShape2D.global_position.y - room_height/2) and 
		(global_coordinates.y < $Area2D/CollisionShape2D.global_position.y + room_height/2)
	)

