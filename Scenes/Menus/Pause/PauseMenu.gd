extends CanvasLayer

var HUD
var controls = false

func _ready():
	$Controls2.hide()
	HUD = get_parent().get_parent().get_node("HUD")
	resume()

func resume():
	hide()
	HUD.show()
	get_tree().paused = false
	
func pause():
	show()
	HUD.hide()
	get_tree().paused = true

func _input(event):
	if event.is_action_pressed("Escape") and get_tree().paused == false:
		pause()
	elif event.is_action_pressed("Escape") and get_tree().paused == true:
		resume()
		$Controls2.hide()

func _on_resume_pressed():
	resume()

func _on_controls_pressed():
	hide()
	$Controls2.show()

func _on_quit_pressed():
	get_tree().quit()

func _on_menu_pressed():
	resume()
	get_tree().change_scene_to_file("res://Scenes/Menus/MainMenu/MainMenu.tscn")

func _on_back_pressed():
	$Controls2.hide()
	show()
