extends CharacterBody2D


@export var resource_scene: PackedScene

const MAX_SPEED = 100
const accel = 500
var moving = true

const homebase_pos = Vector2(0,0)
const distance_to_see_player = 300
const attack_range = 150
var health = 3
const damage = 2

var player # Reference to player object
var dead = false

func _ready():
	player = get_parent().get_node("Player")
	$AttackTimer.start()

func _physics_process(delta):
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
	for i in get_slide_collision_count():
		handle_collision(get_slide_collision(i))

# Method for receiving damage
func take_damage(amount):
	health = health - amount
	if (health <= 0):
		# create mobdrop on enemy death
		var mobdrop = resource_scene.instantiate()
		mobdrop.init("mobdrop", "res://Assets/Resources/mobdrop_resource.png")
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
func _on_attack_timer_timeout():
	if (player.position - position).length() <= attack_range:
		# when hitting player, reset speed (since they need to stop for a successful hit)
		velocity = Vector2.ZERO
		$EnemyHead.start_attack()
		# force enemy to stop moving after hit
		moving = false
		await get_tree().create_timer(1.0).timeout
		# after timer, make everything resume
		moving = true
	$AttackTimer.start()

func handle_collision(collision: KinematicCollision2D):
	var collider = collision.get_collider()
	if collider != null:
		if collider.name == "Head":
			if $TakeDamageTimer.time_left == 0:
				take_damage(collider.get_melee_damage())
				$TakeDamageTimer.start()
