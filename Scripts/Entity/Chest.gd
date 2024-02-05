extends Node2D

var open := false
var value : int

@onready var animated_sprite = $AnimatedSprite2D

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


