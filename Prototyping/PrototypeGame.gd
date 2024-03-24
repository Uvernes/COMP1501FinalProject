extends Node2D

@export var enemy_scene: PackedScene

const min_distance_from_player = 200

# Called when the node enters the scene tree for the first time.
func _ready():
	$EnemySpawnTimer.start()
	
func _process(_delta):
	if($EnemySpawnTimer.time_left == 0):
		var enemy_spawn_location = $EnemyPath/EnemySpawnLocation
		enemy_spawn_location.progress_ratio = randf()
		
		if(enemy_spawn_location.position - get_node("Player").position).length() > min_distance_from_player: #ensures enemies don't spawn too close to player
			var enemy = enemy_scene.instantiate()
			enemy.position = enemy_spawn_location.position
			enemy.add_to_group("Enemy")
			add_child(enemy)
			$EnemySpawnTimer.start()
