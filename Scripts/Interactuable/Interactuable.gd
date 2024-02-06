extends Node2D
class_name Interactuable

@onready var animated_sprite = $AnimatedSprite2D

func interact():
	animated_sprite.play("Open")
	pass
