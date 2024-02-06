extends Control

var stage : int = 0

@onready var level_editing = $LevelEditing
@onready var level_populating = $LevelPopulating

@onready var dungeon = $SubViewportContainer/SubViewport/Dungeon
@onready var level = $SubViewportContainer/SubViewport/Dungeon/EditableLevel

func _ready():
	open_level_editor()
	dungeon.RICHES_UPDATE.connect(update_riches)
	dungeon.SOULS_UPDATE.connect(update_souls)
	
	dungeon.dungeon_init()


func open_level_editor():
	level_editing.visible = true
	level_populating.visible = false
	
func open_level_populator():
	level_editing.visible = false
	level_populating.visible = true

func play_level():
	if !level.start_level():
		return false
	level_editing.visible = false
	level_populating.visible = false



func add_level():
	pass
	## current_level_level +1
	## 

func _on_next_pressed(value):
	stage = clampi(stage + value, 0, 3)
	match stage:
		0:
			open_level_editor()
		1:
			open_level_populator()
		2:
			if !play_level():
				stage -= 1


@onready var riches_value = $Stats/ColorRect/MarginContainer/VBoxContainer/Riches/value
func update_riches(value):
	riches_value.text = str(value)

@onready var souls_value = $Stats/ColorRect/MarginContainer/VBoxContainer/Souls/value
func update_souls(value):
	souls_value.text = str(value)
