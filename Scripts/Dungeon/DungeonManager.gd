extends Node2D

signal RICHES_UPDATE
signal SOULS_UPDATE

@export var riches := 200
@export var souls := 3

var renoun

var current_level := 1
var level_dictionary = {
	0: "res://Scenes/BossRoom.tscn"
}

func dungeon_init():
	update_riches()
	update_souls()
	
	
	
	
	
func update_riches():
	RICHES_UPDATE.emit(riches)
func update_souls():
	SOULS_UPDATE.emit(souls)


func switch_level(modifier):
	current_level += modifier
	
	var instance = load(level_dictionary[current_level]).instantiate()
	remove_child(get_child(0))
	add_child(instance)
	
	## switch children level scene
	## (on editor moving between levels or adventurer advancing to next level.)
	pass

func calculate_renoun():
	## Get a value depending on amount of riches spent on the dungeon to influence adventurer spawn
	pass
	
