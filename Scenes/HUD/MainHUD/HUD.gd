extends CanvasLayer

var player
var homebase
var can_open_upgrade_menu
var can_build_base

var currentSubBase
var subBases


func _ready():
	player = get_parent().get_node("Player")
	homebase = get_parent().get_node("HomeBase")
	can_open_upgrade_menu = false
	can_build_base = false
	subBases = []
	currentSubBase = null
	homebase.connect("player_on_home_base", update_upgrade_menu_open.bind(true))
	homebase.connect("player_off_home_base", update_upgrade_menu_open.bind(false))
	
	#repeat for each sub base (change name):
	#subBases.append(get_parent().get_node("SubBase"))
	
	for i in subBases.size():
		subBases[i].connect("player_on_sub_base", update_current_subBase.bind(subBases[i], true))
		subBases[i].connect("player_off_sub_base", update_current_subBase.bind(subBases[i], false))
	
	
	
	#$HScrollBar.set_focus()

# Cannot initialize HUD until player is initialized (otherwise undefined values)
func _on_player_ready():
	# Initialize Health bar
	$HealthBar.max_value = player.max_health
	$HealthBar.value = player.cur_health
	# Initialize Stamina bar
	$StaminaBar.max_value = player.max_stamina
	$StaminaBar.value = player.cur_stamina
	# Initial render for everything
	_on_player_mode_changed(player.cur_mode)
	_on_player_build_selection_changed(player.cur_build_selection)
	update_all_resources(get_parent().get_node("ResourceManager").resources)

func _on_player_health_changed(new_health):
	$HealthBar.value = new_health


func _on_player_stamina_changed(new_stamina):
	$StaminaBar.value = new_stamina

# Update the player mode hotbar
# NOTE: The GUI must be kept in sync with player's modes 
func _on_player_mode_changed(new_mode):
	# Hide background for all hotbar items
	var hotBarItems = $HotBar/Children.get_children()
	for hotBarItem in hotBarItems:
		hotBarItem.get_node("Background").hide()
	# Add background for the selected mode
	hotBarItems[new_mode].get_node("Background").show()
	

func _on_player_build_selection_changed(new_build_selection):
	# Hide background for all sidebar items
	var buildSiderbar = $BuildSidebar/Children.get_children()
	for buildItem in buildSiderbar:
		buildItem.get_node("Background").hide()
	# Add background for the selected mode
	buildSiderbar[new_build_selection].get_node("Background").show()


func update_resource(type, new_amount):
	if type == "dirt":
		$ResourceDisplay/Dirt/Label.text = "Dirt: " + str(new_amount)
	elif type == "stone":
		$ResourceDisplay/Stone/Label.text = "Stone: " + str(new_amount)
	elif type == "leaves":
		$ResourceDisplay/Leaves/Label.text = "Leaves: " + str(new_amount)
	elif type == "wood":
		$ResourceDisplay/Wood/Label.text = "Wood: " + str(new_amount)
	elif type == "mobdrops":
		$ResourceDisplay/Mobdrops/Label.text = "Mobdrops: " + str(new_amount)


func update_all_resources(resource_amounts: Dictionary):
	$ResourceDisplay/Dirt/Label.text = "Dirt: " + str(resource_amounts["dirt"])
	$ResourceDisplay/Stone/Label.text = "Stone: " + str(resource_amounts["stone"])
	$ResourceDisplay/Leaves/Label.text = "Leaves: " + str(resource_amounts["leaves"])
	$ResourceDisplay/Wood/Label.text = "Wood: " + str(resource_amounts["wood"])
	$ResourceDisplay/Mobdrops/Label.text = "Mobdrops: " + str(resource_amounts["mobdrops"])

func update_upgrade_menu_open(state):
	can_open_upgrade_menu = state

func _input(ev):
	if Input.is_action_pressed("interact"):
		if can_open_upgrade_menu == true:
			pass
			#open or close upgrade menu here
		elif can_build_base == true:
			print(currentSubBase)
			if currentSubBase != null:
				#check for ressources, build base if possible
				currentSubBase.changeActiveStatus(true)
				update_build_base_option(false)
				update_upgrade_menu_open(true)
			

func update_current_subBase(base, state):
	if base.active == true:
		update_upgrade_menu_open(state)
	else:
		update_build_base_option(state)
	if state == true:
		currentSubBase = base
	else:
		currentSubBase = null

func update_build_base_option(state):
	can_build_base = state
	if state == true:
		pass
		#show build base pop up
	else:
		pass
		#hide build base pop up
