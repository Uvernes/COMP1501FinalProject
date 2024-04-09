extends CharacterBody2D


@export var resource_scene: PackedScene
@onready var _animated_sprite = $AnimatedSprite2D

const attack_range = 100 # to start attacking
const max_attack_angle = 0.7

# external references
var player: CharacterBody2D 
var nav_agent: NavigationAgent2D
var base
var game_controller

# enemy stats
const MAX_SPEED = 100
const accel = 500
const rotation_speed = 4
var health = 3
const damage = 2
const min_distance_from_player = 70 # to stop moving

# enemy state
var dead = false
var angle_to_face
var difficulty
var target
var moving = true
var attacking_base = false

# misc
var itemdropdistancerange = 20

func _ready():
	player = get_tree().get_current_scene().get_node("Player")
	base = get_parent().get_parent().get_parent().get_node_or_null("Base")
	game_controller = get_tree().get_current_scene()
	nav_agent = $NavigationAgent2D
	
	if base != null:
		base.connect("status_changed", base_status_changed)
	target = player
	
	$AttackTimer.start()
	angle_to_face = 0
	difficulty = 1
	
func _process(_delta):
	if moving:
		_animated_sprite.play()
	else:
		_animated_sprite.stop()

func base_status_changed(type): #types: "under attack", "inactive", "safe"
	if type == "inactive":
		target = player
	elif type == "safe":
		queue_free()
	elif type == "under attack":
		if (player.global_position - global_position).length() > (base.global_position - global_position).length():
			target = base
		else:
			target = player

func _physics_process(delta):
	if target == null:
		target = player
	if attacking_base == false:
		#Stops moving when too close to player, or when stunned by knockback (will still be moved by knockback)
		if (player.position - position).length() <= min_distance_from_player || $StunTimer.time_left > 0:
			moving = false
		else:
			moving = true
		if moving:
			angle_to_face = (target.position - position).angle()
			rotation = lerp_angle(rotation, angle_to_face, delta * rotation_speed)
			
			var dir = (nav_agent.get_next_path_position()-global_position).normalized()
			velocity += (dir * accel * delta)
			velocity = velocity.limit_length(MAX_SPEED)
			move_and_slide()
		#if taking knockback:
		elif $StunTimer.time_left > 0:
			move_and_slide()
		#if not moving, not taking knockback, checks if enemy can hit player
		#will back up from player if not moving and too close to hit
		elif abs((player.position - position).angle() - rotation) > max_attack_angle:
			velocity -= ((player.position - position).normalized() * accel * delta)
			velocity = velocity.limit_length(MAX_SPEED)
			move_and_slide()
		#will attack player if in attack range and at correct angle for hit to land
		# (and player not dashing)
		if ((player.position - position).length() <= attack_range and $AttackTimer.time_left == 0
			and not player.dashing):
			angle_to_face = (player.position - position).angle()
			if abs(angle_to_face - rotation) < max_attack_angle:
				start_attack_process()
	#for attacking base:
	elif $AttackTimer.time_left == 0:
		start_attack_process()

# Method for receiving damage
func take_damage(amount,attacker,knockback=Vector2.ZERO,force=0):
	print(attacker)
	health = health - amount
	if (health <= 0):
		# create mobdrop on enemy death
		var mobdrop = resource_scene.instantiate()
		mobdrop.init("mobdrops","res://Assets/Resources/body.png")
		mobdrop.position = Vector2((position.x)-(randf_range(-itemdropdistancerange, itemdropdistancerange)), (position.y)-(randf_range(-itemdropdistancerange, itemdropdistancerange)))
		get_parent().add_child(mobdrop)
		var randomizer = randf()
		if randomizer < 0.25:
			var dirt = resource_scene.instantiate()
			dirt.init("dirt", "res://Assets/Resources/dirt.png")
			dirt.position = Vector2((position.x)+(randf_range(-itemdropdistancerange, itemdropdistancerange)), (position.y)+(randf_range(-itemdropdistancerange, itemdropdistancerange)))
			get_parent().add_child(dirt)
		elif randomizer < 0.5:
			var stone = resource_scene.instantiate()
			stone.init("stone", "res://Assets/Resources/rock.png")
			stone.position = Vector2((position.x)+(randf_range(-itemdropdistancerange, itemdropdistancerange)), (position.y)+(randf_range(-itemdropdistancerange, itemdropdistancerange)))
			get_parent().add_child(stone)
		elif randomizer < 0.75:
			var leaves = resource_scene.instantiate()
			leaves.init("leaves", "res://Assets/Resources/leaf.png")
			leaves.position = Vector2((position.x)+(randf_range(-itemdropdistancerange, itemdropdistancerange)), (position.y)+(randf_range(-itemdropdistancerange, itemdropdistancerange)))
			get_parent().add_child(leaves)
		else:
			var wood = resource_scene.instantiate()
			wood.init("wood", "res://Assets/Resources/wood.png")
			wood.position = Vector2((position.x)+(randf_range(-itemdropdistancerange, itemdropdistancerange)), (position.y)+(randf_range(-itemdropdistancerange, itemdropdistancerange)))
			get_parent().add_child(wood)
		self.dead = true
		game_controller.update_enemy_death_count(difficulty)
		queue_free()
	# 40% chance of changing target upon taking damage
	if randf() <= 0.4:
		stop_attacking_base()
		target = attacker
	velocity *= (knockback * accel * force * get_physics_process_delta_time())#+= makes knockback look very inconsistent
	$StunTimer.start()
	move_and_slide()

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

#called by base when enemy enters ita
func attack_base():
	attacking_base = true
	moving = false

#called by base when enemy exits it, called by enemy when damaged
func stop_attacking_base():
	attacking_base = false
	moving = true

func make_path(target):
	nav_agent.target_position = target.global_position

func _on_path_update_timer_timeout():
	make_path(target)
