extends Node2D

var damage : int
@onready var slash_area = $Offset/SlashArea

func _ready():
	await get_tree().create_timer(0.4).timeout
	queue_free()

func init_slash(set_damage, mask):
	slash_area.collision_mask = mask
	damage = set_damage

func _on_slash_area_body_entered(body):
	pass
	#if body is PathfindingEntity:
		#body.recieve_damage(damage)
