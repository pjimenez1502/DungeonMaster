extends Node

signal RICHES_UPDATE
signal RESOURCES_UPDATE
signal DAY_UPDATE
signal RENOUN_UPDATE

signal DAY_END
signal SHOW_CHART

var DUNGEON : Node2D

@export var riches := 100
@export var resources = {
	"soul": 1,
	"flesh": 1,
	"iron": 1,
}
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
	update_resources()
	DAY_UPDATE.emit(current_day)


	
func update_riches(value = null):
	if value:
		riches += value
	RICHES_UPDATE.emit(riches)
func update_resources(value = null):
	
	if value:
		if !check_enough_res(value):
			print("nuhuh")
			return false
		
		resources["soul"] += value["soul"]
		resources["flesh"] += value["flesh"]
		resources["iron"] += value["iron"]
		
	RESOURCES_UPDATE.emit(resources)
	return true

func check_enough_res(value):
	if (resources["soul"] + value["soul"]) < 0:
		return false
	if (resources["flesh"] + value["flesh"]) < 0:
		return false
	if (resources["iron"] + value["iron"]) < 0:
		return false
	return true
	
func update_day():
	current_day += 1
	DAY_UPDATE.emit(current_day)
func update_renoun(value):
	renoun = clampi(renoun + value, 0, 5)
	RENOUN_UPDATE.emit(renoun)


func adventurer_death(reward):
	
	restore_adventurer_looted()
	update_resources(reward)
	
	DAY_END.emit()
	update_day()
	
	current_adventurer = null
	await get_tree().create_timer(1.5).timeout
	heal_monsters()
	
	update_renoun(1)


func heal_monsters():
	for monster in DUNGEON.get_child(0).get_node("MonsterList").get_children():
		if !monster is Monster:
			monster.queue_free()
	for monster in DUNGEON.get_child(0).level_monster_list:
		if !monster.get_parent():
			DUNGEON.get_child(0).get_node("MonsterList").add_child(monster)
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

func game_over():
	#print("GAME OVER")
	pass
	
func _unhandled_input(event):
	if Input.is_key_pressed(KEY_P):
		switch_level(-1)

var adventurer = preload("res://Scenes/Prefab/Adventurer.tscn")
func create_adventurer():
	var instance = adventurer.instantiate()
	Director.current_adventurer = instance
	instance.calculate_level(Director.renoun)

	return instance
	
const CHARACTER_SHEET = preload("res://Scenes/UI/Character_sheet.tscn")
func get_sheet() -> Node:
	var sheet = CHARACTER_SHEET.instantiate()
	sheet.load_sheet_data(current_adventurer)
	return sheet

var current_chart
const CHARACTER_CHART = preload("res://Scenes/UI/Character_chart.tscn")
func show_chart(caracter):
	if current_chart != null:
		current_chart.queue_free()
	current_chart = CHARACTER_CHART.instantiate()
	current_chart.load_sheet_data(caracter)
	SHOW_CHART.emit(current_chart)
	return current_chart
