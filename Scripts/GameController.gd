"""
Game controller script. Highest level for orchestrating the game logic.
Recieves signals and delegates tasks accordingly.
Some tasks include: 
-Population (handled here)
-Resource management (delegated)

The controller should also manage the calls to updating the UI.
"""

extends Node2D


const respawn_price = 10

var player
var homebase

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node("Player")
	homebase = get_node("HomeBase")
	player.connect("player_death", handle_player_death)
	homebase.connect("population_zero", handle_homebase_death)
	$HUD.connect("health_button_pressed", handle_upgrade.bind(0))
	$HUD.connect("stamina_button_pressed", handle_upgrade.bind(1))
	$HUD.connect("melee_dmg_button_pressed", handle_upgrade.bind(2))

# Handle player build request and delegate accordingly
func _on_player_build_requested(global_mouse_pos, build_id):
	# Check if can build at area using tilemap controller
	if not $WorldMap.can_place_build(global_mouse_pos, build_id):
		return
	
	# Attempt purchase
	var build_instance = $ResourceManager.attempt_build_purchase(build_id)
	# Case where not enough resources to build. Just return
	if build_instance == null:
		return
	# Pass build to tilemap controller so it places it
	# $WorldMap.place_build(global_mouse_pos, build_instance)
	$WorldMap.place_build_at_hover_tile(build_instance)
	# Update resources HUD
	$HUD.update_all_resources($ResourceManager.resources)

# Handle player delete request and delegate accordingly
func _on_player_delete_requested(global_mouse_pos):
	# Remove build from the world at the tile the mouse is hovering over 
	var build_instance = $WorldMap.get_build_at_hover_tile()
	# If nothing to delete, return
	if build_instance == null:
		return
	# Get some resources returned back from delete
	$ResourceManager.return_resources_from_delete(build_instance)
	# Update resource HUD
	$HUD.update_all_resources($ResourceManager.resources)

	# Delete build
	build_instance.queue_free()
	
func handle_player_death():
	if homebase.current_pop > respawn_price:
		get_tree().call_group("Enemy", "queue_free") #for now, all enemies are deleted upon death
		homebase.decrease_pop(respawn_price)
		player.respawn()
	else:
		#game over
		print("Player died and could not respawn: Game Over")
		get_tree().change_scene_to_file("res://Scenes/Menus/MainMenu/MainMenu.tscn")


func handle_homebase_death():
	#game over
	print("Population reached zero: Game Over")
	get_tree().change_scene_to_file("res://Scenes/Menus/MainMenu/MainMenu.tscn")

func handle_upgrade(type):
	if $ResourceManager.check_upgrade_cost(10) == true:
		if type == 0:
			player.increase_max_health(2)
		elif type == 1:
			player.increase_max_stamina(2)
		elif type == 2:
			player.increase_melee_damage(1)
		$HUD.update_all_resources($ResourceManager.resources)
