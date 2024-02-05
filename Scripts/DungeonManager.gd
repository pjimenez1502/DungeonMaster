extends Node2D

var adventurer = preload("res://Scenes/Prefab/Adventurer.tscn")

@onready var tile_map = $TileMap

var tile_value_dict = {
	0: "wall",
	1: "floor",
	2: "door",
	3: "chest",
	4: "stair_up",
	5: "stair_down",
}

var entity_dictionary = {
	0: "chest",
	5: "unarmed_skeleton",
}


func _on_tile_button_pressed(tile_value: int):
	print("selected: ", tile_value_dict[tile_value])
	tile_map.set_selected_placeable_tile(tile_value_dict[tile_value])

func _on_entity_button_pressed(int_id: int):
	print("selected: ", entity_dictionary[int_id])
	tile_map.set_selected_placeable_entity(entity_dictionary[int_id])
	

func start_dungeon():
	var instance = adventurer.instantiate()
	
	var entrance_position = tile_map.get_tile_real_position(tile_map.entrance_location)
	var exit_position = tile_map.get_tile_real_position(tile_map.exit_location)
	
	instance.position = entrance_position
	instance.exit_pos = exit_position
	
	add_child(instance)
