"""
Controller for the world tilemap. Attach to any tilemap for it
to take effect.
)
"""
extends TileMap

@export var hover_tile_source_id: int
@export var hover_tile_atlas_coords: Vector2

var Player = load("res://Scenes/Player/Player.gd")

var wall_scene = load("res://Scenes/WorldStructures/CaveWall.tscn")
var wall_scene_id

# Keep track of player's mode. If not in build mode, no hover tile displayed.
var player_mode 

# Keep track of the currently highlighted tile. Before updating, stores the previous
# one so it can be removed without having to scan the whole tile map for it.
var cur_hover_tile_coords = null  # Starts null since nothing highlighted

# Called when the node enters the scene tree for the first time.
func _ready():
	wall_scene_id =  wall_scene.get_instance_id()
	
	player_mode = get_parent().get_node("Player").cur_mode 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	# If in build mode, create next hover tile (and delete previous one)
	if player_mode == Player.mode.BUILD:
		var global_mouse_pos = get_global_mouse_position()
		var tile_coords = local_to_map(global_mouse_pos)
		var tile_cell = get_cell_source_id(1, tile_coords)
		update_hover_tile(tile_coords)
		
		#var mouse_pos = get_global_mouse_position()
		#var tile_coords = local_to_map(mouse_pos)
		#var tile_cell = get_cell_source_id(1, tile_coords)
		#print(mouse_pos)
		#print(tile_coords)
		#print(tile_cell)
		# erase_cell(0, tile_coords)
	
func update_hover_tile(new_hover_tile_coords):
	# Remove old hover tile (if not null, i.e none yet)
	if cur_hover_tile_coords != null:
		# -1 source_id (3rd argument) means to erase the tile at tile_coords on layer 2
		set_cell(2, cur_hover_tile_coords, -1)  
	# Set new hover tile
	print(new_hover_tile_coords)
	set_cell(2, new_hover_tile_coords, hover_tile_source_id, hover_tile_atlas_coords, 0)
	cur_hover_tile_coords = new_hover_tile_coords  # Update current hover tile coords

func _on_player_build_requested(global_mouse_pos):
	# Create new building - hardcoded for now to be a wall
	var wall = wall_scene.instantiate()

	var tile_coords = local_to_map(global_mouse_pos)
	var tile_cell = get_cell_source_id(1, tile_coords)
	print(global_mouse_pos)
	print(tile_coords)
	print(tile_cell)
	
	var global_tile_center_pos = map_to_local(tile_coords)
	wall.position = global_tile_center_pos
	get_tree().root.add_child(wall)
	print(map_to_local(tile_coords))
	
	#set_cell(1, tile_coords, wall)
	pass # Replace with function body.


func _on_player_mode_changed(new_mode):
	player_mode = new_mode
	
	# If changed away from build mode, remove the current hover tile (if one there).
	if player_mode != Player.mode.BUILD:
		if cur_hover_tile_coords != null:
		# -1 source_id (3rd argument) means to erase the tile at tile_coords on layer 2
			set_cell(2, cur_hover_tile_coords, -1) 
			cur_hover_tile_coords = null  # No tile longer hovered

