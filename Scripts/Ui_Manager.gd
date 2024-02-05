extends Control

var stage : int = 0

@onready var dungeon_editing = $DungeonEditing
@onready var dungeon_populating = $DungeonPopulating

@onready var dungeon = $SubViewportContainer/SubViewport/Dungeon

func _ready():
	open_dungeon_editor()



func open_dungeon_editor():
	dungeon_editing.visible = true
	dungeon_populating.visible = false
	dungeon.tile_map.set_dungeon_editable(true)
	dungeon.tile_map.set_dungeon_populating(false)
	
func open_dungeon_populator():
	dungeon_editing.visible = false
	dungeon_populating.visible = true
	dungeon.tile_map.set_dungeon_editable(false)
	dungeon.tile_map.set_dungeon_populating(true)

func play_dungeon():
	dungeon.start_dungeon()

func _on_next_pressed():
	match stage:
		0:
			open_dungeon_populator()
			stage = 1
		1:
			play_dungeon()
