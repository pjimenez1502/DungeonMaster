extends Interactuable
class_name Chest

var open := false
var value : int


func interact():
	set_open(true)

func set_open(value):
	if open == value:
		return
	open = value
	if value:
		animated_sprite.play("Open")
	else:
		animated_sprite.play("Closed")


