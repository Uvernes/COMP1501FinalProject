extends CharacterBody2D


const SPEED = 100
const homebase_pos = Vector2(0,0)
const distance_to_see_player = 300
const attack_range = 70
var health = 3
const damage = 2 #unused right now

var player # Reference to player object

func _ready():
	player = get_parent().get_node("Player")
	#position = Vector2(500, 500)
	$AttackTimer.start()

func _physics_process(delta):
	""" this is used if enemy is Area2D
	# Movement towards the player or to "Homebase"
	if (player_pos - position).length() > distance_to_see_player:
		position = position.move_toward(homebase_pos, delta * SPEED)
	else:
		position = position.move_toward(player_pos, delta * SPEED)
		"""
	# change enemy movement accordingly
	if (player.position - position).length() > distance_to_see_player:
		velocity = (homebase_pos - position).normalized() * SPEED
	else:
		velocity = (player.position - position).normalized() * SPEED
	
	move_and_slide()
	
	# COLLISION WITH BULLETS LOGIC MOVED TO BULLET CLASS.
	# extract enemy collision events to detect presence of bullets
	# (also enables collision/movement simultaneously)
	#var collision = move_and_collide(velocity * delta)
	#if collision:
		## if collided with player bullet...
		#if collision.get_collider().is_in_group("player_projectile"):
			## ...take damage, and delete the bullet object
			#hit(collision.get_collider().damage)
			#collision.get_collider().queue_free()
	#
	if ($AttackTimer.time_left == 0):
		if (player.position - position).length() <= attack_range:
			player.hit(damage)
			# Before: <-- should avoid singleton / global unless no other choice
			# GlobalSingleton.deal_damage(damage)
			$AttackTimer.start()

# Method for recieving damage
func hit(amount):
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
