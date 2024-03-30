extends Area2D

const attack_speed = Vector2(100, 0)
var melee_damage
var attacking
var head_retracting
var already_hit
var overlapping_bodies

func _ready():
	attacking = false
	head_retracting = false
	melee_damage = 1
	already_hit = []

func _physics_process(delta):
	if  attacking == true:
		position += attack_speed * delta
	elif head_retracting == true:
		position -= attack_speed * delta
	
	overlapping_bodies = get_overlapping_bodies()
	for i in overlapping_bodies.size():
		handle_overlap(overlapping_bodies[i])

func start_attack():
	if attacking != true && head_retracting != true:
		attacking = true
		$AttackTimer.start()

func _on_attack_timer_timeout():
	if attacking == true:
		attacking = false
		head_retracting = true
		$AttackTimer.start()
	elif head_retracting == true:
		head_retracting = false
		already_hit.clear()
		
func handle_overlap(body):
	if attacking == true:
		if body != null:
			if body.is_in_group("Enemy") && already_hit.find(body) == -1:
				already_hit.append(body)
				body.take_damage(melee_damage)

func increase_melee_damage(amount):
	melee_damage += amount

