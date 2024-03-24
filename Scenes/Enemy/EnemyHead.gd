extends CharacterBody2D

const attack_speed = 6000
var direction = Vector2.ZERO
var melee_damage
var attacking
var head_retracting
var player
var hit_player

func _ready():
	player = get_parent().get_parent().get_node("Player")
	attacking = false
	head_retracting = false
	melee_damage = 1
	hit_player = false

func _physics_process(delta):
	if  attacking == true:
		do_attack(delta)
	elif head_retracting == true:
		do_head_retract(delta)


func do_attack(delta):
	direction =  player.position - get_parent().get_global_position()
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
		hit_player = false
		attacking = true
		$AttackDurationTimer.start()

func _on_attack_duration_timer_timeout():
	if attacking == true:
		attacking = false
		head_retracting = true
		$AttackDurationTimer.start()
	elif head_retracting == true:
		head_retracting = false
		
func get_melee_damage():
	if attacking == true && hit_player == false:
		return melee_damage
	return 0
	
func update_hit_player():
	hit_player = true
	
