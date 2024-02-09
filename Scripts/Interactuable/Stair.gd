extends Interactuable

@export var level_modifier := -1

func interact():
	Director.switch_level(level_modifier)
