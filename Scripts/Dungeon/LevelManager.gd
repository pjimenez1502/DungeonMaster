extends Node2D

var level_monster_list = []
@onready var tile_map = $TileMap

func _on_tile_button_pressed(tile_value: int):
	tile_map.set_selected_placeable_tile(tile_value)
	tile_map.editing_state = 1

func _on_entity_button_pressed(int_id: int):
	tile_map.set_selected_placeable_entity(int_id)
	tile_map.editing_state = 2


func start_level():
	var adventurer = get_adventurer()
	
	var entrance = tile_map.entrance
	var exit = tile_map.exit
	
	adventurer.global_position = entrance.global_position
	adventurer.exit = exit
	adventurer.treasure_list = tile_map.loot_list.get_children()
	
	add_child.call_deferred(adventurer)
	return true

func get_adventurer():
	var adventurer
	if Director.current_adventurer:
		adventurer = Director.current_adventurer
		if adventurer.get_parent():
			adventurer.get_parent().remove_child(adventurer)
	else:
		adventurer = Director.create_adventurer()
	return adventurer


func check_playable():
	if !tile_map.entrance or !tile_map.exit:
		return false
	return true
