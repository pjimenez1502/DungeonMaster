extends Node

signal RICHES_UPDATE
signal SOULS_UPDATE
signal DAY_UPDATE
signal RENOUN_UPDATE

signal DAY_END


var DUNGEON : Node2D

@export var riches := 200
@export var souls := 3
var current_day := 0
var current_time

var current_level := 1
var current_adventurer
var renoun := 0

var level_dictionary = {
	0: "res://Scenes/BossRoom.tscn"
}



func dungeon_init():
	update_riches()
	update_souls()
	DAY_UPDATE.emit(current_day)


	
func update_riches(value = null):
	if value:
		riches += value
	RICHES_UPDATE.emit(riches)
func update_souls(value = null):
	if value:
		souls += value
	SOULS_UPDATE.emit(souls)
func update_day():
	current_day += 1
	DAY_UPDATE.emit(current_day)
func update_renoun(value):
	renoun = clampi(renoun + value, 0, 5)
	RENOUN_UPDATE.emit(renoun)


func adventurer_death():
	
	restore_adventurer_looted()
	update_souls(+1)
	
	DAY_END.emit()
	update_day()
	
	current_adventurer = null
	await get_tree().create_timer(1.5).timeout
	heal_monsters()
	
	update_renoun(1)


func heal_monsters():
	for monster in DUNGEON.get_child(0).get_node("MonsterList").get_children():
		if monster is Monster:
			monster.reset_health()


func looted_riches(value):
	current_adventurer.looted_ammount += value
	print("director, adventurer looted: ", current_adventurer.looted_ammount)

func restore_adventurer_looted():
	update_riches(current_adventurer.looted_ammount)
	current_adventurer.looted_ammount = 0



func switch_level(modifier):
	current_level += modifier
	
	var instance = load(level_dictionary[current_level]).instantiate()
	DUNGEON.remove_child(DUNGEON.get_child(0))
	DUNGEON.add_child(instance)

func calculate_renoun():
	## Get a value depending on amount of riches spent on the dungeon to influence adventurer spawn
	pass

func game_over():
	print("GAME OVER")
	
func _unhandled_input(event):
	if Input.is_key_pressed(KEY_P):
		switch_level(-1)

var adventurer = preload("res://Scenes/Prefab/Adventurer.tscn")
func create_adventurer():
	var instance = adventurer.instantiate()
	Director.current_adventurer = instance
	instance.calculate_level(Director.renoun)

	return instance

var character_sheet = load("res://Scenes/UI/Character_sheet.tscn")
func get_sheet() -> Node:
	var sheet = character_sheet.instantiate()
	sheet.load_sheet_data(current_adventurer)
	return sheet
