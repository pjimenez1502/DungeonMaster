extends ColorRect

var tween

func _ready():
	modulate = Color(1,1,1,0)	

func show_screen():
	tween = create_tween()
	tween.tween_property(self, "modulate", Color(1,1,1,1), 2)
	tween.tween_interval(0.5)
	tween.tween_property(self, "modulate", Color(0,0,0,0), 2)
