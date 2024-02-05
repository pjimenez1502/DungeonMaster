extends CharacterBody2D
class_name monster

const BASE_SPEED = 40
const acceleration = 6
var health

var free_to_move := true

var starting_pos
var target_pos
var targets_on_sight = []

@onready var nav_agent : NavigationAgent2D = $Nav/NavigationAgent2D
func _ready():
	nav_agent.path_desired_distance = 4
	nav_agent.target_desired_distance = 4
	starting_pos = position

func _physics_process(delta):
	if free_to_move:
		pathfind_and_move()

func pathfind_and_move():
	if nav_agent.is_navigation_finished():
		return
	
	var direction = Vector2.ZERO
	var next_path_position = nav_agent.get_next_path_position()
	direction = next_path_position - global_position
	direction = direction.normalized()
	print(next_path_position)
	
	#print(target_pos, " - ", global_position, " -- ", next_path_position )
	#velocity = velocity.lerp(direction * BASE_SPEED, acceleration * delta)
	velocity = direction * BASE_SPEED
	move_and_slide()

func monster_pathfind():
	if targets_on_sight.size() == 0:
		target_pos = starting_pos
	else :
		target_pos = targets_on_sight[0].position

func _on_pathfindtimer_timeout():
	monster_pathfind()
	if target_pos:
		#print(target_pos)
		nav_agent.target_position = target_pos


func _on_aggro_area_body_entered(body):
	targets_on_sight.append(body)

func _on_aggro_area_body_exited(body):
	targets_on_sight.erase(body)
