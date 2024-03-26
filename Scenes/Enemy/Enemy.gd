extends CharacterBody2D


@export var resource_scene: PackedScene

const MAX_SPEED = 100
const accel = 500
var moving = true

const homebase_pos = Vector2(0,0)
const distance_to_see_player = 400
const attack_range = 100
var health = 3
const damage = 2
const min_distance_from_player = 70

var player # Reference to player object
var dead = false

func _ready():
	player = get_parent().get_node("Player")
	$AttackTimer.start()

func _physics_process(delta):
	if (player.position - position).length() <= min_distance_from_player:
		moving = false
	else:
		moving = true
	if moving:
		# change enemy movement accordingly
		if (player.position - position).length() > distance_to_see_player:
			look_at(homebase_pos)
			velocity += ((homebase_pos - position).normalized() * accel * delta)
		else:
			look_at(player.position)
			velocity += ((player.position - position).normalized() * accel * delta)
		velocity = velocity.limit_length(MAX_SPEED)
		move_and_slide()
	if (player.position - position).length() <= attack_range && $AttackTimer.time_left == 0:
		start_attack_process()

# Method for receiving damage
func take_damage(amount):
	health = health - amount
	if (health <= 0):
		# create mobdrop on enemy death
		var mobdrop = resource_scene.instantiate()
		mobdrop.init("mobdrops", "res://Assets/Resources/mobdrop_resource.png")
		mobdrop.position = Vector2((position.x)-3, (position.y)-3)
		get_parent().add_child(mobdrop)
		var randomizer = randf()
		if randomizer < 0.25:
			var dirt = resource_scene.instantiate()
			dirt.init("dirt", "res://Assets/Resources/dirt_resource.png")
			dirt.position = Vector2((position.x)+3, (position.y)+3)
			get_parent().add_child(dirt)
		elif randomizer < 0.5:
			var stone = resource_scene.instantiate()
			stone.init("stone", "res://Assets/Resources/stone_resource.png")
			stone.position = Vector2((position.x)+3, (position.y)+3)
			get_parent().add_child(stone)
		elif randomizer < 0.75:
			var leaves = resource_scene.instantiate()
			leaves.init("leaves", "res://Assets/Resources/leaves_resource.png")
			leaves.position = Vector2((position.x)+3, (position.y)+3)
			get_parent().add_child(leaves)
		else:
			var wood = resource_scene.instantiate()
			wood.init("wood", "res://Assets/Resources/wood_resource.png")
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
	pass
func stop_attacking_base():
	pass
