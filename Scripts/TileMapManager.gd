extends TileMap

var grid = []
var entity_grid = []
var grid_width = 12
var grid_height = 12

var terrain_layer := 0
var source_id := 0
var atlas_coord : Vector2i = Vector2i(0,0)

var placeable_count := 50
var selected_placeable := "floor"

var dungeon_editing = false
var dungeon_populating = false

var tile_dictionary = {
	"empty": Vector2i(0,0),
	"wall": Vector2i(1,0),
	"floor": Vector2i(2,0),
	"door": Vector2i(0,1),
	"stair_down": Vector2i(1,1),
	"stair_up": Vector2i(2,1),
	}

var entity_dictionary = {
	"chest": "res://Scenes/Prefab/Chest.tscn",
	"unarmed_skeleton": "res://Scenes/Prefab/Monster.tscn",
}
var entrance_location
var exit_location

var loot_locations = []
var enemy_list = []

func _unhandled_input(event):
	if dungeon_editing:
		if event.is_action_pressed("LeftClick"):
			change_hovered_tile(selected_placeable)
		if event.is_action_pressed("RightClick"):
			change_hovered_tile("wall")
			
	if dungeon_populating:
		if event.is_action_pressed("LeftClick"):
			place_entity()
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
			set_cell(terrain_layer, Vector2(i,j), source_id, tile_dictionary["empty"])
	
	for i in grid_width:
		entity_grid.append([])
		for j in grid_height:
			entity_grid[i].append("empty")

## DUNGEON EDIT
func change_hovered_tile(tile_value):
	var mouse_tile : Vector2i = get_tile_at_mousepos()
	print(tile_value)
	if !check_placeable_limit(tile_value, mouse_tile):
		return
		
	set_cell(terrain_layer, mouse_tile, source_id, tile_dictionary[tile_value])
	grid[mouse_tile.x][mouse_tile.y] = tile_value
	
	for cell in get_surrounding_cells(mouse_tile):
		if !check_inside_bounds(cell):
			set_cell(terrain_layer, cell, source_id, tile_dictionary["wall"])
			continue
		if grid[cell.x][cell.y] == "empty":
			set_cell(terrain_layer, cell, source_id, tile_dictionary["wall"])
			grid[cell.x][cell.y] == "wall"
	
	check_placing_stair(tile_value, mouse_tile)

func check_placeable_limit(tile_value, mouse_tile) -> bool:
	if !check_inside_bounds(mouse_tile):
		return false
	var prev_tile_atlas = get_cell_atlas_coords(terrain_layer, mouse_tile)
	
	if tile_value != "wall" and (prev_tile_atlas == tile_dictionary["empty"] or prev_tile_atlas == tile_dictionary["wall"]):
		if placeable_count < 1:
			return false
		placeable_count -= 1
	if tile_value == "wall" and (prev_tile_atlas != tile_dictionary["empty"] and prev_tile_atlas != tile_dictionary["wall"]):
		placeable_count += 1
	return true

func check_placing_stair(tile_value, mouse_tile):
	## CHECK IF TILE_VALUE IS ANY OF THE STAIRS AND REMOVE PREVIOUS SIMILAR STAIR IF ALREADY ONE PLACED IN THE MAP.
	## SAVE NEW STAIR ENTRANCE AND EXIT ON VARIABLES TO SEND TO THE ADVENTURER.
	
	if tile_value == "stair_up":
		if entrance_location:
			set_cell(terrain_layer, entrance_location, source_id, tile_dictionary["floor"])
		entrance_location = mouse_tile
	
	if tile_value == "stair_down":
		if exit_location:
			set_cell(terrain_layer, exit_location, source_id, tile_dictionary["floor"])
		exit_location = mouse_tile

func set_selected_placeable_tile(tile_value):
	selected_placeable = tile_value

func check_inside_bounds(position):
	if position.x == grid_width or position.y == grid_height or position.x < 0 or position.y < 0:
		return false
	return true
## END DUNGEON EDIT


## ENTITY PLACING
var selected_entity
@onready var monster_list = $"../MonsterList"
@onready var loot_list = $"../LootList"

func place_entity():
	
	var mouse_tile : Vector2i = get_tile_at_mousepos()
	
	if entity_grid[mouse_tile.x][mouse_tile.y] == selected_entity:
		print("COMBINE?")
		return
	
	if !grid[mouse_tile.x][mouse_tile.y] == "floor":
		return
		
	if entity_grid[mouse_tile.x][mouse_tile.y] != "empty":
		return
	
	entity_grid[mouse_tile.x][mouse_tile.y] = selected_entity
	var instance = load(entity_dictionary[selected_entity]).instantiate()
	instance.position = get_tile_real_position(mouse_tile)
	
	if selected_entity == "chest":
		loot_list.add_child(instance)
		return
	
	monster_list.add_child(instance)
	
func remove_entity():
	pass

func set_selected_placeable_entity(entity):
	selected_entity = entity
## END ENTITY PLACING

## UTIL
func get_tile_at_mousepos():
	var mouse_pos : Vector2 = get_global_mouse_position()
	var tile_mouse_pos : Vector2i = local_to_map(mouse_pos)
	return tile_mouse_pos

func set_dungeon_editable(value: bool):
	dungeon_editing = value

func set_dungeon_populating(value: bool):
	dungeon_populating = value
	
func get_tile_real_position(tile: Vector2i) -> Vector2:
	return map_to_local(tile)
