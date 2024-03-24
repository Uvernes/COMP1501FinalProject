extends CharacterBody2D

const attack_speed = 4000
var direction = Vector2.ZERO
var melee_damage
var attacking
var head_retracting

func _ready():
	attacking = false
	head_retracting = false
	melee_damage = 1

func _physics_process(delta):
	if  attacking == true:
		do_attack(delta)
	elif head_retracting == true:
		do_head_retract(delta)


func do_attack(delta):
	direction =  get_global_mouse_position() - get_parent().get_global_position()
	direction = direction.normalized()
	
	velocity = (direction * attack_speed * delta)

		
	move_and_slide()
	
func do_head_retract(delta):
	direction = get_parent().get_global_position() - global_position
	direction = direction.normalized()
	
	velocity = (direction * attack_speed * delta)
	
	move_and_slide()
	

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
		
func get_melee_damage():
	return melee_damage
