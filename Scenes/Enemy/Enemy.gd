extends CharacterBody2D


const SPEED = 100
const homebase_pos = Vector2(0,0)
const distance_to_see_player = 300
const attack_range = 70
var health = 3
const damage = 2 #unused right now

func _ready():
	#position = Vector2(500, 500)
	$AttackTimer.start()


func _physics_process(delta):
	var player_pos = get_parent().get_node("Player").position
	""" this is used if enemy is Area2D
	# Movement towards the player or to "Homebase"
	if (player_pos - position).length() > distance_to_see_player:
		position = position.move_toward(homebase_pos, delta * SPEED)
	else:
		position = position.move_toward(player_pos, delta * SPEED)
		"""
	# change enemy movement accordingly
	if (player_pos - position).length() > distance_to_see_player:
		velocity = (homebase_pos - position).normalized() * SPEED
	else:
		velocity = (player_pos - position).normalized() * SPEED
	
	# extract enemy collision events to detect presence of bullets
	# (also enables collision/movement simultaneously)
	var collision = move_and_collide(velocity * delta)
	if collision:
		# if collided with player bullet...
		if collision.get_collider().is_in_group("player_projectile"):
			# ...take damage, and delete the bullet object
			take_damage(collision.get_collider().damage)
			collision.get_collider().queue_free()
	
	if ($AttackTimer.time_left == 0):
		if (player_pos - position).length() <= attack_range:
			#send signal to player that the enemey is attacking and how much damage it does
			GlobalSingleton.deal_damage(damage)
			$AttackTimer.start()

# function to simulate enemy taking damage
func take_damage(amount):
	health = health - amount
	if (health <= 0):
		queue_free()

# Used if enemy is Area2D
""" connect on area entered signal
func _on_area_entered(area): 
	if area.is_in_group("player_projectile"):
		take_damage(area.damage)
		area.queue_free()
"""
