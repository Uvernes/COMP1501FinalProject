extends Area2D

signal player_on_home_base()
signal player_off_home_base()
signal population_zero()
signal population_changed()

var current_pop
var max_pop

# Called when the node enters the scene tree for the first time.
func _ready():
	current_pop = 100
	max_pop = 100
	position = Vector2(0,0)

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
		population_zero.emit()
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
			player_on_home_base.emit()


func _on_body_exited(body):
	if body != null:
		if body.name == "Player":
			player_off_home_base.emit()


func _on_area_entered(area):
	if area != null:
		if area.is_in_group("EnemyHeads"):
			area.get_parent().attack_base()

func _on_area_exited(area):
	if area != null:
		if area.is_in_group("EnemyHeads"):
			area.get_parent().stop_attacking_base()


func _on_attack_message_cooldown_timeout():
	#send message that base has not been attacked recently to wherever needed
	pass
