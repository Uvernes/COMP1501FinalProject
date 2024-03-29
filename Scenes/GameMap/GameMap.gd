"""
Controller for the world game map. Contains a large background tilemap
that is overlayed with nxn room (tile map) scenes making up the world.
)
"""
extends Node2D
#
#@export var hover_tile_source_id: int
#@export var hover_tile_atlas_coords: Vector2

var Player = load("res://Scenes/Player/Player.gd")

#var wall_scene = load("res://Scenes/WorldStructures/CaveWall.tscn")
#var wall_scene_id

# Keep track of player's mode. If not in build mode, no hover tile displayed.
var player_mode 

# Keep track of the currently highlighted tile. Before updating, stores the previous
# one so it can be removed without having to scan the whole tile map for it.
# var cur_hover_tile_coords = null  # Starts null since nothing highlighted


# Called when the node enters the scene tree for the first time.
func _ready():
	player_mode = get_parent().get_node("Player").cur_mode
	if player_mode != Player.mode.BUILD and player_mode != Player.mode.DELETE:
		$HoverTile.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _physics_process(delta):
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
	
	
func move_hover_tile_to_moused_over_cell():
	var global_mouse_pos = get_global_mouse_position()
	var tile_coords_map = $BackgroundTileMap.local_to_map(global_mouse_pos)
	var tile_coords_local = $BackgroundTileMap.map_to_local(tile_coords_map)
	$HoverTile.position  = tile_coords_local
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
	#print("A------")
	#for object in $HoverTile.objects_in_area:
		#print(object.get_class() + " " + str(object.get_groups()))
	#print("B------")
	for object in $HoverTile.objects_in_area:
		if object.is_in_group("Player"):
			return false
		if object.is_in_group("Enemy"):
			return false
		if object.is_in_group("Placeable"):
			return false
		if object.is_in_group("Obstruction"):
			return false
	return true
	
	
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
	
	get_tree().root.add_child(build_instance)
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

