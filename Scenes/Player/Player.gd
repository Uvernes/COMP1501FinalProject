extends CharacterBody2D

signal health_changed(new_health: int)
signal stamina_changed(new_stamina: int)
signal mode_changed(new_mode: int)
signal build_selection_changed(new_build_selection: int)
signal player_death()
signal max_health_changed(new_max)
signal max_stamina_changed(new_max)
signal direction_changed(new_direction)

 # Player signals that they want to build / delete. Indirect rather than direct call
# as there is lots of logic game controller handles (e.g cost to build, etc.)
signal build_requested(global_mouse_pos: Vector2, build_id: int)
signal delete_requested(global_mouse_pos: Vector2)
 
# Enum for what mode the player is currently in
enum mode { ATTACK, BUILD, DELETE }

# Stats - can be upgraded over time
var max_health = 20
var max_stamina = 20
var bullet_speed = 500
var bullet_damage = 1

var stamina_percentage_regen = 0.20
const walk_speed = 300
const sprint_speed = 600
const accel = 1500
const friction = 1000
# Represents direction to go into
var direction = Vector2.ZERO

# Dash-related variabled
@export var dash_speed = 1000
@export var dash_max_distance = 300  # Max distance. Less if you bump into world obstacle (e.g wall)
@export var dash_stamina_use = 4
@export var dash_knockback_force = 50

@onready var _animated_sprite = $Thorax/AnimatedSprite2D
@onready var dash_sound = $Dash
@onready var shoot_sound = $Shoot
@onready var walk_sound = $Walk
# @export var dash_cooldown =  0.5  # In seconds
var dashing = false 
var cur_dash_distance = 0
var time_since_last_dash

# Current values
var cur_speed
var cur_health
var cur_stamina
var cur_mode  # Current mode player is in (e.g Build mode)
var cur_build_selection: int # holds id for the corresponding build enum value


const bullet_stamina_use = 1

@export var bullet_scene: PackedScene
const Bullet = preload("res://Scenes/Bullet/bullet.gd") # For type annotation
const Placeable = preload("res://Scenes/Placeables/Placeable.gd")

var enemies_following = 0

func _ready():
	# position = Vector2(0,0)
	cur_health = max_health
	cur_stamina = max_stamina
	
	cur_speed = walk_speed
	
	# Starting, default mode is attack
	cur_mode = mode.ATTACK
	# Starting build selection is the first build (torch)
	cur_build_selection = 0


func _process(_delta):
	#print("Player mode:")
	#print(cur_mode)
	
	_update_mode()
	
	if Input.is_action_just_pressed("shift"):
		_handle_shift_pressed()
	if Input.is_action_just_pressed("LMB"):
		_handle_left_mouse_click()
	if Input.is_action_just_pressed("RMB"):
		_handle_right_mouse_click()
	if Input.is_action_just_pressed("space"):
		_handle_space_bar_pressed()
		
	if Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left") or Input.is_action_pressed("move_up")or Input.is_action_pressed("move_down"):
		_animated_sprite.play()
		if not walk_sound.is_playing():
			walk_sound.pitch_scale = randf_range(0.9, 1.1)
			walk_sound.play()
	else:
		_animated_sprite.stop()
		walk_sound.stop()
	

# Handles hotkey presses
func _unhandled_input(event):
	if event is InputEventKey:
		for i in Placeable.placeables.size():
			if event.pressed and event.keycode == KEY_1 + i:
				cur_build_selection = i
				build_selection_changed.emit(cur_build_selection)
				break


func _physics_process(delta):
	look_at(get_global_mouse_position())
	player_movement(delta)

# get updated direction value for player
func get_direction():
	direction.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	direction.y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	return direction.normalized()

func set_direction(new_direction):
	direction = new_direction
	emit_signal("direction_changed", new_direction)

# handles player movement
func player_movement(delta):
	if dashing:
		_dash_movement(delta)
	else: 
		_regular_movement(delta)


func _dash_movement(delta):
	cur_dash_distance += dash_speed * delta
	# Check if done dashing
	if cur_dash_distance >= dash_max_distance:
		dashing = false
		velocity = Vector2.ZERO
		$DashCoolDownTimer.start()
		return
	# Continue dashing
	velocity = direction * dash_speed
	
	var collision = move_and_collide(velocity*delta)
	if collision:
		var collider = collision.get_collider()
		if collider.is_in_group("Enemy"):
			# Knockback direction is perpendicular to player direction
			var knockback_direction = Vector2(-direction.y, direction.x)
			
			collider.take_damage(0.5, self, knockback_direction, dash_knockback_force)
			
	#
	#return 
	#for i in get_slide_collision_count():
		#var collision = get_slide_collision(i)
		#var collider = collision.get_collider()
		#if collider.is_in_group("Enemy"):
			## Knockback direction is perpendicular to player direction
			#var knockback_direction = Vector2(-direction.y, direction.x)
			#
			#collider.take_damage(0, knockback_direction, dash_knockback_force)
			#
	#


func _regular_movement(delta):
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


# Pressing space bar changes the build to the one below. Wrap around to top if at bottom
func _handle_shift_pressed():
	cur_build_selection += 1
	if cur_build_selection >= Placeable.placeables.size():
		cur_build_selection = 0
	build_selection_changed.emit(cur_build_selection)
	
	
func _handle_left_mouse_click():
	if cur_mode == mode.ATTACK:
		shoot()
	elif cur_mode == mode.BUILD:
		build()
	elif cur_mode == mode.DELETE:
		delete()


func _handle_right_mouse_click():
	# Right click only used for attacking
	if cur_mode == mode.ATTACK:
		$Head.start_attack()

# Pressing the shift triggers a dash if player is not currently already
# dashing and they are able to dash (enough stamina and dash cooldown done),
# and they are moving.
func _handle_space_bar_pressed():
	if dashing:
		return 
	if (not dashing and $DashCoolDownTimer.is_stopped() and 
			cur_stamina >= dash_stamina_use and velocity.length() > 0):
		direction = velocity.normalized()
		
		# Reduce the amount of stamina a player has and sends signal to HUD
		cur_stamina -= dash_stamina_use
		stamina_changed.emit(cur_stamina)
		#checks stamina and sets a timer for the stamina regeneration.
		stamina_check()
		
		# Begin dash in direction player is moving (not where mouse is pointing)
		dashing = true
		dash_sound.play()
		cur_dash_distance = 0 
		velocity = direction * dash_speed 
		$DashCoolDownTimer.start()


# Method for recieving damage
func hit(amount,knockback=Vector2.ZERO,force=0):
	cur_health -= amount
	health_changed.emit(cur_health)
	if (cur_health <= 0):
		player_death.emit()
		return
	velocity += (knockback * accel * force * get_physics_process_delta_time())
	move_and_slide()
	
func heal(amount):
	if(amount + cur_health > max_health):
		cur_health = max_health
	else:
		cur_health += amount
	health_changed.emit(cur_health)

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
		shoot_sound.play()
		bullet.fire()


func build():
	build_requested.emit(get_global_mouse_position(), cur_build_selection)


func delete():
	delete_requested.emit(get_global_mouse_position())
	

func stamina_check():
	if(cur_stamina <= 0):
			cur_stamina = 0
	$StaminaTimer.start()

func _on_stamina_timer_timeout():
	if cur_stamina < max_stamina:
		cur_stamina += floor(max_stamina * stamina_percentage_regen)
	elif cur_stamina > max_stamina:
		cur_stamina = max_stamina
	stamina_changed.emit(cur_stamina)

func increase_max_health(amount):
	max_health += amount
	cur_health += amount
	max_health_changed.emit(max_health)
	health_changed.emit(cur_health)

func increase_max_stamina(amount):
	max_stamina += amount
	cur_stamina += amount
	max_stamina_changed.emit(max_stamina)
	stamina_changed.emit(cur_stamina)

func increase_damage(amount):
	$Head.increase_melee_damage(amount)
	bullet_damage += amount
	
