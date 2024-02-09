extends Area2D

func _process(delta):
		position = get_global_mouse_position()


var character_sheet
func _on_body_entered(body):
	pass
	#if character_sheet != null:
		#character_sheet.queue_free()
	#character_sheet = Director.show_sheet(body)


#func _on_body_exited(body):
	#if character_sheet != null:
		#character_sheet.queue_free()
