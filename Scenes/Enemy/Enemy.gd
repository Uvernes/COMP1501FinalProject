extends CharacterBody2D


@export var resource_scene: PackedScene

const MAX_SPEED = 100
const accel = 500
const rotation_speed = 4
var moving = true
var attacking_base = false

const homebase_pos = Vector2(0,0)
const distance_to_see_player = 400
const attack_range = 100
const max_attack_angle = 0.7
var health = 3
const damage = 2
const min_distance_from_player = 70
var angle_to_face

var player # Reference to player object
var dead = false

func _ready():
	player = get_parent().get_node("Player")
	$AttackTimer.start()
	angle_to_face = 0

func _physics_process(delta):
	if attacking_base == false: #for now, once an enemy starts attacking the base they won't stop
		if (player.position - position).length() <= min_distance_from_player:
			moving = false
		else:
			moving = true
		if moving:
			# change enemy movement accordingly
			if (player.position - position).length() > distance_to_see_player:
				angle_to_face = (homebase_pos - position).angle()
				rotation =  lerp_angle(rotation, angle_to_face, delta * rotation_speed)
				velocity += ((homebase_pos - position).normalized() * accel * delta)
			else:
				angle_to_face = (player.position - position).angle()
				rotation = lerp_angle(rotation, angle_to_face, delta * rotation_speed)
				velocity += ((player.position - position).normalized() * accel * delta)
			velocity = velocity.limit_length(MAX_SPEED)
			move_and_slide()
		elif abs((player.position - position).angle() - rotation) > max_attack_angle:
			velocity -= ((player.position - position).normalized() * accel * delta)
			velocity = velocity.limit_length(MAX_SPEED)
			move_and_slide()
		if (player.position - position).length() <= attack_range && $AttackTimer.time_left == 0:
			angle_to_face = (player.position - position).angle()
			if abs(angle_to_face - rotation) < max_attack_angle:
				start_attack_process()
	elif $AttackTimer.time_left == 0:
		start_attack_process()

# Method for receiving damage
func take_damage(amount):
	health = health - amount
	stop_attacking_base() #remove to prioritze attacking base over player
	if (health <= 0):
		# create mobdrop on enemy death
		var mobdrop = resource_scene.instantiate()
		mobdrop.init("mobdrops", "res://Assets/Resources/mobdrop_resource.png")
		mobdrop.position = Vector2((position.x)-3, (position.y)-3)
		get_parent().add_child(mobdrop)
		var randomizer = randf()
		if randomizer < 0.25:
			var dirt = resource_scene.instantiate()
			dirt.init("dirt", "res://FinalAssets/Resources/dirt.png")
			dirt.position = Vector2((position.x)+3, (position.y)+3)
			get_parent().add_child(dirt)
		elif randomizer < 0.5:
			var stone = resource_scene.instantiate()
			stone.init("stone", "res://FinalAssets/Resources/rock.png")
			stone.position = Vector2((position.x)+3, (position.y)+3)
			get_parent().add_child(stone)
		elif randomizer < 0.75:
			var leaves = resource_scene.instantiate()
			leaves.init("leaves", "res://FinalAssets/Resources/leaf.png")
			leaves.position = Vector2((position.x)+3, (position.y)+3)
			get_parent().add_child(leaves)
		else:
			var wood = resource_scene.instantiate()
			wood.init("wood", "res://FinalAssets/Resources/wood.png")
			wood.position = Vector2((position.x)+3, (position.y)+3)
			get_parent().add_child(wood)
		self.dead = true
		queue_free()

# handle enemy attack when possible
func start_attack_process():
	# when hitting player, reset speed (since they need to stop for a successful hit)
	velocity = Vector2.ZERO
	$EnemyHead.start_attack()
	$AttackTimer.start()
	# force enemy to stop moving after hit
	moving = false
	await get_tree().create_timer(1.0).timeout
	# after timer, make everything resume
	moving = true

func attack_base():
	attacking_base = true
	moving = false

func stop_attacking_base():
	attacking_base = false
	moving = true
