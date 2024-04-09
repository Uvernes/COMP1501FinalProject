extends Node2D


@export var resource_scene: PackedScene

func _ready():
	var wood = resource_scene.instantiate()
	wood.init("wood", "res://Assets/Resources/wood.png")
	call_deferred("add_child", wood)
	#add_child(wood)

func _on_spawn_timer_timeout():
	var wood = resource_scene.instantiate()
	wood.init("wood", "res://Assets/Resources/wood.png")
	add_child(wood)

func _on_child_exiting_tree(node):
	if node.name == "Resource":
		$SpawnTimer.start()
