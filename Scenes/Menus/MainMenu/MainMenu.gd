extends Control

func _on_play_pressed():#settings button
	get_tree().change_scene_to_file("res://Prototyping/Gameplay.tscn")

func _on_settings_pressed(): #settings button
	get_tree().change_scene_to_file("res://Scenes/Menus/Settings/Settings.tscn")

func _on_quit_pressed():
	get_tree().quit()
