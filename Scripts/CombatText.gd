extends Node2D

@onready var label = $Label
@onready var anim_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func start_combat_text(value:String, start_pos:Vector2, height:float, spread:float):
	anim_player.play("Fall and Fade")
	label.text = value
	var tween = get_tree().create_tween()
	var end_pos = Vector2(randf_range(-spread, spread), -height) + start_pos
	var tween_lenght = anim_player.get_animation("Fall and Fade").length
	
	tween.tween_property(self, "position", end_pos, tween_lenght).from(start_pos)


func remove():
	pass
#	anim_player.stop()
#	if is_inside_tree():
#		get_parent().remove_child(self)
#	queue_free(self) ??? does this do anything
