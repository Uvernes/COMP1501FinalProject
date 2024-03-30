"""
Game controller script. Highest level for orchestrating the game logic.
Recieves signals and delegates tasks accordingly.
Some tasks include: 
-Population (handled here)
-Enemy spawning (handled here for now)
-Resource management (delegated)

The controller should also manage the calls to updating the UI.
"""

extends Node2D

@export var enemy_scene: PackedScene

const min_distance_from_player = 200
const min_player_distance_from_base = 1000

const min_spawn_distance_from_base = 400
const max_spawn_distance_from_base = 1000
const min_spawn_distance_from_player = 250 #should be far enough that the player can never see an enemy spawn
const max_spawn_distance_from_player = 500

const respawn_price = 10

var random = RandomNumberGenerator.new()

var spawn_location_around_base
var spawn_location_around_player
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
	$EnemySpawnTimerForBase.start()
	$EnemySpawnTimerForPlayer.start()
	
func _process(_delta):
	if($EnemySpawnTimerForBase.time_left == 0):
		var distance = random.randf_range(min_spawn_distance_from_base, max_spawn_distance_from_base)
		var direction = Vector2(randf_range(-1,1),randf_range(-1,1))
		var spawn_position = direction * distance
		
		$WorldMap.move_spawn_tile_to_cell_at_pos(spawn_position)
		if $WorldMap.can_spawn_mob(spawn_position) == true:
			if(spawn_position - player.position).length() > min_distance_from_player && (spawn_position - homebase.position).length() > min_spawn_distance_from_base:
				var enemy = enemy_scene.instantiate()
				enemy.position = spawn_position
				enemy.add_to_group("Enemy")
				add_child(enemy)
				$EnemySpawnTimerForBase.start()
				
	
	
	if player.position.length() > min_player_distance_from_base:
		if $EnemySpawnTimerForPlayer.time_left == 0:
			var distance = random.randf_range(min_spawn_distance_from_player, max_spawn_distance_from_player)
			var direction = Vector2(randf_range(-1,1),randf_range(-1,1))
			var spawn_position = player.position + (direction * distance)
			
			$WorldMap.move_spawn_tile_to_cell_at_pos(spawn_position)
			if $WorldMap.can_spawn_mob(spawn_position) == true:
				if(spawn_position - player.position).length() > min_distance_from_player:
					var enemy = enemy_scene.instantiate()
					enemy.position = spawn_position
					enemy.add_to_group("Enemy")
					enemy.get_node("EnemyHead").add_to_group("EnemyHeads") #used to determine if head is touching homebase
					add_child(enemy)
					$EnemySpawnTimerForPlayer.start()

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
		get_tree().quit()


func handle_homebase_death():
	#game over
	print("Population reached zero: Game Over")
	get_tree().quit()

func handle_upgrade(type):
	if $ResourceManager.check_upgrade_cost(10) == true:
		if type == 0:
			player.increase_max_health(2)
		elif type == 1:
			player.increase_max_stamina(2)
		elif type == 2:
			player.increase_melee_damage(1)
		$HUD.update_all_resources($ResourceManager.resources)
	
