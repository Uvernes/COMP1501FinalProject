extends Node2D


@export var spawn_delay: float
@export var max_enemy_count: int
var original_max_enemy_count

@export var include_melee: bool = false
@export var include_ranged: bool = false

# enemy scenes
var enemy_melee_scene: PackedScene = preload("res://Scenes/Enemy/Enemy.tscn")
var enemy_ranged_scene: PackedScene = preload("res://Scenes/Enemy/EnemyShooter.tscn")
var enemy_scenes = [enemy_melee_scene, enemy_ranged_scene]

# enemy probabilities
var melee_prob = 1
var ranged_prob = melee_prob - 0.7

var base

# vars for wave event -> value varies according to difficulty // num of bases claimed
var difficulty
var wave_countdown
var max_wave_options = [3, 5, 7, 9, 11]
var spawn_interval_options = [10, 11, 13, 15, 15] # 3, 2, 2, 1, 1

# set difficulty based on how many rooms captured from bottom of GameMap
var cur_enemy_count = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if spawn_delay == 0:
		spawn_delay = 8
	if max_enemy_count == 0:
		max_enemy_count = 4
	original_max_enemy_count = max_enemy_count
	$SpawnTimer.wait_time = spawn_delay
	$SpawnTimer.start()
	base = get_parent().get_parent().get_node_or_null("Base")
	if base != null:
		difficulty = get_tree().get_current_scene().get_node("GameMap").get_num_bases_captured()
		base.connect("status_changed", base_status_changed)

func _on_spawn_timer_timeout():
	if cur_enemy_count < max_enemy_count:
		spawn_enemy()
		$SpawnTimer.start()

func spawn_enemy():
	var enemy
	if (include_melee && !(include_ranged)):
		enemy = enemy_melee_scene.instantiate()
	elif (include_ranged && !(include_melee)):
		enemy = enemy_ranged_scene.instantiate()
	else:
		var index = randf()
		if index <= ranged_prob:
			enemy = enemy_scenes[1].instantiate()
		elif index <= melee_prob:
			enemy = enemy_scenes[0].instantiate()
	enemy.add_to_group("Enemy")
	enemy.get_node("EnemyHead").add_to_group("EnemyHeads")
	enemy.spawner = self
	enemy.position = global_position
	get_parent().get_parent().add_child(enemy)
	cur_enemy_count += 1

func enemy_died():
	cur_enemy_count -= 1
	$SpawnTimer.start()

func base_status_changed(type): #types: "under attack", "inactive", "safe"
	if type == "safe":
		$SpawnTimer.stop()
		queue_free()
	elif type == "under attack":
		trigger_wave_event()
	elif type == "inactive":
		$SpawnTimer.wait_time = spawn_delay
		max_enemy_count = original_max_enemy_count
		wave_countdown = 0

func trigger_wave_event():
	wave_countdown = max_wave_options[difficulty]
	$SpawnTimer.wait_time = spawn_interval_options[difficulty] - 1
	max_enemy_count += 1
	$WaveTimer.start()

func _on_wave_timer_timeout():
	if wave_countdown > 0:
		$SpawnTimer.wait_time = $SpawnTimer.wait_time - 1
		max_enemy_count += 1
		wave_countdown -= 1
		$WaveTimer.start()
