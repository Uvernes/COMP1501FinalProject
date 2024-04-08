"""
Game controller script. Highest level for orchestrating the game logic.
Recieves signals and delegates tasks accordingly.
Some tasks include: 
-Population (handled here)
-Resource management (delegated)

The controller should also manage the calls to updating the UI.

Note: Enemy spawning should be handled by rooms!! Including spawn timers, etc.
"""

extends Node2D

@export var enemy_scene: PackedScene

const respawn_price = 10

var random = RandomNumberGenerator.new()

var spawn_location_around_base
var spawn_location_around_player
var player
var gameMap
var roomController
var room
var base

var enemy_death_count
var next_heal

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node("Player")
	gameMap = get_node("GameMap")
	room = gameMap.cur_room
	base = room.base
	$HUD.connect("health_button_pressed", handle_upgrade.bind(0))
	$HUD.connect("stamina_button_pressed", handle_upgrade.bind(1))
	$HUD.connect("dmg_button_pressed", handle_upgrade.bind(2))
	#room.connect("player_close_to_exit",handle_player_close_to_exit)
	gameMap.connect("room_changed", handle_room_change)
	handle_room_change()
	enemy_death_count = 0
	next_heal = 0
	
func _process(delta):
	#print(Engine.get_frames_per_second())
	pass

# Handle player build request and delegate accordingly
func _on_player_build_requested(global_mouse_pos, build_id):
	# Check if can build at area using tilemap controller
	if not $GameMap.can_place_build(global_mouse_pos, build_id):
		return
	
	# Attempt purchase
	var build_instance = $ResourceManager.attempt_build_purchase(build_id)
	# Case where not enough resources to build. Just return
	if build_instance == null:
		return
	# Pass build to tilemap controller so it places it
	# $WorldMap.place_build(global_mouse_pos, build_instance)
	$GameMap.place_build_at_hover_tile(build_instance)
	# Update resources HUD
	$HUD.update_all_resources($ResourceManager.resources)

# Handle player delete request and delegate accordingly
func _on_player_delete_requested(_global_mouse_pos):
	# Remove build from the world at the tile the mouse is hovering over 
	var build_instance = $GameMap.get_build_at_hover_tile()
	# If nothing to delete, return
	if build_instance == null:
		return
	# Get some resources returned back from delete
	$ResourceManager.return_resources_from_delete(build_instance)
	# Update resource HUD
	$HUD.update_all_resources($ResourceManager.resources)

	# Delete build
	build_instance.remove()


func _handle_player_death():
		#game over
		print("Player died: Game Over")
		get_tree().change_scene_to_file("res://Scenes/Menus/MainMenu/MainMenu.tscn")


func handle_upgrade(type):
	if $ResourceManager.check_upgrade_cost(10) == true:
		if type == 0:
			player.increase_max_health(2)
		elif type == 1:
			player.increase_max_stamina(2)
		elif type == 2:
			player.increase_damage(1)
		$HUD.update_all_resources($ResourceManager.resources)

func attempt_base_claim():
	if $ResourceManager.attempt_base_purchase() == true:
		base.build()
		$HUD.update_all_resources($ResourceManager.resources)
	

func handle_room_change():
	room = gameMap.cur_room
	room.connect("player_close_to_exit",handle_player_close_to_exit)
	base = room.base
	$HUD.room_changed(base)
	if base != null:
		base.connect("fully_heal_player", heal_player.bind(1000))
		base.connect("attempt_claim", attempt_base_claim)
	
func handle_player_close_to_exit(state):
	$HUD.show_warning(state)

func heal_player(amount):
	player.heal(amount)

func update_enemy_death_count(enemy_difficulty):
	enemy_death_count += 1
	next_heal += enemy_difficulty
	if next_heal >= 8:
		next_heal = next_heal - 8
		player.heal(1)
	
	
