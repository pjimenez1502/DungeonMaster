extends Entity
class_name PathfindingEntity

var attack = load("res://Scenes/Prefab/VFX/Slash.tscn")

@export var BASE_SPEED = 40
const acceleration = 6

var target_pos

var targets_on_sight = []
var targets_in_range = []

var in_action := false

@onready var nav_agent : NavigationAgent2D = $Nav/NavigationAgent2D

func _ready():
	if !BASE_SPEED:
		print("NO BASE SPEED")
		BASE_SPEED = 30
	nav_agent.path_desired_distance = 20
	nav_agent.target_desired_distance = 20
	

func _physics_process(delta):
	if in_action:
		return
	pathfind_and_move()

func pathfind_and_move():
	if nav_agent.is_navigation_finished():
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
	print("attack")
	in_action = true
	var instance = attack.instantiate()
	instance.position = Vector2.ZERO
	add_child(instance)
	
	instance.look_at(target.global_position)

	await get_tree().create_timer(0.8).timeout
	in_action = false


func _on_aggro_area_body_entered(body):
	targets_on_sight.append(body)

func _on_aggro_area_body_exited(body):
	targets_on_sight.erase(body)

func _on_attack_area_body_entered(body):
	targets_in_range.append(body)

func _on_attack_area_body_exited(body):
	targets_in_range.erase(body)
