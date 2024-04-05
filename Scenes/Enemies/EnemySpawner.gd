"""
Spawner for enemies. Add to a room as a child.
TODO - this is too limited. We should have spawners be area based so that
	   we can have multiple spawn regions in a room and have it be better
	   under our control rather than just one timer.
"""
extends Node2D

@export var enemy_scene: PackedScene
var player
var base

const min_distance_from_player = 200
const min_player_distance_from_base = 1000

const min_spawn_distance_from_base = 400
const max_spawn_distance_from_base = 1000
const min_spawn_distance_from_player = 250 # should be far enough that the player can never see an enemy spawn
const max_spawn_distance_from_player = 500

var random = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_current_scene().get_node("Player")
	base = get_parent().get_node("Base")

	$EnemySpawnTimerForBase.start()
	$EnemySpawnTimerForPlayer.start()


func _process(_delta):
	if(base != null and $EnemySpawnTimerForBase.time_left == 0):
		var distance = random.randf_range(min_spawn_distance_from_base, max_spawn_distance_from_base)
		var direction = Vector2(randf_range(-1,1),randf_range(-1,1))
		var spawn_position = direction * distance
		
		spawn_position = get_tree().get_current_scene().get_node("GameMap").move_spawn_tile_to_cell_at_pos(spawn_position)
		
		if(spawn_position - player.position).length() > min_distance_from_player && (spawn_position - base.position).length() > min_spawn_distance_from_base:
			if get_tree().get_current_scene().get_node("GameMap").can_spawn_mob() == true:
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
			
			spawn_position = get_tree().get_current_scene().get_node("GameMap").move_spawn_tile_to_cell_at_pos(spawn_position)
			if(spawn_position - player.position).length() > min_distance_from_player:
				if get_tree().get_current_scene().get_node("GameMap").can_spawn_mob() == true:
					var enemy = enemy_scene.instantiate()
					enemy.position = spawn_position
					enemy.add_to_group("Enemy")
					enemy.get_node("EnemyHead").add_to_group("EnemyHeads") #used to determine if head is touching base
					add_child(enemy)
					$EnemySpawnTimerForPlayer.start()



