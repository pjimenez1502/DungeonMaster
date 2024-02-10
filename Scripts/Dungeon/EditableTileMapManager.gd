extends TileMap

var grid = []
var entity_grid = []
var grid_width = 12
var grid_height = 12

var terrain_layer := 0
var source_id := 0
var atlas_coord : Vector2i = Vector2i(0,0)

var placeable_count := 50
var selected_placeable

enum EDIT_STATES {NONE, TILE, ENTITY}
var editing_state := EDIT_STATES.NONE

var entrance
var exit


var tile_dictionary = {
	-1: {"id": "empty", "value": Vector2i(0,0)},
	0: {"id": "wall", "value": Vector2i(1,0)},
	1: {"id": "floor", "value": Vector2i(2,0)},
	2: {"id": "door", "value": Vector2i(0,1)},
}

var interactuable_dictionary = {
	0: {"id": "stair_down", "value": "res://Scenes/Prefab/Stair_Down.tscn"},
	1: {"id": "stair_up", "value": "res://Scenes/Prefab/Stair_Up.tscn"},
	2: {"id": "chest", "value": "res://Scenes/Prefab/Chest.tscn"},
	3: {"id": "phylactery", "value": "res://Scenes/Prefab/Phylactery.tscn"},
	
	5: {"id": "monster", "value": "res://Scenes/Prefab/Monster.tscn"},
}

func _unhandled_input(event):
	match editing_state:
		EDIT_STATES.TILE:
			if event.is_action_pressed("LeftClick"):
				change_hovered_tile(selected_placeable)
			if event.is_action_pressed("RightClick"):
				change_hovered_tile(tile_dictionary[0])
			
		EDIT_STATES.ENTITY:
			if event.is_action_pressed("LeftClick"):
				place_entity(selected_entity)
				pass
			if event.is_action_pressed("RightClick"):
				remove_entity()
				pass

func _ready():
	generate_empty_grid()

##DUNGEON INIT
func generate_empty_grid():
	for i in grid_width:
		grid.append([])
		for j in grid_height:
			grid[i].append("empty")
			set_cell(terrain_layer, Vector2(i,j), source_id, tile_dictionary[-1]["value"])
	
	for i in grid_width:
		entity_grid.append([])
		for j in grid_height:
			entity_grid[i].append({"id":"empty", "object": null})

## DUNGEON EDIT
func change_hovered_tile(tile_value):
	var mouse_tile : Vector2i = get_tile_at_mousepos()
	if !check_placeable_limit(tile_value, mouse_tile):
		return
		
	set_cell(terrain_layer, mouse_tile, source_id, tile_value["value"])
	grid[mouse_tile.x][mouse_tile.y] = tile_value["id"]
	
	for cell in get_surrounding_cells(mouse_tile):
		if !check_inside_bounds(cell):
			set_cell(terrain_layer, cell, source_id, tile_dictionary[0]["value"])
			continue
		if grid[cell.x][cell.y] == "empty":
			set_cell(terrain_layer, cell, source_id, tile_dictionary[0]["value"])
			grid[cell.x][cell.y] == "wall"
	
	#check_placing_stair(tile_value, mouse_tile)

func check_placeable_limit(tile_value, mouse_tile) -> bool:
	if !check_inside_bounds(mouse_tile):
		return false
	var prev_tile_atlas = get_cell_atlas_coords(terrain_layer, mouse_tile)
	
	if tile_value != tile_dictionary[0] and (prev_tile_atlas == tile_dictionary[-1]["value"] or prev_tile_atlas == tile_dictionary[0]["value"]):
		if placeable_count < 1:
			return false
		placeable_count -= 1
	if tile_value == tile_dictionary[0] and (prev_tile_atlas != tile_dictionary[-1]["value"] and prev_tile_atlas != tile_dictionary[0]["value"]):
		placeable_count += 1
	return true

func set_selected_placeable_tile(tile_value):
	selected_placeable = tile_dictionary[tile_value]

func check_inside_bounds(position):
	if position.x >= grid_width or position.y >= grid_height or position.x < 0 or position.y < 0:
		return false
	return true
## END DUNGEON EDIT


## ENTITY PLACING
var selected_entity
@onready var monster_list = $"../MonsterList"
@onready var loot_list = $"../LootList"
@onready var access_list = $"../AccessList"

func place_entity(entity_id):
	var location : Vector2i = get_tile_at_mousepos()
	if !check_inside_bounds(location):
		return false
	
	if compare_tile(location):
		combine_entity(location)
		return
	
	if !grid[location.x][location.y] == "floor":
		return
	if entity_grid[location.x][location.y]["id"] != "empty":
		return
	
	var instance = load(selected_entity["value"]).instantiate()
	instance.position = get_tile_real_position(location)
	
	match selected_entity["id"]:
		"stair_up":
			access_list.add_child(instance)
			if entrance:
				entrance.queue_free()
				clear_prev_entrance(location)
			entrance = instance
		"stair_down":
			access_list.add_child(instance)
			if exit:
				exit.queue_free()
				clear_prev_exit(location)
			exit = instance
		"chest":
			if Director.riches < 50:
				instance.queue_free()
				return
			Director.update_riches(-50)
			loot_list.add_child(instance)
			instance.chest_loot = 50
		"monster":
			if Director.souls < 1:
				instance.queue_free()
				return
			Director.update_souls(-1)
			monster_list.add_child(instance)
			$"..".level_monster_list.append(instance)
		_:
			print("NO MATCH")
			
	entity_grid[location.x][location.y]["id"] = selected_entity["id"]
	entity_grid[location.x][location.y]["object"] = instance

func combine_entity(location):
	#print("COMBINATION")
	#print("selected: ", selected_entity)
	#print("already_placed: ", entity_grid[location.x][location.y])
	if(selected_entity["id"] == entity_grid[location.x][location.y]["id"]) and Director.souls > 0:
		entity_grid[location.x][location.y]["object"].level_up()
		Director.update_souls(-1)
	pass

func compare_tile(location):
	return entity_grid[location.x][location.y]["id"] == selected_entity["id"]

func remove_entity():
	var location : Vector2i = get_tile_at_mousepos()
	print(location)
	pass

func clear_prev_entrance(new_entrance : Vector2i):
	for i in grid_width:
		for j in grid_height:
			if entity_grid[i][j]["id"] == "stair_up":
				entity_grid[i][j]["id"] = "empty"
	entity_grid[new_entrance.x][new_entrance.y]["id"] = "stair_up"

func clear_prev_exit(new_exit : Vector2i):
	for i in grid_width:
		for j in grid_height:
			if entity_grid[i][j]["id"] == "stair_down":
				entity_grid[i][j]["id"] = "empty"
	entity_grid[new_exit.x][new_exit.y]["id"] = "stair_down"

func set_selected_placeable_entity(entity):
	selected_entity = interactuable_dictionary[entity]
## END ENTITY PLACING

## UTIL
func get_tile_at_mousepos():
	var mouse_pos : Vector2 = get_global_mouse_position()
	var tile_mouse_pos : Vector2i = local_to_map(mouse_pos)
	return tile_mouse_pos

func get_tile_real_position(tile: Vector2i) -> Vector2:
	return map_to_local(tile)
