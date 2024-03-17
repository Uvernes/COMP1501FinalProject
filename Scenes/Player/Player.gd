extends CharacterBody2D


signal health_changed(new_health: int)

# Stats - can be upgraded over time
var max_health = 10
var speed = 300
var bullet_speed = 600
var bullet_damage = 1

# Current values
var cur_health

#const decrease_speed_factor = 10

const max_bullet_count = 3
# make a scene to be used for Bullet creation
@export var bullet_scene: PackedScene
const Bullet = preload("res://Scenes/Player/Bullet/bullet.gd"); # For type annotation

func _ready():
	position = Vector2(0,0)
	cur_health = max_health

#func _process(_delta):
	 # .set_rot(get_angle_to(...))

func _physics_process(_delta):
	look_at(get_global_mouse_position())
	velocity = Vector2.ZERO
	#if velocity.length() > 10:
		#velocity = velocity / decrease_speed_factor
	
	#else:
	#	velocity = Vector2.ZERO
	#print(velocity)
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		#$AnimatedSprite2D.play()
	#else:
		#$AnimatedSprite2D.stop()

	move_and_slide()
	
	# handle player attack (ranged)
	# check if player left clicked
	if Input.is_action_just_pressed("attack"):
		shoot()

# Method for recieving damage
func hit(amount):
	cur_health -= amount
	health_changed.emit(cur_health)
	if (cur_health <= 0):
		# TODO - send out player_death signal. Game controller should handle death
		get_tree().quit()
		
func shoot():
	# use Bullet Storage node to check how many bullets currently exist
	if $Bullet_Storage.get_child_count() < max_bullet_count:
		# if we haven't reached max bullet count, create new bullet for player
		var bullet: Bullet = bullet_scene.instantiate()
		# add bullet as a child to keep track of its existence
		$Bullet_Storage.add_child(bullet)
		
		# make bullet rotate to mouse pointer (NEXT 2 lines are strangely failed attempts)
		#bullet.rotation = rotation # comment this out and use next line if player doesnt follow mouse
		#bullet.look_at(get_global_mouse_position())

		# we create a direction vector to move appropriately. It is the direction of the mouse pointer from the player
		var bullet_direction = (get_global_mouse_position() - position).normalized()
		bullet.init(position, rotation, bullet_speed, bullet_direction, bullet_damage)
		bullet.fire()
