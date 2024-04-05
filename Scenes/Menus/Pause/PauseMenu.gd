extends Control

func _ready():
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

func _on_button_pressed():
	resume()

func _on_quit_pressed():
	get_tree().quit()

func _on_menu_pressed():
	resume()
	get_tree().change_scene_to_file("res://Scenes/Menus/MainMenu/MainMenu.tscn")
