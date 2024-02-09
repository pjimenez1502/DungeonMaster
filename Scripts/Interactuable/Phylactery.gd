extends Interactuable

func interact():
	animated_sprite.play("Open")
	
	Director.game_over()
