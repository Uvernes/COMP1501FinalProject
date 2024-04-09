extends Node2D


@export var spawn_delay: int
@export var max_enemy_count: int

var enemy_scene: PackedScene = preload("res://Scenes/Enemy/EnemyShooter.tscn")
var random = RandomNumberGenerator.new()
var base

# vars for wave event
var wave_countdown
var max_wave = 7 # make value change according to difficulty // num of bases claimed

var cur_enemy_count = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	#player = get_tree().get_current_scene().get_node("Player")
	$SpawnTimer.wait_time = spawn_delay
	$SpawnTimer.start()
	base = get_parent().get_parent().get_parent().get_node_or_null("Base")
	if base != null:
		base.connect("status_changed", base_status_changed)

func _on_spawn_timer_timeout():
	if cur_enemy_count < max_enemy_count:
		spawn_enemy()
		$SpawnTimer.start()

func spawn_enemy():
	var enemy = enemy_scene.instantiate()
	enemy.add_to_group("Enemy")
	enemy.get_node("EnemyHead").add_to_group("EnemyHeads")
	get_parent().get_parent().add_child(enemy)
	#add_child(enemy)
	enemy.position = global_position
	cur_enemy_count += 1

func _on_child_exiting_tree(node):
	if node.is_in_group("Enemy"):
		cur_enemy_count -= 1
		$SpawnTimer.start()

func base_status_changed(type): #types: "under attack", "inactive", "safe"
	if type == "safe":
		$SpawnTimer.pause()
	elif type == "under attack":
		trigger_wave_event()
	elif type == "inactive":
		$SpawnTimer.wait_time = spawn_delay
		wave_countdown = -1

func trigger_wave_event():
	wave_countdown = max_wave
