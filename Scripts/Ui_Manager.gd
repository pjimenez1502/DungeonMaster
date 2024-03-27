extends Control

var stage : int = 0

@onready var level_editing = $Right_Panel/LevelEditing
@onready var level_populating = $Right_Panel/LevelPopulating

@onready var level = $SubViewportContainer/SubViewport/Dungeon/Level
@onready var next_day_screen = $NextDayScreen


func _ready():
	next_day_screen.visible = true
	Director.DUNGEON = $SubViewportContainer/SubViewport/Dungeon
	
	open_level_editor()
	Director.RICHES_UPDATE.connect(update_riches)
	Director.RESOURCES_UPDATE.connect(update_resources)
	Director.DAY_UPDATE.connect(update_day)
	Director.RENOUN_UPDATE.connect(update_renoun)
	
	Director.DAY_END.connect(reset_editable_ui)
	Director.dungeon_init()
	
	Director.SHOW_CHART.connect(show_chart)

func reset_editable_ui():
	next_day_screen.show_screen()
	stage = 1
	$LeftPanel/Back.visible = false
	_on_next_pressed(0)

func open_level_editor():
	level_editing.visible = true
	level_populating.visible = false
	show_builddungeon_sheet(true)
	show_adventurer_sheet(null)
	
func open_level_populator():
	level_editing.visible = false
	level_populating.visible = true
	show_builddungeon_sheet(false)
	
	level.get_adventurer()
	var sheet = Director.get_sheet()
	show_adventurer_sheet(sheet)


func play_level():
	if !level.start_level():
		return false
	level_editing.visible = false
	level_populating.visible = false



func _on_next_pressed(value):
	if !level.check_playable():
		print("UNPLAYABLE")
		return false
	stage = clampi(stage + value, 0, 3)
	match stage:
		0:
			open_level_editor()
		1:
			open_level_populator()
		2:
			if !play_level():
				stage -= 1

## STATS PANNEL
@onready var riches_value = $LeftPanel/Stats/ColorRect/MarginContainer/VBoxContainer/Riches/value
func update_riches(value):
	riches_value.text = str(value)

@onready var soul_count = %SoulCount
@onready var flesh_count = %FleshCount
@onready var iron_count = %IronCount

func update_resources(value):
	soul_count.text = str(value["soul"])
	flesh_count.text = str(value["flesh"])
	iron_count.text = str(value["iron"])


@onready var day_value = $LeftPanel/Stats/ColorRect/MarginContainer/VBoxContainer/Day/value
func update_day(value):
	day_value.text = str(value)

@onready var renoun_value = $LeftPanel/Stats/ColorRect/MarginContainer/VBoxContainer/Renoun/value
func update_renoun(value):
	renoun_value.text = str(value)
## END STATS PANNEL

## INFO SHEETS PANEL
@onready var next_adventurer_sheet = $LeftPanel/Next_Adventurer_Sheet
func show_adventurer_sheet(sheet: Node):
	if !sheet:
		next_adventurer_sheet.visible = false
		return
	next_adventurer_sheet.visible = true
	next_adventurer_sheet.add_child(sheet)
	sheet.position = Vector2(28, 30)

@onready var dungeon_build_sheet = $LeftPanel/Dungeon_Build_Sheet
func show_builddungeon_sheet(value):
	dungeon_build_sheet.visible = value
## INFO SHEETS PANEL

func show_chart(chart):
	add_child(chart)
	chart.position = get_global_mouse_position() + Vector2(20, -100)




func set_selected_tile(tile):
	level._on_tile_button_pressed(tile)
	
func set_selected_entity(entity):
	level._on_entity_button_pressed(entity)
