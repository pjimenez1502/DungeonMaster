extends PathfindingEntity
class_name Monster

var starting_pos

func _ready():
	starting_pos = position

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


