extends CharacterBody2D


const SPEED = 100
const homebase_pos = Vector2(0,0)
const distance_to_see_player = 300

func _ready():
	position = Vector2(500, 500)


func _physics_process(delta):
	var player_pos = get_parent().get_node("Player").position
	if abs(player_pos.length() - position.length()) > distance_to_see_player:
		position = position.move_toward(homebase_pos, delta * SPEED)
	else:
		position = position.move_toward(player_pos, delta * SPEED)
	
	
	

