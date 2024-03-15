extends CharacterBody2D


const speed = 300
#const decrease_speed_factor = 10

const max_bullet_count = 3
# make a scene to be used for Bullet creation
@export var bullet_scene: PackedScene

func _ready():
	position = Vector2(0,0)

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
		# use Bullet Storage node to check how many bullets currently exist
		if $Bullet_Storage.get_child_count() < max_bullet_count:
			# if we haven't reached max bullet count, create new bullet for player
			var bullet = bullet_scene.instantiate()
			# make bullet appear on player
			bullet.position = position
			# make bullet rotate to mouse pointer (NEXT 2 lines are strangely failed attempts)
			bullet.rotation = rotation # comment this out and use next line if player doesnt follow mouse
			#bullet.look_at(get_global_mouse_position())
			# we create a direction vector to move appropriately
			bullet.direction = (get_global_mouse_position() - position).normalized()
			# allow bullet to move
			bullet.moving = true
			# add bullet as a child to keep track of its existence
			$Bullet_Storage.add_child(bullet)
