extends Control

@onready var health_label = %HealthLabel
@onready var damage_label = %DamageLabel
@onready var movespeed_label = %MovespeedLabel

@onready var portrait_label = %Portrait
@onready var character_name_label = %NameLabel
@onready var level_label = %LevelLabel


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
	movespeed = str(character.speed)
	
	portrait = character.portrait
	char_name = character.name
	level = character.level_name
	
	
	
	

