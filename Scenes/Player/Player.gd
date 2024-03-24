extends CharacterBody2D

signal health_changed(new_health: int)
signal stamina_changed(new_stamina: int)
signal mode_changed(new_mode: int)

 # Player signals that they want to build. Indirect rather than direct call
# as there is lots of logic game controller handles (e.g cost to build, etc.)
# For now. Simplified and tile map just picks it up.
signal build_requested(global_mouse_pos: Vector2)
 
# Enum for what mode the player is currently in
enum mode { MELEE, SHOOT, DELETE, BUILD }

# Stats - can be upgraded over time
var max_health = 10
var max_stamina = 10
var bullet_speed = 500
var bullet_damage = 1

const max_speed = 300
const accel = 1500
const friction = 1000
# Represents direction to go into
var direction = Vector2.ZERO

# Current values
var cur_health
var cur_stamina
var cur_mode  # Current mode player is in (e.g Build mode)

# UNUSED CONSTANT
# const max_bullet_count = 3
# make a scene to be used for Bullet creation
# how much stamina does a bullet take? currently set to 3
const bullet_stamina_use = 3

@export var bullet_scene: PackedScene
const Bullet = preload("res://Scenes/Bullet/bullet.gd") # For type annotation


func _ready():
	position = Vector2(0,0)
	cur_health = max_health
	cur_stamina = max_stamina
	
	# Starting, default mode is melee
	cur_mode = mode.MELEE


func _process(_delta):
	_update_mode()
		
	# handle left mouse click
	if Input.is_action_just_pressed("LMB"):
		_handle_left_mouse_click()

func _physics_process(delta):
	look_at(get_global_mouse_position())
	player_movement(delta)


# get updated direction value for player
func get_direction():
	direction.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	direction.y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	return direction.normalized()

# handles player movement
func player_movement(delta):
	direction = get_direction()
	
	if direction == Vector2.ZERO:
		if velocity.length() > (friction * delta):
			velocity -= velocity.normalized() * (friction * delta)
		else:
			velocity = Vector2.ZERO
	else:
		velocity += (direction * accel * delta)
		velocity = velocity.limit_length(max_speed)
		
	move_and_slide()


func _update_mode():
	# Check if mode changed
	var mode_has_changed = false
	if Input.is_action_just_pressed("MWU"):
		cur_mode += 1
		mode_has_changed = true
	if Input.is_action_just_pressed("MWD"):
		cur_mode -= 1
		mode_has_changed = true
	# Wrap around if scrolled past end / beginnning
	if cur_mode < 0:
		cur_mode = mode.size() - 1 # Wrap around
	elif cur_mode >= mode.size():
		cur_mode = 0
	if mode_has_changed:
		mode_changed.emit(cur_mode)

func _handle_left_mouse_click():
	if cur_mode == mode.SHOOT:
		shoot()
	elif cur_mode == mode.BUILD:
		build()
	# TODO. Other mode logic

# Method for recieving damage
func hit(amount):
	cur_health -= amount
	health_changed.emit(cur_health)
	if (cur_health <= 0):
		# TODO - send out player_death signal. Game controller should handle death
		get_tree().quit()

func shoot():
	# compares the current stamina to the amount of stamina needed to fire a bullet.
	print(cur_stamina)
	if cur_stamina >= bullet_stamina_use:
		# if we have enought stamina, create new bullet for player
		var bullet: Bullet = bullet_scene.instantiate()
		# add bullet as a child to keep track of its existence
		$Bullet_Storage.add_child(bullet)
		# Reduce the amount of stamina a player has and sends signal to HUD
		cur_stamina -= bullet_stamina_use
		stamina_changed.emit(cur_stamina)
		#checks stamina and sets a timer for the stamina regeneration.
		stamina_check()
		# we create a direction vector to move appropriately. It is the direction of the mouse pointer from the player
		var bullet_direction = (get_global_mouse_position() - position).normalized()
		bullet.init(position, rotation, bullet_speed, bullet_direction, bullet_damage)
		bullet.fire()

func build():
	build_requested.emit(get_global_mouse_position())

func stamina_check():
	if(cur_stamina <= 0):
			cur_stamina = 0
	$StaminaTimer.start()

func _on_stamina_timer_timeout():
	cur_stamina = max_stamina

