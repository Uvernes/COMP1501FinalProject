extends Node2D


@export var resource_scene: PackedScene

func _ready():
	var stone = resource_scene.instantiate()
	stone.init("stone", "res://Assets/Resources/rock.png")
	call_deferred("add_child", stone)
	#add_child(stone)

func _on_spawn_timer_timeout():
	var stone = resource_scene.instantiate()
	stone.init("stone", "res://Assets/Resources/rock.png")
	add_child(stone)

func _on_child_exiting_tree(node):
	if node.name == "Resource":
		$SpawnTimer.start()
