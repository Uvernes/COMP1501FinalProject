"""
Controller for the world game map. Contains a large background tilemap
that is overlayed with nxn room (tile map) scenes making up the world.
)
"""
extends Node2D

# Number of rows and cols of rooms to have in main map (so not including tutorial rooms) 
# Total num rooms = n_rows x n_cols
@export var n_rows = 5
@export var n_cols = 5
@export var main_map_num_bases = 5  # Number of bases that need to be claimed in the main map

signal room_changed()


#@export var hover_tile_source_id: int
#@export var hover_tile_atlas_coords: Vector2

var Player = load("res://Scenes/Player/Player.gd")
var Placeable = preload("res://Scenes/Placeables/Placeable.gd")

# Gameplay begins with tutorial rooms placed sequentially from left to right.
# Each dict specifies path of room and whether or not it has a base
const tutorial_rooms = [
	{
		#"path": "res://Scenes/GameMap/Rooms/Main/NoBase/template_room_no_base.tscn",
		"path": "res://Scenes/GameMap/Rooms/Tutorials/tutorial_1.tscn",
		"has_base": false
	},
	{
		"path": "res://Scenes/GameMap/Rooms/Tutorials/tutorial_2.tscn",
		"has_base": true
	},
]

# Add all possible non-tutorial rooms 
const main_room_scene_paths = 	{
	"with_base": [
		"res://Scenes/GameMap/Rooms/Main/WithBase/room_with_base_1.tscn",
		"res://Scenes/GameMap/Rooms/Main/WithBase/room_with_base_10.tscn",
	],
	"no_base": [
		"res://Scenes/GameMap/Rooms/Main/NoBase/room_no_base_1.tscn",
		"res://Scenes/GameMap/Rooms/Main/NoBase/room_no_base_2.tscn",
		"res://Scenes/GameMap/Rooms/Main/NoBase/room_no_base_3.tscn",
		"res://Scenes/GameMap/Rooms/Main/NoBase/room_no_base_4.tscn",
		
	]	
}
	
# rooms that can be added:
#"res://Scenes/GameMap/Rooms/Main/NoBase/room_no_base_1.tscn"
#"res://Scenes/GameMap/Rooms/Main/NoBase/room_no_base_2.tscn"
#"res://Scenes/GameMap/Rooms/Main/NoBase/room_no_base_3.tscn"
#"res://Scenes/GameMap/Rooms/Main/WithBase/room_with_base_1.tscn"
#"res://Scenes/GameMap/Rooms/Main/NoBase/room_no_base_4.tscn"

	
# A 2D array of the rooms making up the game map for the current playthrough.
# Entries are scene paths
var game_map: Array

# cur_room_index is an integer if in tutorial rooms (since linear).
# It is a tuple of the form (row, col) if in map
var cur_room_index  
var cur_room: TileMap
var starting_room_index  # Index of very first room when game is loaded (will be a tutorial one)
var main_map_start_index  # Index of the starting room in the main map

# Nested dictionary remembering all of the builds currently placed by the player 
# for each room. Mapping:
# (Room index) -> Dictionary( (build global position) -> build_index )
var room_index_to_builds: Dictionary

# Dictionary mapping from room index to true/false, where
# true = base captured, false = base not captured yet.
# Only contains keys for rooms with a base
var room_index_with_base_to_captured: Dictionary

# Maps a room index to true if visited, o.w false
var room_index_to_visited: Dictionary

#var wall_scene = load("res://Scenes/WorldStructures/CaveWall.tscn")
#var wall_scene_id

var player
# Keep track of player's mode. If not in build mode, no hover tile displayed.
var player_mode 

# Keep track of the currently highlighted tile. Before updating, stores the previous
# one so it can be removed without having to scan the whole tile map for it.
# var cur_hover_tile_coords = null  # Starts null since nothing highlighted


# Called when the node enters the scene tree for the first time.
func _ready():
	# Init world map (both main map and tutorial rooms)
	starting_room_index = 0
	# Starting room of the main world is the center row, left most room
	main_map_start_index = [floor((n_rows - 1)/2), 0]
	init_game_map()
	
	player = get_parent().get_node("Player")
	# Init whether or not hover tile appears
	player_mode = get_parent().get_node("Player").cur_mode
	if player_mode != Player.mode.BUILD and player_mode != Player.mode.DELETE:
		$HoverTile.hide()


func _physics_process(_delta):
	# If in build or delete mode, move hover tile to center of tile cell mouse is on
	if  player_mode == Player.mode.BUILD or player_mode == Player.mode.DELETE:
		move_hover_tile_to_moused_over_cell()

		#var tile_cell = $BackgroundTileMap.get_cell_source_id(1, tile_coords)
		

		#
		#print(global_mouse_pos)
		#print(tile_coords)
		#print(tile_cell)
		#print(tile_pixel_coords)
		#print(to_global(tile_pixel_coords))
		#print("B")
		
		# move_hover_tile(tile_coords)

		
		#var mouse_pos = get_global_mouse_position()
		#var tile_coords = local_to_map(mouse_pos)
		#var tile_cell = get_cell_source_id(1, tile_coords)
		#print(mouse_pos)
		#print(tile_coords)
		#print(tile_cell)
		# erase_cell(0, tile_coords)

func init_game_map():
	# Make sure main # of main bases specified does not exceed number of main map rooms
	if main_map_num_bases > n_rows * n_cols:
		main_map_num_bases = n_rows * n_cols
	
	# Init visited rooms state
	room_index_to_visited = {}
	for i in n_rows:
		for j in n_cols:
			room_index_to_visited[[i,j]] = false
	for i in tutorial_rooms.size():
		room_index_to_visited[i] = false
	
	# Init what rooms are in the main map.
	# First create empty main map
	game_map = []
	var main_map_room_indices = []
	for i in n_rows:
		game_map.append([])
		for j in n_cols:
			game_map[i].append(null)
			main_map_room_indices.append([i,j])
	# Shuffle the room indices to randomize where base and no base rooms are placed.
	main_map_room_indices.shuffle()
	# Randomly place set amount of rooms with bases
	for index in main_map_room_indices.slice(0, main_map_num_bases):
		#print(game_map)
		#print(index)
		game_map[index[0]][index[1]] = main_room_scene_paths["with_base"].pick_random()
	# Randomly place remaining rooms without bases
	for index in main_map_room_indices.slice(main_map_num_bases):
		game_map[index[0]][index[1]] = main_room_scene_paths["no_base"].pick_random()

	# Init base captured status for rooms with bases
	for index in main_map_room_indices.slice(0, main_map_num_bases):
		room_index_with_base_to_captured[index] = false
	for index in tutorial_rooms.size():
		if tutorial_rooms[index]["has_base"]:
			room_index_with_base_to_captured[index] = false

	# Init storage keeping track of player builds (placeables) in each room
	for i in n_rows:
		for j in n_cols:
			room_index_to_builds[[i,j]] = Dictionary()
	for i in tutorial_rooms.size():
		room_index_to_builds[i] = Dictionary()
			
	#print("---")
	#print(room_index_to_visited)
	#print(room_index_to_builds)
	#print(room_index_with_base_to_captured)
	#print(game_map)
	#
	# First tutorial room edwntered from the left (which has room index 0)
	init_new_room(starting_room_index, "left") 


func move_spawn_tile_to_cell_at_pos(pos):
	var tile_coords_map = $BackgroundTileMap.local_to_map(pos)
	var tile_coords_local = $BackgroundTileMap.map_to_local(tile_coords_map)
	$SpawnTile.position = tile_coords_local
	return $SpawnTile.position

func can_spawn_mob():
	for object in $SpawnTile.objects_in_area:
		if object.is_in_group("Player"):
			return false
		if object.is_in_group("Enemy"):
			return false
		if object.is_in_group("Placeable"):
			return false
		if object.is_in_group("Obstruction"):
			return false
	return true
	
	
func move_hover_tile_to_moused_over_cell():
	var global_mouse_pos = get_global_mouse_position()
	
	# If mouse hovering outside of room, just hide hovertile
	if not cur_room.global_coordinates_in_room(global_mouse_pos):
		$HoverTile.hide()
		return
	# Otherwise proceed to rendering
	# Move hovertile to the tile mouse is over
	var tile_coords_map = $BackgroundTileMap.local_to_map(global_mouse_pos)
	var tile_coords_local = $BackgroundTileMap.map_to_local(tile_coords_map)
	$HoverTile.position  = tile_coords_local
	
	# Update hovertile status. Different statuses result in dif colour rectangles being shown
	if player_mode == Player.mode.BUILD:
		if can_place_build($HoverTile.position, player.cur_build_selection):
			$HoverTile.set_status($HoverTile.STATUSES.CAN_BUILD)
		else:
			$HoverTile.set_status($HoverTile.STATUSES.NO_OPTION)
	# Should be the only other case
	elif player_mode == Player.mode.DELETE:
		if _hover_tile_on_placeable():
			$HoverTile.set_status($HoverTile.STATUSES.CAN_DELETE)
		else:
			$HoverTile.set_status($HoverTile.STATUSES.NO_OPTION)
	$HoverTile.show()

	
	# Remove old hover tile (if not null, i.e none yet)
	#if cur_hover_tile_coords != null:
		## -1 source_id (3rd argument) means to erase the tile at tile_coords on layer 2
		#set_cell(2, cur_hover_tile_coords, -1)  
	# Set new hover tile
	#print(new_hover_tile_coords)
	#set_cell(2, new_hover_tile_coords, hover_tile_source_id, hover_tile_atlas_coords, 0)
	#cur_hover_tile_coords = new_hover_tile_coords  # Update current hover tile coords

# Determines whether or not the given build can be placed on the tile where global_mouse_pos
# is at (i.e where the hover tile is at).
# This check is done by looking at what is currently inside of the hover tile.
func can_place_build(global_mouse_pos, build_id):
	# First check if mouse pos is in bounds
	if not cur_room.global_coordinates_in_room(global_mouse_pos):
		return

	#print("B------")
	for object in $HoverTile.objects_in_area:
		# Special case for handling torches and the limit on # of pointlights.
		# Cannot play a torch in another torch's no build zone, to prevent torches being too close.
		if object.is_in_group("no_torch_build_zone"):
			if build_id == Placeable.placeables.TORCH:
				return false
			continue
		if object.is_in_group("Player"):
			return false
		if object.is_in_group("Enemy"):
			return false
		if object.is_in_group("Placeable"):
			return false
		if object.is_in_group("Obstruction"):
			return false
		if object.is_in_group("Base"):
			return false
	return true
	

func _hover_tile_on_placeable():
	for object in $HoverTile.objects_in_area:
		if object.is_in_group("Placeable"):
			return true
	return false

	
func place_build_at_hover_tile(build_instance):
	# var tile_coords = $BackgroundTileMap.local_to_map(global_mouse_pos)
	# var tile_cell = $BackgroundTileMap.get_cell_source_id(1, tile_coords)
	#print(global_mouse_pos)
	#print(tile_coords)
	#print(tile_cell)
	#
	# var global_tile_center_pos = $BackgroundTileMap.map_to_local(tile_coords)
	# build_instance.position = global_tile_center_pos
	build_instance.position = $HoverTile.position
	# Add build as child of room 
	cur_room.get_node("StructureStorage").add_child(build_instance)
	# Connect to build removed signal 
	build_instance.removed.connect(_on_build_removed)
	
	# Track the build
	room_index_to_builds[cur_room_index][build_instance.position] = build_instance.build_id
	
	#print(room_index_to_builds)
	
	#print(map_to_local(tile_coords))
	
	#set_cell(1, tile_coords, wall)


#  For now we assume only up to one build (placeable) can be on given tile at a time
func get_build_at_hover_tile():
	for object in $HoverTile.objects_in_area:
		if object.is_in_group("Placeable"):
			return object
	return null


func _on_player_mode_changed(new_mode):
	player_mode = new_mode
	if player_mode == Player.mode.BUILD or player_mode == Player.mode.DELETE:
		move_hover_tile_to_moused_over_cell()
		$HoverTile.show()
	else:
		$HoverTile.hide()
	
	
	# If changed away from build mode, remove the current hover tile (if one there).
	#if player_mode != Player.mode.BUILD:
		#if cur_hover_tile_coords != null:
		## -1 source_id (3rd argument) means to erase the tile at tile_coords on layer 2
			#set_cell(2, cur_hover_tile_coords, -1) 
			#cur_hover_tile_coords = null  # No tile longer hovered


func _on_build_removed(build):
	room_index_to_builds[cur_room_index].erase(build.position)


func _on_cur_room_base_status_changed(new_status):
	#print("updating gameMap")
	if new_status == "safe":
		_handle_cur_room_base_captured()


func _handle_cur_room_base_captured():
	if room_index_with_base_to_captured[cur_room_index] != true:
		room_index_with_base_to_captured[cur_room_index] = true
		get_parent().handle_base_captured(cur_room)


# Initialize the room just entered (either at start of the game or when entered from a dif. room).
# Initialization involves:'
# -Create room instance
# -Have exits open only where valid and closed elsewhere
# -Have player enter room from direction they were travelling
# -Create any pre-existing builds the player has in the room entered (i.e if revisiting a room)
func init_new_room(room_index, entrance):
	#print("Entered:")
	#print(room_index)
	# Mark room as visited if not already visited, and let game controller know.
	if not room_index_to_visited[room_index]:
		room_index_to_visited[room_index] = true
		get_parent().handle_room_entered_first_time()
	#print(room_index_to_visited)
	
	# Create instance of room just entered
	cur_room_index = room_index
	var is_tutorial_room = _is_tutorial_room(room_index)
	var cur_room_scene_path
	if _is_tutorial_room(room_index):
		cur_room_scene_path = tutorial_rooms[room_index]["path"]
	else:
		cur_room_scene_path = game_map[cur_room_index[0]][cur_room_index[1]]
	cur_room = load(cur_room_scene_path).instantiate()
	call_deferred("add_child", cur_room)
	#add_child(cur_room)
	
	# Set up any required connections
	# If room has a base, check if it needs to be considered safe
	if cur_room.get_node_or_null("Base"):
		if room_index_with_base_to_captured[cur_room_index]:
			cur_room.base_is_safe = true
	
	#print("in init_new_room...")
	#print(is_tutorial_room)
	##print(game_map)
	##print(room_index_to_builds)
	#print(cur_room_index)
	#
	# Open any valid exits (e.g if room to the right, open exit to the right)
	_init_room_exits(cur_room, room_index, is_tutorial_room)

	# Have player start in room at the specified entrance
	get_parent().get_node("Player").global_position = \
		cur_room.get_node("Entrances").get_node(entrance).global_position
	cur_room.get_node("Entrances").hide()  # Entrances are just markers for the inspector, can hide
	
	# Restore any pre-existing builds
	#print(room_index_to_builds)
	for build_position in room_index_to_builds[cur_room_index]:
		var build_id = room_index_to_builds[cur_room_index][build_position]
		var build_instance = Placeable.packed_scenes[build_id].instantiate()
		build_instance.position = build_position
		cur_room.get_node("StructureStorage").add_child(build_instance)
		build_instance.removed.connect(_on_build_removed)


func _is_tutorial_room(room_index):
	return typeof(room_index) == TYPE_INT


# By default all exits are closed. Remove the closing for all exits that are valid
# (e.g can't enter the right-side exit if in a room on the right-most side of the map)
func _init_room_exits(room, room_index, is_tutorial_room):
	room.get_node("ClosedExits").modulate.a = 1  # Alpha changed in inspector for dinstinguishing
	# If in tutorial room, room index is an int
	if is_tutorial_room:
		if room_index > 0:
			room.get_node("ClosedExits/left").queue_free()
			room.add_exit("left") 
		# Can always exit right. Whether that is to another tutorial room or main map
		room.get_node("ClosedExits/right").queue_free()
		room.add_exit("right")
	# If in main map, room index is a tuple
	else:	
		if room_index[0] > 0:
			room.get_node("ClosedExits/up").queue_free()
			room.add_exit("up")
		if room_index[0] < n_rows - 1:
			room.get_node("ClosedExits/down").queue_free()
			room.add_exit("down")
		if room_index[1] > 0:
			room.get_node("ClosedExits/left").queue_free()
			room.add_exit("left")
		if room_index[1] < n_cols - 1:
			room.get_node("ClosedExits/right").queue_free()
			room.add_exit("right")
	# Special case. Exit open if in the starting room of the main map. This is since there are 
	# tutorial rooms to the left of this room.
	if not is_tutorial_room and cur_room_index == main_map_start_index :
		cur_room.get_node("ClosedExits/left").queue_free()
		cur_room.add_exit("left")


# When player exits a room, delete the current room scene and change to the next room.
func handle_room_exit(direction):
	#print("start index main map: " + str(main_map_start_index))
	#print("cur room index: " + str(cur_room_index))
	# Free the previous room
	cur_room.queue_free()
	
	# One of "left", "right", "up" or "down" based on direction player exited.
	# e.g if exited to the right then they enter the new room from the left
	var entrance 
	
	# Compute new room index and entrance.
	var new_room_index
	# Case where a tutorial room exited
	if _is_tutorial_room(cur_room_index):
		# Go to main map if in right most tutorial room and moved right
		if direction == "right" and cur_room_index == tutorial_rooms.size() - 1:
			new_room_index = main_map_start_index.duplicate()
			entrance = "left"
		elif direction == "right":
			new_room_index = cur_room_index + 1
			entrance = "left"
		elif direction == "left" and cur_room_index > 0:
			new_room_index = cur_room_index - 1
			entrance = "right"
		# Case where you move exit from the left in 1st tutorial room (but shouldn't be possible)
		else:
			new_room_index = cur_room_index
			entrance = "right"
	# Special case. Main map room exited and it leads back to a tutorial room
	elif cur_room_index == main_map_start_index and direction == "left":
		new_room_index = tutorial_rooms.size() - 1
		entrance = "right"
	# Case where a main map room exited and we stay in the main map
	else:
		new_room_index = cur_room_index.duplicate()
		if direction == "up":
			new_room_index[0] -= 1
			entrance = "down"
		elif direction == "down":
			new_room_index[0] += 1
			entrance = "up"
		elif direction == "left":
			new_room_index[1] -= 1
			entrance = "right"
		elif direction == "right":
			new_room_index[1] += 1
			entrance = "left"
		# Sanity check error handling (but shouldn't occur)
		if new_room_index[0] < 0:
			new_room_index[0] = 0
			entrance = direction  # Simulates staying in room
		if new_room_index[0] > n_rows - 1:
			new_room_index[0] = n_rows - 1
			entrance = direction  
		if new_room_index[1] < 0:
			new_room_index[1] = 0
			entrance = direction  
		if new_room_index[1] > n_cols - 1:
			new_room_index[1] = n_cols - 1
			entrance = direction  
	
	init_new_room(new_room_index, entrance)
	room_changed.emit()


func total_rooms():
	return n_rows * n_cols + tutorial_rooms.size()


func total_bases():
	return room_index_with_base_to_captured.size()
	

func get_num_rooms_visited():
	var num_rooms_visited = 0
	for index in room_index_to_visited:
		if room_index_to_visited[index]:
			num_rooms_visited += 1
	return num_rooms_visited


func get_num_bases_captured():
	var num_bases_captured = 0
	for index in room_index_with_base_to_captured:
		if room_index_with_base_to_captured[index]:
			num_bases_captured += 1
	return num_bases_captured
	

# Returns true iff game won
func is_game_won():
	return get_num_bases_captured() == total_bases() 


