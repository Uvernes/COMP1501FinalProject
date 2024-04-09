extends Area2D

const attack_speed = Vector2(100, 0)
var melee_damage
var attacking
var head_retracting
var already_hit
var overlapping_bodies
var knock_back_force = 16

func _ready():
	attacking = false
	head_retracting = false
	melee_damage = 1
	already_hit = []

func _physics_process(delta):
	if  attacking == true:
		position += attack_speed * delta
		if position >= Vector2(38,0):
			position = Vector2(38,0)
			head_retracting = true
			attacking = false
	elif head_retracting == true:
		position -= attack_speed * delta
		if position <= Vector2(18,0):
			position = Vector2(18,0)
			head_retracting = false
			already_hit.clear()
	overlapping_bodies = get_overlapping_bodies()
	for i in overlapping_bodies.size():
		handle_overlap(overlapping_bodies[i])

func start_attack():
	if attacking != true && head_retracting != true:
		attacking = true
		
func handle_overlap(body):
	if attacking == true:
		if body != null:
			if body.is_in_group("Enemy") && already_hit.find(body) == -1:
				already_hit.append(body)
				var facing = (body.position - get_parent().position).normalized()
				body.take_damage(melee_damage,get_parent(),facing,knock_back_force)

func increase_melee_damage(amount):
	melee_damage += amount

