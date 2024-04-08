extends Area2D

signal player_on_base()
signal player_off_base()
signal population_changed(new_pop)
signal status_changed(type)#types: "under attack", "inactive", "safe"
signal fully_heal_player()
signal attempt_claim()

var current_pop
var max_pop
var active
var safe
var player_at_base

var sprite_node = "NestSprite"

# Called when the node enters the scene tree for the first time.
func _ready():
	position = Vector2.ZERO
	current_pop = 0
	max_pop = 100
	active = false
	safe = false
	$ActivateBasePopUp.hide()
	$ActivateBasePopUp.position = Vector2(-70,-90)
	player_at_base = false
	$Light.hide()
	var sprite = get_node(sprite_node)
	sprite.texture = preload("res://Assets/Buildings/HomeBases/emptybase2.png")

func update_sprite_based_on_population():
	var sprite = get_node(sprite_node)
	if current_pop > 65:
		sprite.texture = preload("res://Assets/Buildings/HomeBases/anthomebase.png")
	elif current_pop > 40:
		sprite.texture = preload("res://Assets/Buildings/HomeBases/anthomebase3.png")
	elif current_pop > 0:
		sprite.texture = preload("res://Assets/Buildings/HomeBases/anthomebase6.png")
	else:
		sprite.texture = preload("res://Assets/Buildings/HomeBases/emptybase2.png")

func get_attacked(amount):
	decrease_pop(amount)

	if $AttackMessageCooldown.time_left == 0:
		#send message that base is being attacked to wherever needed
		$AttackMessageCooldown.start()
	
func decrease_pop(amount):
	current_pop -= amount
	population_changed.emit(current_pop)
	update_sprite_based_on_population()
	if current_pop <= 0:
		current_pop = 0
		status_changed.emit("inactive")
		changeActiveStatus(false)
	elif $RegenTimer.time_left == 0:
		$RegenTimer.start()

func increase_pop(amount):
	current_pop += amount
	population_changed.emit(current_pop)
	update_sprite_based_on_population()
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
			player_at_base = true
			if active == false:
				$ActivateBasePopUp.show()
			if safe == true:
				fully_heal_player.emit()#sent to game controller

func _on_body_exited(body):
	if body != null:
		if body.name == "Player":
			player_off_base.emit()
			player_at_base = false
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
		$Light.show()
		active = true
		increase_pop(100)
		$RegenTimer.start()
	elif status == false:
		active = false
		$Light.hide()
		
		stopAllEnemyAttacks()

func becomeSafe(): #can be called when re-entering a room with a claimed base
	active = true
	safe = true
	status_changed.emit("safe")#use to stop mob spawns, and update HUD

func _input(ev):
	if player_at_base && Input.is_action_pressed("interact"):
		if active == false:
			attempt_claim.emit()#checks for ressources

#called by game controller
func build():
	changeActiveStatus(true)
	status_changed.emit("under attack")#use to start enemy wave, and update HUD

func stopAllEnemyAttacks():
	var overlapping_areas = get_overlapping_areas()
	for i in overlapping_areas.size():
		if overlapping_areas[i] != null:
			if overlapping_areas[i].is_in_group("EnemyHeads"):
				overlapping_areas[i].get_parent().stop_attacking_base()
