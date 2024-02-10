extends PathfindingEntity
class_name Monster

var starting_pos
var level := 1
var xp := 0



func _ready():
	super._ready()
	enemy_mask = 0b100
	starting_pos = position
	level_name = str(level, " : ", xp, " / 2")

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
		
var stats_per_level = {
	"health": {"min": 6, "max": 6},
	"damage": {"min": 3, "max": 3},
	"speed": {"min": 0, "max": 0},
}
func level_up():
	
	var xp_to_level = level * 2
	xp += 1
	if xp >= xp_to_level:
		print("LEVELUP")
		xp -= xp_to_level
		level += 1
		max_health += randi_range(stats_per_level["health"]["min"], stats_per_level["health"]["max"])
		health = max_health
		damage += randi_range(stats_per_level["damage"]["min"], stats_per_level["damage"]["max"]) 
		speed += randi_range(stats_per_level["speed"]["min"], stats_per_level["speed"]["max"])
		
	level_name = str(level, " : ", xp, " / ", xp_to_level)
