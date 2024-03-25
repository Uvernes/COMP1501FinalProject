extends CanvasLayer

var player


func _ready():
	player = get_parent().get_node("Player")
	#$HScrollBar.set_focus()

# Cannot initialize HUD until player is initialized (otherwise undefined values)
func _on_player_ready():
	# Initialize Health bar
	$HealthBar.max_value = player.max_health
	$HealthBar.value = player.cur_health
	# Initialize Stamina bar
	$StaminaBar.max_value = player.max_stamina
	$StaminaBar.value = player.cur_stamina
	# Init hotbar
	_on_player_mode_changed(player.cur_mode)

func _on_player_health_changed(new_health):
	$HealthBar.value = new_health


func _on_player_stamina_changed(new_stamina):
	$StaminaBar.value = new_stamina

# Update the player mode hotbar
# NOTE: The GUI must be kept in sync with player's modes 
func _on_player_mode_changed(new_mode):
	# Hide background fot all hotbar items
	var hotBarItems = $HotBar/Children.get_children()
	for hotBarItem in hotBarItems:
		hotBarItem.get_node("Background").hide()
	# Add background for the selected mode
	hotBarItems[new_mode].get_node("Background").show()

func update_resource(type, new_amount):
	if type == "dirt":
		$ResourceDisplay/Dirt/Label.text = "Dirt: " + str(new_amount)
	elif type == "stone":
		$ResourceDisplay/Stone/Label.text = "Stone: " + str(new_amount)
	elif type == "leaves":
		$ResourceDisplay/Leaves/Label.text = "Leaves: " + str(new_amount)
	elif type == "wood":
		$ResourceDisplay/Wood/Label.text = "Wood: " + str(new_amount)
	elif type == "mobdrop":
		$ResourceDisplay/Mobdrops/Label.text = "Mobdrops: " + str(new_amount)
