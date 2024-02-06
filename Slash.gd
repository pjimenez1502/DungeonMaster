extends Node2D

func _ready():
	await get_tree().create_timer(0.4).timeout
	queue_free()

func _on_slash_area_body_entered(body):
	if body is Entity:
		body.recieve_damage(5)
