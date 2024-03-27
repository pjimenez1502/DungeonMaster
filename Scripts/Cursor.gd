extends Area2D

func _process(delta):
		position = get_global_mouse_position()


func _on_body_entered(body):
	if body is Monster:
		Director.current_chart = Director.show_chart(body)

func _on_body_exited(body):
	if Director.current_chart != null:
		Director.current_chart.queue_free()
