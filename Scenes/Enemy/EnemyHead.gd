extends Area2D

const attack_speed = Vector2(100, 0)
var melee_damage
var attacking
var head_retracting
var hit_player
var overlapping_bodies

func _ready():
	attacking = false
	head_retracting = false
	melee_damage = 1
	hit_player = false

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
		$AttackDurationTimer.start()

func _on_attack_duration_timer_timeout():
	if attacking == true:
		attacking = false
		head_retracting = true
		$AttackDurationTimer.start()
	elif head_retracting == true:
		head_retracting = false
		hit_player = false
		
func handle_overlap(body):
	if attacking == true:
		if body != null:
			if body.name == "Player" && hit_player == false:
				hit_player = true
				body.hit(melee_damage)
