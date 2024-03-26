extends CharacterBody2D

signal health_changed(new_health: int)
signal stamina_changed(new_stamina: int)
signal mode_changed(new_mode: int)
signal build_selection_changed(new_build_selection: int)
signal player_death()

 # Player signals that they want to build. Indirect rather than direct call
# as there is lots of logic game controller handles (e.g cost to build, etc.)
# For now. Simplified and tile map just picks it up.
signal build_requested(global_mouse_pos: Vector2, build_id: int)

 
# Enum for what mode the player is currently in
enum mode { MELEE, SHOOT, DELETE, BUILD }

# Stats - can be upgraded over time
var max_health = 10
var max_stamina = 14
var bullet_speed = 500
var bullet_damage = 1

const walk_speed = 300
const sprint_speed = 600
const accel = 1500
const friction = 1000
# Represents direction to go into
var direction = Vector2.ZERO

var cur_speed

# Current values
var cur_health
var cur_stamina
var cur_mode  # Current mode player is in (e.g Build mode)
var cur_build_selection: int # holds id for the corresponding build enum value

const bullet_stamina_use = 2

@export var bullet_scene: PackedScene
const Bullet = preload("res://Scenes/Bullet/bullet.gd") # For type annotation
const Placeable = preload("res://Scenes/Placeables/Placeable.gd")



func _ready():
	position = Vector2(0,0)
	cur_health = max_health
	cur_stamina = max_stamina
	
	cur_speed = walk_speed
	
	# Starting, default mode is melee
	cur_mode = mode.MELEE
	# Starting build selection is the first build (torch)
	cur_build_selection = 0


func _process(_delta):
	_update_mode()
	
	if Input.is_action_just_pressed("tab"):
		_handle_tab_pressed()
	if Input.is_action_just_pressed("LMB"):
		_handle_left_mouse_click()
	if Input.is_action_just_pressed("RMB"):
		_handle_right_mouse_click()


func _physics_process(delta):
	look_at(get_global_mouse_position())
	player_movement(delta)


func _input(event: InputEvent):
	pass
	

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
		velocity = velocity.limit_length(cur_speed)
		
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


# Pressing tab changes the build to the one below. Wrap around to top if at bottom
func _handle_tab_pressed():
	cur_build_selection += 1
	if cur_build_selection >= Placeable.placeables.size():
		cur_build_selection = 0
	build_selection_changed.emit(cur_build_selection)
	
	
func _handle_left_mouse_click():
	if cur_mode == mode.SHOOT:
		shoot()
	elif cur_mode == mode.BUILD:
		build()
	# TODO. Other mode logic

func _handle_right_mouse_click():
	if cur_mode == mode.MELEE:
		$Head.start_attack()

# Method for recieving damage
func hit(amount):
	cur_health -= amount
	health_changed.emit(cur_health)
	if (cur_health <= 0):
		player_death.emit()

func shoot():
	# compares the current stamina to the amount of stamina needed to fire a bullet.
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
	build_requested.emit(get_global_mouse_position(), cur_build_selection)


func stamina_check():
	if(cur_stamina <= 0):
			cur_stamina = 0
	$StaminaTimer.start()

func _on_stamina_timer_timeout():
	if cur_stamina < max_stamina:
		cur_stamina += 4
	elif cur_stamina > max_stamina:
		cur_stamina = max_stamina
	stamina_changed.emit(cur_stamina)

func sprint():
	if Input.is_action_just_pressed("shift"):
		cur_speed = sprint_speed
		print("shift")
	if Input.is_action_just_released("shift"):
		cur_speed = walk_speed

func respawn():
	cur_health = max_health
	health_changed.emit(cur_health)
	cur_stamina = max_stamina
	stamina_changed.emit(cur_stamina)
	velocity = Vector2(0,0)
	cur_speed = walk_speed
	position = Vector2(0,0)
