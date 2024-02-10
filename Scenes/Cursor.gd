extends Area2D

func _process(delta):
		position = get_global_mouse_position()


var character_chart
func _on_body_entered(body):
	if character_chart != null:
		character_chart.queue_free()
	character_chart = Director.show_chart(body)
	pass

func _on_body_exited(body):
	if character_chart != null:
		character_chart.queue_free()
