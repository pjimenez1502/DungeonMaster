extends PathfindingEntity
class_name Monster

var starting_pos

func _ready():
	super._ready()
	enemy_mask = 0b100
	starting_pos = position

func monster_pathfind():
	if targets_on_sight.size() == 0:
		target_pos = starting_pos
		nav_agent.path_desired_distance = 5
	else:
		nav_agent.path_desired_distance = 20
		target_pos = targets_on_sight[0].position
		target = targets_on_sight[0]
	if nav_agent.is_navigation_finished():
		check_interact()

func _on_pathfindtimer_timeout():
	monster_pathfind()
	if target_pos:
		nav_agent.target_position = target_pos
