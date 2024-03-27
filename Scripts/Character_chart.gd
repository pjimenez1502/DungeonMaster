extends Control

@onready var health_label = %HealthLabel
@onready var damage_label = %DamageLabel
@onready var movespeed_label = %MovespeedLabel

@onready var portrait_label = %Portrait

@onready var xp_bar = %XpBar

var health
var damage
var movespeed
var portrait
var char_name
var level

var xp_to_level
var xp

func _ready():
	health_label.text = health
	damage_label.text = damage
	movespeed_label.text = movespeed
	
	portrait_label.texture = portrait
	#character_name.text = char_name
	
	xp_bar.max_value = xp_to_level
	xp_bar.value = xp

func load_sheet_data(character):
	health = str(character.max_health)
	damage = str(character.damage)
	movespeed = str(character.speed)
	
	portrait = character.portrait
	char_name = character.name
	
	xp_to_level = character.xp_to_level
	xp = character.xp
