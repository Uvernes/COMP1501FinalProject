"""
Controller for the world tilemap. Attach to any tilemap for it
to take effect.
)
"""
extends TileMap

var wall_scene = load("res://Scenes/WorldStructures/CaveWall.tscn")
var wall_scene_id

# Called when the node enters the scene tree for the first time.
func _ready():
	wall_scene_id =  wall_scene.get_instance_id()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	pass
	#var mouse_pos = get_global_mouse_position()
	#var tile_coords = local_to_map(mouse_pos)
	#var tile_cell = get_cell_source_id(1, tile_coords)
	#print(mouse_pos)
	#print(tile_coords)
	#print(tile_cell)
	# erase_cell(0, tile_coords)
	

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
