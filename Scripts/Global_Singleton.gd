extends Node

var health = 100;
var population = 0;

signal health_changed(new_health)
signal population_changed(new_population)

func deal_damage(amount):
	health -= amount
	if health < 0:
		health = 0
	emit_signal("health_changed", health)

func heal(amount):
	health += amount
	emit_signal("health_changed", health)
