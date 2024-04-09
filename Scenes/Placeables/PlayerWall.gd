extends "res://Scenes/Placeables/Placeable.gd"

var health = 3
var enemies_in_range = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	build_id = placeables.PLAYER_WALL

func _on_breaking_interval_timeout():
	if enemies_in_range > 0:
		take_damage()
	else:
		$BreakingInterval.start()

func take_damage():
	health -= 1
	
	$Sprite2D.set_modulate(Color(1, 0, 0, 1))
	await get_tree().create_timer(0.2).timeout
	$Sprite2D.set_modulate(Color(0.5451, 0.5451, 0.5451, 1))
	
	if health <= 0:
		queue_free()
	
	$BreakingInterval.start()

func _on_area_2d_area_entered(area):
	if area.is_in_group("EnemyHeads"):
		enemies_in_range += 1

func _on_area_2d_area_exited(area):
	if area.is_in_group("EnemyHeads"):
		enemies_in_range -= 1
