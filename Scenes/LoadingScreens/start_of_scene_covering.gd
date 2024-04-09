"""
Creates a covering so that when the gameplay scene first loads it is hidden from
the player (otherwise there is a jarring transition)
"""

extends CanvasLayer



func _on_delete_self_timer_timeout():
	queue_free()
