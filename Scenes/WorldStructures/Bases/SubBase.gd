extends Area2D

signal player_on_sub_base()
signal player_off_sub_base()
signal base_destroyed()

var current_pop
var max_pop
var active


# Called when the node enters the scene tree for the first time.
func _ready():
	current_pop = 0
	max_pop = 20
	active = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_attacked(amount):
	decrease_pop(amount)

	if $AttackMessageCooldown.time_left == 0:
		#send message that base is being attacked to wherever needed
		$AttackMessageCooldown.start()
	
func decrease_pop(amount):
	current_pop -= amount
	if current_pop <= 0:
		current_pop = 0
		base_destroyed.emit() #currently not received anywhere
		changeActiveStatus(false)
	elif $RegenTimer.time_left == 0:
		$RegenTimer.start()

func increase_pop(amount):
	current_pop += amount
	if current_pop > max_pop:
		current_pop = max_pop

func _on_regen_timer_timeout():
	increase_pop(1)
	if current_pop != max_pop:
		$RegenTimer.start()
	

func _on_body_entered(body):
	if body != null:
		if body.name == "Player":
			player_on_sub_base.emit()


func _on_body_exited(body):
	if body != null:
		if body.name == "Player":
			player_off_sub_base.emit()


func _on_area_entered(area):
	if area != null:
		if active == true:
			if area.is_in_group("EnemyHeads"):
				area.get_parent().attack_base()

func _on_area_exited(area):
	if area != null:
		if active == true:
			if area.is_in_group("EnemyHeads"):
				area.get_parent().stop_attacking_base()


func _on_attack_message_cooldown_timeout():
	#send message that base has not been attacked recently to wherever needed
	pass

func changeActiveStatus(status):
	if status == true:
		active = true
		increase_pop(5)
		$RegenTimer.start()
	elif status == false:
		active = false
		stopAllEnemyAttacks()
		
func stopAllEnemyAttacks():
	var overlapping_areas = get_overlapping_areas()
	for i in overlapping_areas.size():
		if overlapping_areas[i] != null:
			if overlapping_areas[i].is_in_group("EnemyHeads"):
				overlapping_areas[i].get_parent().stop_attacking_base()
