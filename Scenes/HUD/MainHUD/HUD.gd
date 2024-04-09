extends CanvasLayer

signal health_button_pressed()
signal stamina_button_pressed()
signal dmg_button_pressed()

var player
var game_map
var base
var can_open_upgrade_menu
var can_build_base
var upgrade_menu_open
var wave_num = 1
var max_waves

@onready var mode_change_sound = $Mode_change
@onready var build_change_sound = $Build_change
@onready var resource_collect_sound = $Resource_collect

func _ready():
	$UpgradeMenu.hide()
	$PopulationBar.hide()
	$Warning.hide()
	$BuildSidebar.hide()
	player = get_parent().get_node("Player")
	game_map = get_parent().get_node("GameMap")
	can_open_upgrade_menu = false
	can_build_base = false
	upgrade_menu_open = false

func _process(_delta):
	if $PopulationBar.is_visible():
		$PopulationBar/WaveInfo.text = "Wave " + str(wave_num) + ": " + str(snapped($PopulationBar/WaveTimer.time_left, 0.01))

func room_changed(base):
	$PopulationBar.hide()
	$Warning.hide()
	if base != null:
		base.connect("player_on_base", update_current_base.bind(base, true))
		base.connect("player_off_base", update_current_base.bind(base,false))
		base.connect("population_changed", base_population_changed)
		base.connect("status_changed", base_status_changed)

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


# Init HUD progress display using the initialized values of the game map
func _on_game_map_ready():
	update_rooms_visited()
	update_bases_captured()

func _on_player_health_changed(new_health):
	$HealthBar.value = new_health

func _on_player_stamina_changed(new_stamina):
	$StaminaBar.value = new_stamina
	
func _on_player_max_stamina_changed(new_max):
	$StaminaBar.max_value = new_max
	
func _on_player_max_health_changed(new_max):
	$HealthBar.max_value = new_max

# Update the player mode hotbar
# NOTE: The GUI must be kept in sync with player's modes 
func _on_player_mode_changed(new_mode):
	#print("Player mode!")
	# Hide background for all hotbar items
	var hotBarItems = $HotBar/Children.get_children()
	for hotBarItem in hotBarItems:
		hotBarItem.get_node("Background").hide()
	# Add background for the selected mode
	hotBarItems[new_mode].get_node("Background").show()
	mode_change_sound.play()
	
	
	#shows build sidebar or starts hide timer
	if new_mode == player.mode.BUILD:
		$BuildSidebar.show()
		$HideBuildSidebarTimer.stop()
	else:
		$HideBuildSidebarTimer.start()

func _on_player_build_selection_changed(new_build_selection):
	# Hide background for all sidebar items
	var buildSiderbar = $BuildSidebar/Children.get_children()
	for buildItem in buildSiderbar:
		buildItem.get_node("Background").hide()
	# Add background for the selected mode
	buildSiderbar[new_build_selection].get_node("Background").show()
	build_change_sound.play()

func _on_hide_build_sidebar_timer_timeout():
	$BuildSidebar.hide()

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
	resource_collect_sound.play()


func update_all_resources(resource_amounts: Dictionary):
	$ResourceDisplay/Dirt/Label.text = "Dirt: " + str(resource_amounts["dirt"])
	$ResourceDisplay/Stone/Label.text = "Stone: " + str(resource_amounts["stone"])
	$ResourceDisplay/Leaves/Label.text = "Leaves: " + str(resource_amounts["leaves"])
	$ResourceDisplay/Wood/Label.text = "Wood: " + str(resource_amounts["wood"])
	$ResourceDisplay/Mobdrops/Label.text = "Mobdrops: " + str(resource_amounts["mobdrops"])


func update_rooms_visited():
	$ProgressDisplay/RoomsVisited/TextLabel.text = "Rooms Visited: " +\
		str(game_map.get_num_rooms_visited()) + "/" + str(game_map.total_rooms())


func update_bases_captured():
	$ProgressDisplay/BasesCaptured/TextLabel.text = "Bases Captured: " +\
		str(game_map.get_num_bases_captured()) + "/" + str(game_map.total_bases())


#updates if the upgrade menu can be opened
func update_upgrade_menu_open(state):
	can_open_upgrade_menu = state
	if state == false:
		show_upgrade_menu(false)

func _input(ev):
	if Input.is_action_pressed("interact"):
		if can_open_upgrade_menu == true:
			if upgrade_menu_open == true:
				show_upgrade_menu(false)
			else:
				show_upgrade_menu(true)

#received when player moves on/off base
func update_current_base(base, state):
	if base.safe == true:
		update_upgrade_menu_open(state)

func base_status_changed(type):
	if type == "safe":
		can_open_upgrade_menu = true
		$PopulationBar.hide()
		$PopulationBar/WaveTimer.stop()
		$PopulationBar/WaveTimer.wait_time = 20
		wave_num = 1
	if type == "under attack":
		$PopulationBar.show()
		$PopulationBar/WaveTimer.start()
		max_waves = (2 * game_map.get_num_bases_captured() + 3)
	if type == "inactive":
		can_open_upgrade_menu = false
		$PopulationBar.hide()
		wave_num = 1

#shows/hides upgrade menu
func show_upgrade_menu(state):
	if state == true:
		$UpgradeMenu.show()
		upgrade_menu_open = true
	else:
		$UpgradeMenu.hide()
		upgrade_menu_open = false


#buttons send signals to game controller
func _on_health_button_pressed():
	health_button_pressed.emit()

func _on_stamina_button_pressed():
	stamina_button_pressed.emit()

func _on_dmg_button_pressed():
	dmg_button_pressed.emit()

#received from base
func base_population_changed(new_population):
	$PopulationBar.value = new_population

#called by game controller
func show_warning(state):
	if state == true:
		$Warning.show()
	else:
		$Warning.hide()

func _on_wave_timer_timeout():
	print("HUD trigger")
	print(wave_num)
	print(max_waves)
	if wave_num <= max_waves && $PopulationBar.is_visible():
		wave_num += 1
		$PopulationBar/WaveTimer.start()
	else:
		game_map.cur_room.get_node("Base").status_changed.emit("safe")
