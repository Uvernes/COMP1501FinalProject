extends ProgressBar

func _ready():
	GlobalSingleton.connect("health_changed",health_change_bar)
	pass

func health_change_bar(new_health):
	value = new_health
