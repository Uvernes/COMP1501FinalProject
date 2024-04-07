extends "res://Scenes/Placeables/Placeable.gd"

var touching
var breaking
# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	build_id = placeables.WEB
	touching = []
	breaking = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if touching.size() > 0 && breaking == false:
		if $BreakTimer.time_left == 0:
			$BreakTimer.start()
			$BreakTimer.paused = false
		else:
			$BreakTimer.paused = false
		breaking = true
	elif touching.size() == 0:
		$BreakTimer.paused = true
		breaking = false
	for i in touching.size():
		touching[i].velocity -= touching[i].velocity * 25 * delta

func _on_body_entered(body):
	if body.is_in_group("Enemy") || body.name == "Player":
		if touching.find(body) == -1:
			touching.append(body)

func _on_body_exited(body):
	touching.erase(body)

func _on_break_timer_timeout():
	remove()
