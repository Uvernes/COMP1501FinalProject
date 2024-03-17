extends CanvasLayer

var player


func _ready():
	player = get_parent().get_node("Player")


# Cannot initialize HUD until player is initialized (otherwise undefined values)
func _on_player_ready():
	# Initialize Health bar
	$Control/Health.max_value = player.max_health
	$Control/Health.value = player.cur_health

	
func _on_player_health_changed(new_health):
	$Control/Health.value = new_health

