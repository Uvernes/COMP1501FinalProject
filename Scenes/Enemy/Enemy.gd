extends CharacterBody2D


const SPEED = 100
const homebase_pos = Vector2(0,0)
const distance_to_see_player = 300
const attack_range = 70
var health = 4
const damage = 2 #unused right now

func _ready():
	#position = Vector2(500, 500)
	$AttackTimer.start()


func _physics_process(delta):
	var player_pos = get_parent().get_node("Player").position
	# Movement towards the player or to "Homebase"
	if (player_pos - position).length() > distance_to_see_player:
		position = position.move_toward(homebase_pos, delta * SPEED)
	else:
		position = position.move_toward(player_pos, delta * SPEED)
	
	if ($AttackTimer.time_left == 0):
		if (player_pos - position).length() <= attack_range:
			#send signal to player that the enemey is attacking and how much damage it does?
			GlobalSingleton.take_damage(damage)
			$AttackTimer.start()
			
# Damage of the enemy.
func _take_damage(amount):
	health = health - amount
	if (health <= 0):
		queue_free()
		
	
	
	

