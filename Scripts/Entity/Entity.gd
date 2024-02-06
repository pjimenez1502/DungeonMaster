extends CharacterBody2D
class_name Entity

@export var health := 10.0


func recieve_damage(damage):
	health -= damage
	if health <= 0:
		die()

func die():
	queue_free()
	## Remove this entity and replace it with a dead sprite
	pass
