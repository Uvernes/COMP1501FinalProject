extends Area2D

@onready var _animated_sprite = $AnimatedSprite2D

func _ready():
		_animated_sprite.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
