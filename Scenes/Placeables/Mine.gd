extends "res://Scenes/Placeables/Placeable.gd"

const max_damage = 120 #multiplied by very small numberw
const knockback_force = 820
var in_blast_radius
# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	build_id = placeables.MINE
	in_blast_radius = []

func _on_body_entered(body):
	if body != null:
		if body.is_in_group("Enemy") || body.name == "Player" || body.is_in_group("player_projectile") || body.is_in_group("enemy_projectile"):
			if body.is_in_group("player_projectile") || body.is_in_group("enemy_projectile"):
				body.queue_free()
			explode()

func explode():
	var distance_vector
	var distance
	in_blast_radius = $BlastArea.get_overlapping_bodies()
	for i in in_blast_radius.size():
		if in_blast_radius[i].is_in_group("Enemy"):
			distance_vector = in_blast_radius[i].position - position
			distance = 1 / distance_vector.length()
			distance_vector = distance_vector.normalized()
			in_blast_radius[i].take_damage(max_damage * distance, distance_vector, knockback_force * distance * 1.8)
		elif in_blast_radius[i].name == "Player":
			distance_vector = in_blast_radius[i].position - position
			distance = 1 / distance_vector.length()
			distance_vector = distance_vector.normalized()
			#print(distance)
			#print(max_damage * distance)
			#print(knockback_force * distance)
			if(max_damage * distance) > 0:
				in_blast_radius[i].hit(max_damage * distance, distance_vector, knockback_force * distance)
			else:
				in_blast_radius[i].hit(0, distance_vector, knockback_force * distance)
	#await get_tree().create_timer(0.1)
	remove()
