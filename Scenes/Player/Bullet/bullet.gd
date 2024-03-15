extends CharacterBody2D

# note: To detect Bullets, enable Mask 2 in Collision Property

# explicitely mentioned variable types for modifications done outside this script
# moving flag used to know when bullet is active
var moving: bool = false
# value to keep track of which direction the bullet should face
var direction: Vector2

""" -lifespan used to keep track of when to make the bullet de-spawn/disappear
-treating lifespan as distance that diminishes (to compare to enemy engage radius)"""
var bullet_lifespan = 280

# bullet damage accessed in enemy collision (area_entered)
var damage = 1
var bullet_speed = 450 # made these vars instead of consts for future upgrade opportunities


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if moving:
		if bullet_lifespan<=0:
			# delete bullet when lifespan diminished
			queue_free()
		# keep track of how much position changes to change lifespan accordingly
		var pos_increase = direction * bullet_speed * delta
		# move bullet
		position += pos_increase
		move_and_slide() # change this line to change behavior for bullets vs. walls
		# decrease lifespan
		bullet_lifespan -= pos_increase.length() 
		
