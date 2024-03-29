extends Area2D

const attack_speed = Vector2(100, 0)
var melee_damage
var damage_to_base
var attacking
var head_retracting
var hit_something
var overlapping_bodies
var overlapping_areas

func _ready():
	attacking = false
	head_retracting = false
	melee_damage = 1
	damage_to_base = 1
	hit_something = false

func _physics_process(delta):
	if  attacking == true:
		position += attack_speed * delta
	elif head_retracting == true:
		position -= attack_speed * delta
	overlapping_bodies = get_overlapping_bodies()
	for i in overlapping_bodies.size():
		handle_overlapping_bodies(overlapping_bodies[i])
	overlapping_areas = get_overlapping_areas()
	for i in overlapping_areas.size():
		handle_overlapping_areas(overlapping_areas[i])
	

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
		hit_something = false
		
func handle_overlapping_bodies(body):
	if attacking == true:
		if body != null:
			if body.name == "Player" && hit_something == false:
				hit_something = true
				body.hit(melee_damage)

func handle_overlapping_areas(area):
	if attacking == true:
		if area != null:
			if area.name == "HomeBase" && hit_something == false:
				hit_something = true
				area.get_attacked(damage_to_base)
