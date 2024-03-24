extends Area2D


var type: String

func init(type: String, image_path: String):
	self.type = type
	get_node("Sprite2D").texture = ResourceLoader.load(image_path)

func _on_body_entered(body):
	if body.is_in_group("Player"):
		# used index 1 because it detects GlobalSingleton on 0
		get_node("/root").get_child(1).get_node("ResourceManager").resource_picked_up(self.type, 1)
		queue_free()
