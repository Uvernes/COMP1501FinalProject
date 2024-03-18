"""
Bullet class. Bullets are responsible for detecting collisions with other 
objects.

Note: To detect Bullets, enable Mask 2 in Collision Property
"""
extends CharacterBody2D

var speed: int
var direction: Vector2 # Direction bullet should face
var damage: int  # Different player / enemies will have dif. damage
var moving: bool = false # moving flag used to know when bullet is active

# -lifespan used to keep track of when to make the bullet de-spawn/disappear
# -treating lifespan as distance that diminishes (to compare to enemy engage radius)
var bullet_lifespan = 280

func init(position, rotation, speed, direction, damage, bullet_lifespan=bullet_lifespan):
	self.position = position
	self.rotation = rotation
	self.speed = speed
	self.direction = direction # Direction bullet will move in same as its rotation
	self.damage = damage
	self.bullet_lifespan = bullet_lifespan
	
func fire():
	moving = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if moving:
		if bullet_lifespan<=0:
			# delete bullet when lifespan diminished
			queue_free()
			
		# keep track of how much position changes to change lifespan accordingly
		var pos_change = direction * speed * delta
		
		# move bullet
		position += pos_change
		move_and_slide() # change this line to change behavior for bullets vs. walls
		
		# Handle collisions
		# Using move_and_slide.
		for i in get_slide_collision_count():
			handle_collision(get_slide_collision(i))
				
		# decrease lifespan
		bullet_lifespan -= pos_change.length()
		
func handle_collision(collision: KinematicCollision2D):
	var collider = collision.get_collider()
	print("Hit!")
	if collider.is_in_group("Enemy"):
		collider.hit(damage)
		queue_free()
		

		
		
		
