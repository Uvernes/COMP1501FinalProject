extends "res://Scenes/Placeables/Placeable.gd"

var enemies_in_sight = [] #may want to make sorting algorithm to keep closest enemies at front
@export var bullet_scene: PackedScene
const Bullet = preload("res://Scenes/Bullet/bullet.gd") 
var bullet_speed = 500
var bullet_damage = 1

var random = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	build_id = placeables.TOWER
	$ShootCooldown.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if $ShootCooldown.time_left == 0:
		if enemies_in_sight.is_empty() == false:
			for i in enemies_in_sight.size():
				if i < (enemies_in_sight.size() + 1) && i <= 4: #ensures enemy will be chosen, sets loop cap at 5
					if random.randi_range(0,1) == 1: # 1/2 chance to choose to shoot enemy i
						shoot_enemy(enemies_in_sight[i].position)
						break
				else:
					shoot_enemy(enemies_in_sight[i].position)
					break
			$ShootCooldown.start()


func _on_sight_body_entered(body):
	if body != null:
		if body.is_in_group("Enemy"):
			enemies_in_sight.append(body)

func _on_sight_body_exited(body):
	if body != null:
		if body.is_in_group("Enemy"):
			enemies_in_sight.erase(body)

func shoot_enemy(enemy_pos):
	var bullet : Bullet = bullet_scene.instantiate()
	$BulletStorage.add_child(bullet)
	var bullet_direction = (enemy_pos - position).normalized()
	bullet.init(position + 50*bullet_direction, position.angle_to_point(enemy_pos), bullet_speed, bullet_direction, bullet_damage)
	bullet.fire()

