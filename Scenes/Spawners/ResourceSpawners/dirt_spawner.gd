extends Node2D


@export var resource_scene: PackedScene

func _ready():
	var dirt = resource_scene.instantiate()
	dirt.init("dirt", "res://Assets/Resources/dirt.png")
	add_child(dirt)

func _on_spawn_timer_timeout():
	var dirt = resource_scene.instantiate()
	dirt.init("dirt", "res://Assets/Resources/dirt.png")
	add_child(dirt)

func _on_child_exiting_tree(node):
	if node.name != "SpawnTimer":
		if node.type == "dirt":
			$SpawnTimer.start()