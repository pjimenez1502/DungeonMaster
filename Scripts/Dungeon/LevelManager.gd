extends Node2D

var adventurer = preload("res://Scenes/Prefab/Adventurer.tscn")


@onready var tile_map = $TileMap

func _on_tile_button_pressed(tile_value: int):
	tile_map.set_selected_placeable_tile(tile_value)
	tile_map.editing_state = 1

func _on_entity_button_pressed(int_id: int):
	tile_map.set_selected_placeable_entity(int_id)
	tile_map.editing_state = 2


func start_level():
	if !check_playable():
		print("UNPLAYABLE")
		return false
		
	var instance = adventurer.instantiate()
	
	var entrance = tile_map.entrance
	var exit = tile_map.exit
	
	instance.position = entrance.position
	instance.exit = exit
	instance.treasure_list = tile_map.loot_list.get_children()
	
	add_child.call_deferred(instance)
	
func check_playable():
	if !tile_map.entrance or !tile_map.exit:
		return false
	return true

func switch_level(modifier):
	$"..".switch_level(modifier)

func _unhandled_input(event):
	if Input.is_key_pressed(KEY_P):
		switch_level(-1)
