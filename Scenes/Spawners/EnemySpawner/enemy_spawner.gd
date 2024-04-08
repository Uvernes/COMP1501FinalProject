extends Node2D


@export var spawn_delay: int
@export var max_enemy_count: int
@export var room_with_base: bool

var enemy_scene: PackedScene = preload("res://Scenes/Enemy/Enemy.tscn")
var random = RandomNumberGenerator.new()

# should be far enough that the player can never see an enemy spawn
#var player
var cur_enemy_count = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	#player = get_tree().get_current_scene().get_node("Player")
	$SpawnTimer.wait_time = spawn_delay
	$SpawnTimer.start()

func _on_spawn_timer_timeout():
	if cur_enemy_count < max_enemy_count:
		spawn_enemy()
	$SpawnTimer.start()

func spawn_enemy():
	var enemy = enemy_scene.instantiate()
	enemy.add_to_group("Enemy")
	enemy.get_node("EnemyHead").add_to_group("EnemyHeads")
	add_child(enemy)
	cur_enemy_count += 1

func _on_child_exiting_tree(node):
	if node.is_in_group("Enemy"):
		cur_enemy_count -= 1
