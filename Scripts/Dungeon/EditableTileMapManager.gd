extends TileMap

var grid = []
var entity_grid = []
var grid_width = 12
var grid_height = 12

var terrain_layer := 0
var source_id := 0
var atlas_coord : Vector2i = Vector2i(0,0)

var placeable_count := 90
var selected_placeable

enum EDIT_STATES {NONE, TILE, ENTITY, ROOM}
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
	
	10: {"id": "soulMonster", "value": "res://Scenes/Prefab/soulMonster.tscn"},
	11: {"id": "fleshMonster", "value": "res://Scenes/Prefab/fleshMonster.tscn"},
	12: {"id": "ironMonster", "value": "res://Scenes/Prefab/ironMonster.tscn"},
}

func _ready():
	generate_empty_grid()
	
func _unhandled_input(event):
	match editing_state:
		EDIT_STATES.TILE:
			if event.is_action_pressed("LeftClick"):
				change_tile(selected_placeable, get_tile_at_mousepos())
			if event.is_action_pressed("RightClick"):
				change_tile(tile_dictionary[0],get_tile_at_mousepos())
			
		EDIT_STATES.ENTITY:
			if event.is_action_pressed("LeftClick"):
				place_entity(selected_entity ,get_tile_at_mousepos())
				
			if event.is_action_pressed("RightClick"):
				remove_entity()
				
		EDIT_STATES.ROOM:
			update_room_stencil()
			if event.is_action_pressed("LeftClick"):
				if check_room_placeable():
					place_room(get_tile_at_mousepos())
			
	if event is InputEventKey and event.is_action_pressed("DebugButton"):
		toggle_room_stencil()


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
	
	place_entrance_room()



## DUNGEON EDIT
func change_tile(tile_value, tile_position):
	if !check_placeable_limit(tile_value, tile_position):
		return
		
	set_cell(terrain_layer, tile_position, source_id, tile_value["value"])
	grid[tile_position.x][tile_position.y] = tile_value["id"]
	
	for cell in get_surrounding_cells(tile_position):
		if !check_inside_bounds(cell):
			set_cell(terrain_layer, cell, source_id, tile_dictionary[0]["value"])
			continue
		if grid[cell.x][cell.y] == "empty":
			set_cell(terrain_layer, cell, source_id, tile_dictionary[0]["value"])
			grid[cell.x][cell.y] == "wall"

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

func place_entity(entity, location):
	if !check_inside_bounds(location):
		return false
	
	if compare_tile(location, entity):
		combine_entity(location)
		return
	
	if !grid[location.x][location.y] == "floor":
		return
	if entity_grid[location.x][location.y]["id"] != "empty":
		return
	
	var instance = load(entity["value"]).instantiate()
	instance.position = get_tile_real_position(location)
	
	match entity["id"]:
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
		"soulMonster":
			if Director.resources["soul"] < 1:
				instance.queue_free()
				return
			Director.update_resources({"soul": -1, "flesh": 0, "iron": 0})
			monster_list.add_child(instance)
			$"..".level_monster_list.append(instance)
		"fleshMonster":
			if Director.resources["flesh"] < 1:
				instance.queue_free()
				return
			Director.update_resources({"soul": 0, "flesh": -1, "iron": 0})
			monster_list.add_child(instance)
			$"..".level_monster_list.append(instance)
		"ironMonster":
			if Director.resources["iron"] < 1:
				instance.queue_free()
				return
			Director.update_resources({"soul": 0, "flesh": 0, "iron": -1})
			monster_list.add_child(instance)
			$"..".level_monster_list.append(instance)
		_:
			print("NO MATCH")
			
	entity_grid[location.x][location.y]["id"] = entity["id"]
	entity_grid[location.x][location.y]["object"] = instance

func combine_entity(location):
	#print("COMBINATION")
	#print("selected: ", selected_entity)
	#print("already_placed: ", entity_grid[location.x][location.y])
	if(selected_entity["id"] == entity_grid[location.x][location.y]["id"]):
		match selected_entity["id"]:
			"soulMonster":
				if !Director.update_resources({"soul": -1, "flesh": 0, "iron": 0}):
					return
				print("evo")
				entity_grid[location.x][location.y]["object"].level_up()
			"fleshMonster":
				if !Director.update_resources({"soul": 0, "flesh": -1, "iron": 0}):
					return
				entity_grid[location.x][location.y]["object"].level_up()
			"ironMonster":
				if !Director.update_resources({"soul": 0, "flesh": 0, "iron": -1}):
					return
				entity_grid[location.x][location.y]["object"].level_up()
		
	pass

func compare_tile(location, entity):
	return entity_grid[location.x][location.y]["id"] == entity["id"]

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

## END ENTITY PLACING



## UI
func set_selected_placeable_tile(tile_value):
	selected_placeable = tile_dictionary[tile_value]
	
func set_selected_placeable_entity(entity):
	selected_entity = interactuable_dictionary[entity]


## UTIL
func get_tile_at_mousepos():
	var mouse_pos : Vector2 = get_global_mouse_position()
	var tile_mouse_pos : Vector2i = local_to_map(mouse_pos)
	return tile_mouse_pos

func get_tile_real_position(tile: Vector2i) -> Vector2:
	return map_to_local(tile)


## ROOMS
var room_stencil = preload("res://Assets/UI/RoomStencil.png")
var current_room_stencil
var showing_room_stencil := false

func update_room_stencil():
	if !showing_room_stencil:
		return
		
	check_room_placeable()
	current_room_stencil.position = get_tile_real_position(get_tile_at_mousepos())
	pass

func toggle_room_stencil():
	if showing_room_stencil:
		current_room_stencil.queue_free()
		
	if !showing_room_stencil:
		editing_state = EDIT_STATES.ROOM
		current_room_stencil = Sprite2D.new()
		current_room_stencil.texture = room_stencil
		current_room_stencil.position = get_tile_real_position(get_tile_at_mousepos())
		add_child(current_room_stencil)
	
	showing_room_stencil = !showing_room_stencil

func place_room(room_position):
	var room_size = 3 ## ALL ROOMS 3 BY 3
	var dummy_room_grid =  []
	var starting_tile = room_position + Vector2i(-1,-1)
	
	for i in room_size:
		for j in room_size:
			change_tile(tile_dictionary[1], starting_tile + Vector2i(i,j))



func check_room_placeable():
	for y in 3:
		for x in 3:
			if !check_inside_bounds(get_tile_at_mousepos() + Vector2i(x-1,y-1)):
				current_room_stencil.modulate = Color(1,0,0)
				return false
				
	for y in 3:
		for x in 3:
			#print(get_tile_at_mousepos().x+x-2," , ", get_tile_at_mousepos().y+y-2)
			if grid[get_tile_at_mousepos().x+x-2][get_tile_at_mousepos().y+y-2] != "empty":
				
				current_room_stencil.modulate = Color(1,0,0)
				return false
				
	current_room_stencil.modulate = Color(1,1,1)
	return true
	
	## CHECK ALL THE ROOM TILES AND 1 SPACE AROUND THEM. DONT LET ROOMS TOUCH (ALLOW DOOR AND HALLWAY TILES BETWEEN THEM.)

func place_entrance_room():
	var entrance_pos = Vector2i(randi_range(1,grid_height-2), randi_range(1,grid_width-2))
	place_room(entrance_pos)
	place_entity(interactuable_dictionary[1],entrance_pos)
	
	var exit_pos = Vector2i(randi_range(1,grid_height-2), randi_range(1,grid_width-2))
	while ((exit_pos - entrance_pos).length() < 4):
		exit_pos = Vector2i(randi_range(1,grid_height-2), randi_range(1,grid_width-2))
		print("tried")
	print("gocha: ", exit_pos)
	place_room(exit_pos)
	place_entity(interactuable_dictionary[0],exit_pos)
