extends Control

func resume():
	get_tree().paused = false
	
func pause():
	get_tree().paused = true

func _input(event):
	if event.is_action_pressed("Escape") and get_tree().paused == false:
		pause()
	elif event.is_action_pressed("Escape") and get_tree().paused == true:
		resume()

func _on_resume_pressed():
	resume()

func _on_quit_pressed():
	get_tree().quit()

func _on_menu_pressed():
	get_tree().change_scene_to_file("res://Scenes/Menus/MainMenu/MainMenu.tscn")
