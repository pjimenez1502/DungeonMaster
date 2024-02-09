extends Control

@onready var healthBar = $HealthBar
#@onready var status_grid = $HealthBar/StatusGrid

#var statusIconPrefab = preload("res://Prefabs/UI_Prefabs/status_icon_prefab.tscn")

var HP

var standard_color
var health_colors = {
	"PLAYER": Color(0,1,0,1),
	"ENEMY": Color(0.8,0,0,1),
	"DAMAGE": Color(0.8,0,0,1),
}

#var status_list = {}
#var status_icon_path = "res://Assets/UI/Status_Icons/"

#func _ready():
#	show_status()

#func show_status():
##	print ("hbstatuses: ", status_list)
	#for child in status_grid.get_children():
		#child.queue_free()
		#
	#for status_id in status_list.keys():
		#var status_icon = statusIconPrefab.instantiate()
		#status_icon.texture = load(str(status_icon_path,status_list[status_id]["icon"],".png"))
		#status_icon.get_node("duration").text = str(status_list[status_id]["duration"])
		#
		#status_icon.get_node("buffprogress").max_value = Combat_effects.STATUS_DICTIONARY[status_id]["duration"]
		#status_icon.get_node("buffprogress").value = status_list[status_id]["duration"]
		#status_grid.add_child(status_icon)
		

func set_max_HP(value, color):
	healthBar.set_max(value)
	healthBar.set_value(value)
	standard_color = health_colors[color]
	healthBar.tint_progress = standard_color
	HP = value
	
func set_HP(value):
	print("hp set to: ", value)
	HP = value
	healthBar.set_value(value)

func hb_damage(damage):
	healthBar.set_value(HP - damage)
	HP -= damage
	
	healthBar.tint_progress = health_colors["DAMAGE"]
	if is_inside_tree():
		await get_tree().create_timer(0.5, false).timeout
		healthBar.tint_progress = standard_color
	
