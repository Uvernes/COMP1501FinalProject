extends Area2D

signal player_on_base()
signal player_off_base()
signal population_changed(new_pop)
signal status_changed(type)#types: "under attack", "inactive", "safe"

var current_pop
var max_pop
var active
var safe


# Called when the node enters the scene tree for the first time.
func _ready():
	position = Vector2.ZERO
	current_pop = 0
	max_pop = 100
	active = false
	safe = false
	$ActivateBasePopUp.hide()
	$ActivateBasePopUp.position = Vector2(-70,-90)


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
	population_changed.emit(current_pop)
	if current_pop <= 0:
		current_pop = 0
		status_changed.emit("inactive")
		changeActiveStatus(false)
	elif $RegenTimer.time_left == 0:
		$RegenTimer.start()

func increase_pop(amount):
	current_pop += amount
	population_changed.emit(current_pop)
	if current_pop > max_pop:
		current_pop = max_pop

func _on_regen_timer_timeout():
	increase_pop(1)
	if current_pop != max_pop:
		$RegenTimer.start()
	

func _on_body_entered(body):
	if body != null:
		if body.name == "Player":
			player_on_base.emit()
			if active == false:
				$ActivateBasePopUp.show()


func _on_body_exited(body):
	if body != null:
		if body.name == "Player":
			player_off_base.emit()
			$ActivateBasePopUp.hide()


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
		$ActivateBasePopUp.hide()
		active = true
		increase_pop(100)
		$RegenTimer.start()
	elif status == false:
		active = false
		
		stopAllEnemyAttacks()

func becomeSafe():
	safe = true
	status_changed.emit("safe")#use to stop mob spawns, and update HUD

func _input(ev):
	if Input.is_action_pressed("interact"):
		if active == false:
			#check for ressources
			changeActiveStatus(true)
			status_changed.emit("under attack")#use to start enemy wave, and update HUD
			
		
func stopAllEnemyAttacks():
	var overlapping_areas = get_overlapping_areas()
	for i in overlapping_areas.size():
		if overlapping_areas[i] != null:
			if overlapping_areas[i].is_in_group("EnemyHeads"):
				overlapping_areas[i].get_parent().stop_attacking_base()
