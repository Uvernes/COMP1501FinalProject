extends CharacterBody2D


const MAX_SPEED = 100
const accel = 500
var moving = true

const homebase_pos = Vector2(0,0)
const distance_to_see_player = 300
const attack_range = 75
var health = 3
const damage = 2

var player # Reference to player object

func _ready():
	player = get_parent().get_node("Player")
	$AttackTimer.start()

func _physics_process(delta):
	if moving:
		# change enemy movement accordingly
		if (player.position - position).length() > distance_to_see_player:
			velocity += ((homebase_pos - position).normalized() * accel * delta)
		else:
			velocity += ((player.position - position).normalized() * accel * delta)
		velocity = velocity.limit_length(MAX_SPEED)
		move_and_slide()

# Method for recieving damage
func take_damage(amount):
	health = health - amount
	if (health <= 0):
		queue_free()

# handle enemy attack when possible
func _on_attack_timer_timeout():
	if (player.position - position).length() <= attack_range:
		# when hitting player, reset speed (since they need to stop for a successful hit)
		velocity = Vector2.ZERO
		player.hit(damage)
		# force enemy to stop moving after hit
		moving = false
		await get_tree().create_timer(1.0).timeout
		# after timer, make everything resume
		moving = true
	$AttackTimer.start()
