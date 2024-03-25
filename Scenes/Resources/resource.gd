extends Area2D

var type: String
var amount: int


func init(type: String, image_path: String, amount: int=1):
	self.type = type
	self.amount = amount
	get_node("Sprite2D").texture = ResourceLoader.load(image_path)


func _on_body_entered(body):
	if body.is_in_group("Player"):
		get_tree().current_scene.get_node("ResourceManager").resource_picked_up(type, amount)
		queue_free()
