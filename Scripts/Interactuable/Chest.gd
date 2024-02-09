extends Interactuable
class_name Chest

var open := false
var value : int

var chest_loot : int

func interact():
	set_open(true)
	Director.looted_riches(chest_loot)
	chest_loot = 0

func set_open(value):
	if open == value:
		return
	open = value
	if value:
		animated_sprite.play("Open")
	else:
		animated_sprite.play("Closed")

