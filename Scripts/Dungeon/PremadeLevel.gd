extends TileMap

@export var entrance : Interactuable
@export var exit : Interactuable

@onready var boss_room = $".."
@onready var loot_list = $"../LootList"


func _ready():
	boss_room.tile_map = self
	#boss_room.start_level()


func get_tile_real_position(tile: Vector2i) -> Vector2:
	return map_to_local(tile)
