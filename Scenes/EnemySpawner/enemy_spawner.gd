extends Node2D

# Note: Enemy spawning doesnt currently take light into consideration

@export var enemy_scene: PackedScene
@export var spawner_type: String # prefered values: "homebase", "wilderness"
@export var spawn_delay: int

const distance_from_player = 600 # distance for spawner to activate (player in reach)
const distance_from_base = 1000 # distance for spawner to activate (homebase nearby)
const spawner_distance_radius = 200 # spawner range

# get player to decide whether spawner should be active
var player = get_tree().get_first_node_in_group("Player")

var random = RandomNumberGenerator.new() # random num generator


func _ready():
	$SpawnTimer.wait_time = spawn_delay
	$SpawnTimer.start()

func _on_spawn_timer_timeout():
	# initialize enemy spawn position
	var distance = random.randf_range(position.x - spawner_distance_radius, position.x + spawner_distance_radius)
	var direction = Vector2(randf_range(-1,1),randf_range(-1,1))
	var spawn_position = direction * distance
	
	# create enemy
	var enemy = enemy_scene.instantiate()
	enemy.hide()
	enemy.position = spawn_position
	
	# verify if it can be placed
	if enemy.get_slide_collision_count() > 0:
		enemy.queue_free()
	elif spawner_type == "wilderness" && ((spawn_position - player.position).length > distance_from_player):
		enemy.queue_free()
	else:
		enemy.add_to_group("Enemy")
		enemy.get_node("EnemyHead").add_to_group("EnemyHeads")
		enemy.show()
		add_child(enemy)
	$SpawnTimer.start()
