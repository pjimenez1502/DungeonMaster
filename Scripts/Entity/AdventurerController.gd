extends PathfindingEntity
class_name Adventurer

var attack_time := 0.5

var exit
var exit_pos
var treasure_list

var melee : bool

var looted_ammount := 0

@onready var interaction_timer = $InteractionTimer
var level_dictionary = {
	0: "Novice",
	1: "Apprentice",
	2: "Adept",
	3: "Expert",
	4: "Master",
	5: "Legendary",
}
var level : int

func _ready():
	super._ready()
	enemy_mask = 0b10

func adventurer_pathfind():
	if find_closest_enemy(): ## found closest enemy
		return
	if find_closest_treasure(): ## found closest treasure
		return
	find_exit()
	
	return

func find_closest_enemy():
	if !targets_on_sight.size() > 0:
		return false
	
	var closest_target = targets_on_sight[0]
	for target in targets_on_sight:
		if target.global_position.distance_to(self.global_position) < closest_target.global_position.distance_to(self.global_position):
			closest_target = target
	target_pos = closest_target.position
	target = closest_target
	return true
	
func find_closest_treasure():
	if !treasure_list.size() > 0:
		return false
		
	var closest_treasure = treasure_list[0]
	for treasure in treasure_list:
		if treasure.global_position.distance_to(self.global_position) < closest_treasure.global_position.distance_to(self.global_position):
			closest_treasure = treasure
	target_pos = closest_treasure.position
	target = closest_treasure
	return true

func find_exit():
	target_pos = exit.position
	target = exit
	
func _on_pathfindtimer_timeout():
	#if target:
		#print("RANGE TO TARGET: ", (target.position - position).length())
		
	adventurer_pathfind()
	if target_pos:
		nav_agent.target_position = target_pos

func check_interact():
	if !target:
		return
	if target is Interactuable:
		if(target.position - position).length() > 16:
			return
		target.interact()
		if treasure_list.has(target):
			treasure_list.erase(target)
		return
	if target is Monster:
		super.check_interact()

func die():
	Director.adventurer_death()
	super.die()

var stats_per_level = {
	"health": {"min": 2, "max": 10},
	"damage": {"min": 1, "max": 5},
	"speed": {"min": 0, "max": 4},
	"dodge_chance": {"min": 1, "max": 5},
	"block_change": {"min": 0, "max": 0},
	"attack_delay": {"min": 0, "max": 0},
}

func calculate_level(level):
	print("CALCULING ADVENTURER LEVEL: ", level)
	level_name = level_dictionary[level]
	for i in range(0, level):
		max_health += randi_range(stats_per_level["health"]["min"], stats_per_level["health"]["max"])
		damage += randi_range(stats_per_level["damage"]["min"], stats_per_level["damage"]["max"]) 
		BASE_SPEED += randi_range(stats_per_level["speed"]["min"], stats_per_level["speed"]["max"]) 
	
	
	#max_health += (randi_range(stats_per_level["health"]["min"], stats_per_level["health"]["max"]) * level)
	#damage += (randi_range(stats_per_level["damage"]["min"], stats_per_level["damage"]["max"]) * level)
	#BASE_SPEED += (randi_range(stats_per_level["speed"]["min"], stats_per_level["speed"]["max"]) * level)
	
