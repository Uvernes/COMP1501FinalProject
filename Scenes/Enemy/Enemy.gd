extends CharacterBody2D


const SPEED = 150
const homebase_pos = Vector2(0,0)
const distance_to_see_player = 1200

func _ready():
	position = Vector2(500, 500)


func _physics_process(delta):
	if abs($Player.position.length() - position.length()) > distance_to_see_player:
		position = position.move_toward(homebase_pos, delta * SPEED)
	else:
		position = position.move_toward($Player.position, delta * SPEED)
	
	
	

