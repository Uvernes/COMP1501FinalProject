extends CharacterBody2D


const speed = 300.0
#const decrease_speed_factor = 10



func _physics_process(delta):
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
