extends Node2D


@export var spawn_delay: int
@export var enemy_count: int
@export var room_with_base: bool

var enemy_scene: PackedScene = preload("res://Scenes/Enemy/Enemy.tscn")
var random = RandomNumberGenerator.new()

# should be far enough that the player can never see an enemy spawn
var player
const spawn_distance_from_player = 500

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_current_scene().get_node("Player")
	$SpawnTimer.wait_time = spawn_delay
	$SpawnTimer.start()

func _on_spawn_timer_timeout():
	var spawn_position = Vector2(random.randf_range(position.x-150, position.x+150), random.randf_range(position.y-150, position.y+150))
	
	if (spawn_position - player.position).length > spawn_distance_from_player:
		$SpawnChecker.position = spawn_position
		$SpawnChecker.usage_allowed = true
		
		if $SpawnChecker.collisionList.size() == 0:
			spawn_enemy(spawn_position)
		
		$SpawnChecker.usage_allowed = false
		$SpawnChecker.collisionList.clear()
	
	$SpawnTimer.start()

func spawn_enemy(pos):
	var enemy = enemy_scene.instantiate()
	enemy.position = pos
	enemy.add_to_group("Enemy")
	enemy.get_node("EnemyHead").add_to_group("EnemyHeads")
	add_child(enemy)
