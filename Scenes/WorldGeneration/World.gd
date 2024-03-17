extends Node2D

@export var noise_height_text : NoiseTexture2D #makes it so i can edit the noise in the inspector.
var noise : Noise

@onready var tile_map = $TileMap
var source_id = 0 #looks at which tilemap we are using.
var ground = Vector2i(0,6) #setting the tiles based on the tilemap texture. using Vector2i because i stands for integer.
var wall = Vector2i(0,0) #same thing but the wall (darker texture.)

#settings the size of the world.
var width  = 100
var height = 100

func _ready():
	noise = noise_height_text.noise #sets the noise variable to the noise_height_texture, which was edited in the inspector.
	generate_world()

#loops throught all the tiles in the world and gets the noise value of that tile.
func generate_world():
	for x in range(width):
		for y in range(height):
			var noise_val = abs(noise.get_noise_2d(x,y)) #Returns the 2D noise value at the given position.
			#after this loops througth and gets all the tiles values, I can generate the world.
			
			#placing walls or ground based on height.
			if noise_val > 0.5:
				tile_map.set_cell(0,Vector2(x,y),source_id, ground)
			if noise_val < 0.5:
				tile_map.set_cell(0,Vector2(x,y),source_id, wall)
