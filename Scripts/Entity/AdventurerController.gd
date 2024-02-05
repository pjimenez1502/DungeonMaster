extends CharacterBody2D
class_name Adventurer

const BASE_SPEED = 40
const acceleration = 6
var health

var exit_pos
var target_pos
var targets_on_sight = []

@onready var nav_agent : NavigationAgent2D = $Nav/NavigationAgent2D
func _ready():
	nav_agent.path_desired_distance = 4
	nav_agent.target_desired_distance = 4

func _physics_process(delta):
	pathfind_and_move()

func pathfind_and_move():
	if nav_agent.is_navigation_finished():
		return
	
	var direction = Vector2.ZERO
	var next_path_position = nav_agent.get_next_path_position()
	direction = next_path_position - global_position
	direction = direction.normalized()
	
	#print(target_pos, " - ", global_position, " -- ", next_path_position )	
	#velocity = velocity.lerp(direction * BASE_SPEED, acceleration * delta)
	velocity = direction * BASE_SPEED
	move_and_slide()

func adventurer_pathfind():
	
	for target in targets_on_sight:
		
		pass
	
	target_pos = exit_pos
	return

func _on_pathfindtimer_timeout():
	adventurer_pathfind()
	if target_pos:
		nav_agent.target_position = target_pos

func _on_aggro_area_body_entered(body):
	targets_on_sight.append(body)
	print(targets_on_sight)

func _on_aggro_area_body_exited(body):
	targets_on_sight.erase(body)
