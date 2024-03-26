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

var random = RandomNumberGenerator.new()

var spawn_location_around_base
var spawn_location_around_player
var player

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node("Player")
	$EnemySpawnTimerForBase.start()
	$EnemySpawnTimerForPlayer.start()
	
func _process(_delta):
	if($EnemySpawnTimerForBase.time_left == 0):
		var distance = random.randf_range(min_spawn_distance_from_base, max_spawn_distance_from_base)
		var direction = Vector2(randf_range(-1,1),randf_range(-1,1))
		var spawn_position = direction * distance
		
		#check if position is available here
		if(spawn_position - player.position).length() > min_distance_from_player:
			var enemy = enemy_scene.instantiate()
			enemy.position = spawn_position
			enemy.add_to_group("Enemy")
			add_child(enemy)
			$EnemySpawnTimerForBase.start()
			
	if player.position.length() > min_player_distance_from_base:
		if $EnemySpawnTimerForPlayer.time_left == 0:
			var distance = random.randf_range(min_spawn_distance_from_player, max_spawn_distance_from_player)
			var direction = Vector2(randf_range(-1,1),randf_range(-1,1))
			var spawn_position = player.position + direction * distance
			
			#check if position is available here
			var enemy = enemy_scene.instantiate()
			enemy.position = spawn_position
			enemy.add_to_group("Enemy")
			add_child(enemy)
			$EnemySpawnTimerForPlayer.start()
			

# Handle player build request and delegate accordingly
func _on_player_build_requested(global_mouse_pos, build_id):
	# Check if can build at area using tilemap controller
	# TODO
	
	# Attempt purchase
	var build_instance = $ResourceManager.attempt_build_purchase(build_id)
	# Case where not enough resources to build. Just return
	if build_instance == null:
		return
	# Pass build to tilemap controller so it places it
	$RoughWorkTileMap.place_build(global_mouse_pos, build_instance)
	# Update resources HUD
	$HUD.update_all_resources($ResourceManager.resources)
