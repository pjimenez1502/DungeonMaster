extends CharacterBody2D
class_name PathfindingEntity

var slash = load("res://Scenes/Prefab/VFX/Slash.tscn")
var corpse = load("res://Scenes/Prefab/VFX/corpse.tscn")
var COMBAT_TEXT = load("res://Scenes/UI/Combat_Text.tscn")

@export var portrait : Texture2D
@export var BASE_SPEED = 40
@export var damage := 5
@export var max_health := 10
var level_name : String
var health

var enemy_mask
var target_pos

var targets_on_sight = []
var targets_in_range = []
var target

var in_action := false

@onready var nav_agent : NavigationAgent2D = $Nav/NavigationAgent2D
@onready var health_bar_manager = $HealthBar_Manager

func _ready():
	health = max_health
	if !BASE_SPEED:
		print("NO BASE SPEED")
		BASE_SPEED = 30
	nav_agent.path_desired_distance = 16
	nav_agent.target_desired_distance = 8
	
	health_bar_manager.set_max_HP(health, "PLAYER")
	

func _physics_process(delta):
	if in_action:
		return
	pathfind_and_move()

func pathfind_and_move():
	if target == null: ## Check for freed objects
		target = null
	if nav_agent.is_navigation_finished():
		if target:
			check_interact()
		return
	var direction = Vector2.ZERO
	var next_path_position = nav_agent.get_next_path_position()
	direction = next_path_position - global_position
	direction = direction.normalized()
	
	#print(target_pos, " - ", global_position, " -- ", next_path_position )
	#velocity = velocity.lerp(direction * BASE_SPEED, acceleration * delta)
	velocity = direction * BASE_SPEED
	move_and_slide()


func check_interact():
	if targets_in_range.size() > 0:
		instantiate_attack(targets_in_range[0])
		pass

func instantiate_attack(target):
	in_action = true
	var slash_instance = slash.instantiate()
	slash_instance.position = Vector2.ZERO
	add_child(slash_instance)
	
	slash_instance.init_slash(damage, enemy_mask)
	slash_instance.look_at(target.global_position)

	await get_tree().create_timer(0.8).timeout
	in_action = false



func recieve_damage(damage):
	var combat_text = COMBAT_TEXT.instantiate()
	add_child(combat_text)
	combat_text.start_combat_text(str(damage), Vector2(8, -8), 32, 16)
	
	health -= damage
	health_bar_manager.hb_damage(damage)
	if health <= 0:
		die()
	

func die():
	spawn_corpse()
	get_parent().remove_child(self)
	#queue_free()

func spawn_corpse():
	var corpse_instance = corpse.instantiate()
	corpse_instance.position = position
	get_parent().add_child(corpse_instance)
	
func reset_health():
	health = max_health
	health_bar_manager.set_HP(health)

func _on_aggro_area_body_entered(body):
	targets_on_sight.append(body)

func _on_aggro_area_body_exited(body):
	targets_on_sight.erase(body)

func _on_attack_area_body_entered(body):
	targets_in_range.append(body)

func _on_attack_area_body_exited(body):
	targets_in_range.erase(body)
