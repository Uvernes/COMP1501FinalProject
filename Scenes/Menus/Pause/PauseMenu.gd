extends CanvasLayer

func _ready():
	$Controls2.hide()
	resume()

func resume():
	hide()
	get_tree().paused = false
	
func pause():
	show()
	get_tree().paused = true

func _input(event):
	if event.is_action_pressed("Escape") and get_tree().paused == false:
		pause()
	elif event.is_action_pressed("Escape") and get_tree().paused == true:
		resume()

func _on_resume_pressed():
	resume()

func _on_controls_pressed():
	$MarginContainer.hide()
	$Controls2.show()

func _on_quit_pressed():
	get_tree().quit()

func _on_menu_pressed():
	resume()
	get_tree().change_scene_to_file("res://Scenes/Menus/MainMenu/MainMenu.tscn")

func _on_back_pressed():
	$Controls2.hide()
	$MarginContainer.show()
