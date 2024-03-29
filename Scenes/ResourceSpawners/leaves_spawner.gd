extends Node2D


@export var resource_scene: PackedScene

func _ready():
	$SpawnTimer.start()

func _on_spawn_timer_timeout():
	var leaves = resource_scene.instantiate()
	leaves.init("leaves", "res://Assets/Resources/leaves_resource.png")
	add_child(leaves)

func _on_child_exiting_tree(node):
	if node.name == "leaves":
		$SpawnTimer.start()
