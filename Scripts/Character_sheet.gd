extends Control


@onready var health_label = $"Card Background/MarginContainer/VBoxContainer/Stats Margin/MarginContainer/HBoxContainer/Left/Health/value"
@onready var damage_label = $"Card Background/MarginContainer/VBoxContainer/Stats Margin/MarginContainer/HBoxContainer/Left/Damage/value"
@onready var movespeed_label = $"Card Background/MarginContainer/VBoxContainer/Stats Margin/MarginContainer/HBoxContainer/Right/Movespeed/value"

@onready var portrait_label = $"Card Background/MarginContainer/VBoxContainer/Portrait Margin/Portrait/Portrait"
@onready var character_name_label = $"Card Background/MarginContainer/VBoxContainer/Name Margin/name"
@onready var level_label = $"Card Background/MarginContainer/VBoxContainer/Level Margin/level"

@onready var agility = $"Card Background/MarginContainer/VBoxContainer/Stats Margin/MarginContainer/HBoxContainer/Right/Agility/value"

var health
var damage
var movespeed
var portrait
var char_name
var level

func _ready():
	health_label.text = health
	damage_label.text = damage
	movespeed_label.text = movespeed
	
	portrait_label.texture = portrait
	#character_name.text = char_name
	level_label.text = level

func load_sheet_data(character):
	health = str(character.max_health)
	damage = str(character.damage)
	movespeed = str(character.BASE_SPEED)
	
	portrait = character.portrait
	char_name = character.name
	level = character.level_name
	
	
	
	

