extends Area2D

signal player_on_home_base()
signal player_off_home_base()
signal population_zero()

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
	
func decrease_pop(amount):
	current_pop -= amount
	if current_pop <= 0:
		current_pop = 0
		population_zero.emit()

func increase_pop(amount):
	current_pop += amount
	if current_pop > max_pop:
		current_pop = max_pop

func _on_regen_timer_timeout():
	increase_pop(1)
	

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
